@echo off
setlocal

:: ============================================================================
:: Last Epoch Save Manager - v2.5 (Added "Backup Only" option)
:: ============================================================================
:: This script automates the process of backing up saves, launching the game
:: to bypass the "save file exists" bug, and then restoring the saves.
:: ============================================================================

REM --- Configuration ---
REM Set the paths below to match your system.
set "SAVES_PARENT_DIR=C:\Users\alfre\AppData\LocalLow\Eleventh Hour Games\Last Epoch"
set "GAME_EXE_PATH=C:\Games\Last Epoch\Last Epoch.exe"
set "PLANNER_EXE_PATH=C:\Games\Last Epoch\Planner\Last Epoch Planner.exe"

REM --- Do not edit below this line ---
set "SAVES_DIR=%SAVES_PARENT_DIR%\Saves"
set "BACKUP_ROOT=%SAVES_PARENT_DIR%\Backups"
set "GAME_LAUNCH_ARGS=--offline"


:main_menu
cls
title Last Epoch Save Manager
color 0B
echo ===========================================
echo         Last Epoch Save Manager
echo ===========================================
echo.
echo   [1] Full Process ^(Backup / Launch / Restore^)
echo   [2] Backup Saves Only
echo   [3] Restore Latest Backup Only
echo   [4] Open Saves ^& Backups Folder
echo   [5] Exit
echo.
choice /c 12345 /n /m "Please choose an option [1,2,3,4,5]: "

if errorlevel 5 goto :eof
if errorlevel 4 goto open_folders
if errorlevel 3 goto restore_only_process
if errorlevel 2 goto backup_only_process
if errorlevel 1 goto full_process

:full_process
call :backup_saves
call :launch_games
call :restore_saves
goto end_script

:backup_only_process
call :backup_saves
echo.
echo Backup process complete.
pause
goto main_menu

:restore_only_process
call :restore_saves
echo.
echo Restore process complete.
pause
goto main_menu

:backup_saves
cls
echo ===========================================
echo         Part 1: Backing Up Saves
echo ===========================================
echo.

if not exist "%SAVES_DIR%" (
    echo [INFO] No 'Saves' folder found to back up.
    echo The game will start with a fresh profile.
    echo.
    goto :eof
)

echo [1] Creating a new timestamped backup...
echo.

REM Create main backup directory if it doesn't exist
if not exist "%BACKUP_ROOT%" mkdir "%BACKUP_ROOT%"

REM --- Generate a reliable, locale-independent timestamp using WMIC ---
for /f "skip=1 tokens=1-6" %%A in ('wmic path Win32_LocalTime get Day^,Month^,Year^,Hour^,Minute^,Second /format:table') do (
    set "YYYY=%%F"
    set "MM=%%D"
    set "DD=%%A"
    set "HH=%%B"
    set "MIN=%%C"
    set "SS=%%E"
    goto :got_datetime
)
:got_datetime

REM Pad single-digit numbers with a leading zero for proper sorting
if %MM% LSS 10 set "MM=0%MM%"
if %DD% LSS 10 set "DD=0%DD%"
if %HH% LSS 10 set "HH=0%HH%"
if %MIN% LSS 10 set "MIN=0%MIN%"
if %SS% LSS 10 set "SS=0%SS%"

set "TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%MIN%-%SS%"
set "TIMESTAMPED_BACKUP_PATH=%BACKUP_ROOT%\%TIMESTAMP%"
REM --- End of timestamp generation ---

echo    Source:      "%SAVES_DIR%"
echo    Destination: "%TIMESTAMPED_BACKUP_PATH%"
echo.

robocopy "%SAVES_DIR%" "%TIMESTAMPED_BACKUP_PATH%" /E /R:2 /W:5 >nul
if errorlevel 1 (
    echo [SUCCESS] Backup created successfully.
    echo.
    echo [2] Removing original 'Saves' folder to allow game launch...
    rmdir /s /q "%SAVES_DIR%"
    echo    'Saves' folder removed.
) else (
    echo [ERROR] Backup failed! Robocopy returned errorlevel %errorlevel%.
    echo The script cannot continue safely.
    pause
    exit /b 1
)
echo.
goto :eof

:launch_games
cls
echo ===========================================
echo         Part 2: Launching Games
echo ===========================================
echo.
echo The script will now launch the game and planner.
echo After you are finished playing and have closed Last Epoch,
echo come back to this window to restore your saves.
echo.
echo Press any key to launch the game...
pause >nul

echo.
echo Launching Last Epoch...
start "Last Epoch" "%GAME_EXE_PATH%" %GAME_LAUNCH_ARGS%

if exist "%PLANNER_EXE_PATH%" (
    echo Launching Planner...
    start "Last Epoch Planner" "%PLANNER_EXE_PATH%"
)
echo.
echo [SUCCESS] Game has been launched.
echo.
echo =================================================================
echo   IMPORTANT: Play the game. When you are done, close the game
echo   and then press a key in this window to restore your saves.
echo =================================================================
echo.
pause >nul
goto :eof


:restore_saves
cls
echo ===========================================
echo         Part 3: Restoring Saves
echo ===========================================
echo.
echo [1] Finding the most recent backup...

REM Find the latest backup directory
for /f "delims=" %%d in ('dir "%BACKUP_ROOT%" /b /ad /o-d') do (
    set "LATEST_BACKUP=%BACKUP_ROOT%\%%d"
    goto :found_backup
)

echo [ERROR] No backups were found in "%BACKUP_ROOT%".
echo Cannot restore anything.
echo.
pause
goto :eof

:found_backup
echo    Latest backup found: "%LATEST_BACKUP%"
echo.

REM The game creates a new, empty 'Saves' folder. We must delete it first.
if exist "%SAVES_DIR%" (
    echo [2] Removing new 'Saves' folder created by the game...
    rmdir /s /q "%SAVES_DIR%"
    echo    Done.
    echo.
)

echo [3] Restoring saves from the latest backup...
robocopy "%LATEST_BACKUP%" "%SAVES_DIR%" /E /R:2 /W:5 >nul
if not errorlevel 1 (
    echo [ERROR] Restore failed! Robocopy returned errorlevel %errorlevel%.
    echo Please check the backup and save folders manually.
) else (
    echo [SUCCESS] Your saves have been restored successfully.
)
echo.
goto :eof

:open_folders
explorer "%SAVES_PARENT_DIR%"
goto main_menu

:end_script
cls
echo ===========================================
echo           Script Finished
echo ===========================================
echo.
echo All selected tasks are complete.
echo.
echo Press any key to close this window...
pause >nul
exit