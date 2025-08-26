# Last Epoch Save Manager

A comprehensive command-line utility for Windows designed to manage "Last Epoch" save files. This script provides a robust workaround for a common game launch bug while offering powerful backup and restore features.

## The Problem

The game "Last Epoch" can fail to launch if a `Saves` folder is already present in its `AppData` directory. This forces players into a tedious and error-prone manual process: moving the save folder before launching the game, and then restoring it after playing.

## The Solution

This script automates the entire workflow. It provides a simple, menu-driven interface to safely back up your saves, prepare the directory for a clean game launch, and then reliably restore your most recent save data after your session. It's designed to be robust, user-friendly, and safe.

---

## Key Features

- **Automated Workflow**: Handles the entire backup -> launch -> restore process with a single selection.
- **Safe, Timestamped Backups**: Creates a new, timestamped backup (e.g., `2025-08-25_08-31-55`) every time. You'll never lose an old save file.
- **Intelligent Restore Logic**: The script is smart enough to remove the new, empty `Saves` folder created by the game before restoring your backup, preventing a common issue where saves are restored into a nested sub-folder.
- **Robust File Operations**: Uses `robocopy` for all file operations, which is more reliable and resilient than older commands like `xcopy`.
- **Locale-Independent Timestamps**: Generates timestamps using `wmic` to ensure they are always formatted correctly, regardless of your Windows regional date and time settings.
- **Flexible Menu System**: Gives you full control over the process:
  - Run the full, automated process.
  - Perform only a backup.
  - Restore the latest backup manually.
  - Quickly open the saves folder in Windows Explorer.
- **Error Handling**: Provides clear feedback if a backup or restore operation fails, and checks for the existence of necessary folders.
- **Easy Configuration**: All user-specific paths are centralized at the top of the script for easy editing.

---

## How It Works: The Technical Details

The script's logic is designed to be safe and to directly address the game's launch bug.

1. **Backup (`:backup_saves`)**:
    - A timestamped folder is created in the `Backups` directory.
    - `robocopy` is used to create a perfect mirror of your current `Saves` folder inside the new timestamped folder.
    - **Crucially**, after a successful backup, the original `Saves` folder is completely removed. This is the key step that allows the game to launch without issue.

2. **Launch (`:launch_games`)**:
    - The script launches `Last Epoch.exe` with the `--offline` argument.
    - It then pauses and waits for you to finish your gaming session. The script does not proceed until you return to the command window and press a key.

3. **Restore (`:restore_saves`)**:
    - The script automatically finds the most recent backup by sorting the backup folders by date.
    - When "Last Epoch" launches without a `Saves` folder, it creates a new, empty one. To prevent errors, the script **deletes this new empty folder** before restoring your data.
    - `robocopy` is then used to copy your most recent backup back to the original `Saves` location, fully restoring your progress.

---

## Configuration

Before first use, you **must** configure the paths in the script. Open `Last Epoch.cmd` in a text editor and modify the variables in the `Configuration` section.

```batch
REM --- Configuration ---
REM Set the paths below to match your system.
set "SAVES_PARENT_DIR=C:\Users\YOUR_USERNAME\AppData\LocalLow\Eleventh Hour Games\Last Epoch"
set "GAME_EXE_PATH=C:\Path\To\Your\Game\Last Epoch.exe"
set "PLANNER_EXE_PATH=C:\Path\To\Your\Planner\Last Epoch Planner.exe"
```

- `SAVES_PARENT_DIR`: The path to the Last Epoch folder in your `AppData\LocalLow`. **Remember to replace `YOUR_USERNAME` with your actual Windows username**.
- `GAME_EXE_PATH`: The full path to the `Last Epoch.exe` file.
- `PLANNER_EXE_PATH`: (Optional) The full path to the `Last Epoch Planner.exe`. If you don't use the planner, the script will simply skip launching it.

## How to Use

1. Save the script as `Last Epoch.cmd` in a convenient location.
2. **Edit the Configuration section** as described above.
3. Double-click the `Last Epoch.cmd` file to run it.
4. A menu will appear. Choose an option by typing the corresponding number.

### Menu Options

- **[1] Full Process (Backup / Launch / Restore)**: The standard, all-in-one option.
- **[2] Backup Saves Only**: Creates a timestamped backup without launching the game or deleting the original `Saves` folder.
- **[3] Restore Latest Backup Only**: Restores the most recent backup, overwriting any current `Saves` folder.
- **[4] Open Saves & Backups Folder**: Opens the parent directory in Windows Explorer.
- **[5] Exit**: Closes the script.

---

## Changelog

**v2.2 (2025-08-26)** - Implement backup count and latest backup timestamp display in the Last Epoch save manager's main menu. Clarify instructions in the game launch section for better user guidance.

**v2.1 (2025-08-25)** - ***FIRST COMMIT TO GITHUB*** This update added a "Backup Only" option for more flexibility and improved the menu flow. It also fixed critical bugs related to locale-specific timestamps and special character handling in the menu display, making the script significantly more robust.

**v2.0 (2025-08-24)** - This major version introduced a true timestamped backup system to prevent overwriting old saves and a multi-option menu for better control. It also modernized the script by replacing `xcopy` with the more reliable `robocopy`, improved the save restore logic, and centralized configuration paths for easier setup.

**v1.0 (2025-08-23)**- This was the initial draft written with Gemini-2.5-flash, providing basic functionality to rename the save folder before launching the game and restore it afterward.

---

## Troubleshooting

- **"The system cannot find the path specified."**: This almost always means one of the paths in the **Configuration** section is incorrect. Double-check them carefully.
- **"Backup failed! Robocopy returned errorlevel..."**: This can indicate a permissions issue. Try running the script as an Administrator (right-click -> "Run as administrator").
- **"No backups were found"**: This means the `Backups` folder is empty. You must run the backup process at least once to be able to restore.

## TO DO LIST

- [X] Make script history persist even after moving into a next stage
- [X] Show numbers of backups and last back up datetime on launch
- [ ] Let user choose which version to restore instead of forcing to restore the latest
- [ ] An option to delete older backups
