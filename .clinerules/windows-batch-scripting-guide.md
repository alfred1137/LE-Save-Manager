---
description: A guide to common pitfalls and best practices for writing robust Windows Batch scripts, specifically for the LE Save Manager project.
author: Cline
version: 1.0
tags: ["batch-scripting", "windows", "cmd", "best-practices"]
globs: ["**/*.cmd", "**/*.bat"]
---

# Windows Batch Scripting Guide for LE Save Manager

This document outlines critical best practices and common pitfalls discovered during the development of the `Last Epoch.cmd` script. Adhering to these guidelines is essential for maintaining and extending the script's functionality reliably.

## 1. Handling Special Characters in `echo` Commands

The Windows Command Prompt interpreter (`cmd.exe`) treats several characters as special operators for redirection, command chaining, and grouping. When using the `echo` command to display text, these characters **must be escaped** with a caret (`^`) to be treated as literal text.

### Critical Characters to Escape:

-   **Ampersand (`&`)**: Used to separate multiple commands on one line.
    -   **Incorrect**: `echo   [4] Open Saves & Backups Folder`
    -   **Correct**: `echo   [4] Open Saves ^& Backups Folder`

-   **Parentheses (`(` and `)`)**: Used to group commands.
    -   **Incorrect**: `echo   [1] Full Process (Backup / Launch / Restore)`
    -   **Correct**: `echo   [1] Full Process ^(Backup / Launch / Restore^)`

-   **Redirection Symbols (`>` and `<`)**: Used to redirect command output or input. These are particularly tricky, especially inside parentheses.
    -   **Problematic**: `echo   [1] Full Process ^(Backup -> Launch -> Restore^)`
    -   **Best Practice**: Avoid using redirection symbols in echoed text whenever possible. Replace them with safe alternatives like `/` or `|`. If you must use them, they need to be escaped (e.g., `^>`), but this can still be unreliable inside other escaped characters like parentheses.

## 2. Reliable Timestamp Generation

**NEVER** rely on the `%date%` and `%time%` variables for generating timestamps. Their format is entirely dependent on the user's Windows regional settings, which leads to inconsistent and incorrect parsing.

### The Correct Method: `wmic`

The **Windows Management Instrumentation Command-line (`wmic`)** tool provides a locale-independent way to retrieve date and time components in a structured format.

**Implementation Pattern:**

```batch
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
```
This pattern is robust and should be used for all timestamping needs.

## 3. Counting Files and Directories Reliably

Avoid parsing the output of the `dir` command, as its output format can change based on user locale. The most reliable method is to use a `for` loop with a counter variable.

**Implementation Pattern (Counting Directories):**
```batch
set "count=0"
for /d %%d in ("C:\Path\To\Your\Directory\*") do (
    set /a count+=1
)
echo Total directories found: %count%
```
- Use `for /d` to iterate over directories.
- Use `for` (without `/d`) to iterate over files.

## 4. String Manipulation and Substrings

Batch scripting supports extracting substrings from variables, which is extremely useful for parsing structured strings like timestamps.

**Syntax:** `%VARIABLE:~start,length%`
- `start`: The zero-based starting index.
- `length`: The number of characters to extract.

**Implementation Pattern (Parsing a Timestamp):**
This example parses a timestamp from a string in the format `YYYY-MM-DD_HH-MIN-SS`.

```batch
set "TIMESTAMP_STRING=2025-08-25_11-51-29"

REM Extract the date part (10 characters from the start)
set "DATE_PART=%TIMESTAMP_STRING:~0,10%"

REM Extract the time part, replacing hyphens with colons
set "TIME_PART=%TIMESTAMP_STRING:~11,2%:%TIMESTAMP_STRING:~14,2%:%TIMESTAMP_STRING:~17,2%"

echo Original: %TIMESTAMP_STRING%
echo Date: %DATE_PART%
echo Time: %TIME_PART%
```

## 5. General Best Practices

-   **Use `setlocal`**: Always start scripts with `@echo off` and `setlocal`. This prevents variables from leaking into the user's global command prompt environment.
-   **Use `robocopy` for File/Directory Operations**: `robocopy` is the modern, reliable replacement for `xcopy` and `copy`. It has better error handling, retry logic, and is more resilient.
-   **Modular Code with Labels and `call`**: For complex scripts, break logic into subroutines using labels (e.g., `:backup_saves`). Use `call :subroutine_name` to execute them and `goto :eof` to return from them. This makes the code much easier to read and maintain.
-   **Check for Existence**: Before acting on a file or directory, check if it exists using `if exist "%FILE_PATH%" (...)`. This prevents errors and allows for more graceful handling of different states.
