@echo off
REM Set the files or directories you want to protect (space-separated)
SET FILES_TO_PROTECT="config.ini last_modified"

REM Stash the files you want to protect
echo Stashing protected files: %FILES_TO_PROTECT%
git stash push -m "Stash protected files" %FILES_TO_PROTECT%
IF ERRORLEVEL 1 (
    echo Failed to stash files.
    exit /b 1
)

REM Perform the hard reset to sync with the remote
echo Performing git reset --hard...
git reset --hard origin/main
IF ERRORLEVEL 1 (
    echo Failed to reset the repository.
    exit /b 1
)

REM Apply the stash to restore the stashed files
echo Restoring stashed files...
git stash apply
IF ERRORLEVEL 1 (
    echo Failed to restore stashed files.
    exit /b 1
)

REM Drop the stash to clean up
echo Cleaning up the stash...
git stash drop
IF ERRORLEVEL 1 (
    echo Failed to drop the stash.
    exit /b 1
)

echo Update and restore completed successfully.
exit /b 0
