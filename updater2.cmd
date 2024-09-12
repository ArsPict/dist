@echo off
REM Set the service name and repo path
SET SERVICE_NAME=watcher
SET REPO_PATH=C:\users\arsenii\up_t\dist
SET UPDIGNORE_FILE=%REPO_PATH%\.updignore

REM Check if the service is running
echo Checking if the service %SERVICE_NAME% is running...
sc query %SERVICE_NAME% | find "RUNNING"
IF ERRORLEVEL 1 (
    echo Service %SERVICE_NAME% is not running, continuing...
) ELSE (
    echo Stopping service: %SERVICE_NAME%
    REM Stop the service
    sc stop %SERVICE_NAME%
    IF ERRORLEVEL 1 (
        echo Failed to stop the service.
        exit /b 1
    )
    echo Service stopped.
)

REM Change to the repository directory
cd /d %REPO_PATH%
IF ERRORLEVEL 1 (
    echo Failed to change directory to %REPO_PATH%.
    exit /b 1
)

REM Check if .gitignore exists
IF NOT EXIST "%UPDIGNORE_FILE%" (
    echo .gitignore file not found!
    exit /b 1
)

REM Generate the list of ignored files from .gitignore
echo Extracting files from .gitignore...
SETLOCAL EnableDelayedExpansion
SET FILES_TO_PROTECT=
FOR /F "usebackq delims=" %%i IN ("%UPDIGNORE_FILE%") DO (
    REM Skip comments and empty lines
    IF NOT "%%i"=="" IF NOT "%%i"=="#" (
        SET FILES_TO_PROTECT=!FILES_TO_PROTECT! %%i
    )
)

REM Check if there are files to protect
IF "%FILES_TO_PROTECT%"=="" (
    echo No files to protect found in .gitignore.
) ELSE (
    REM Attempt to stash the files listed in .gitignore
    echo Stashing files listed in .gitignore: %FILES_TO_PROTECT%
    git stash push -m "Stash .gitignore files" %FILES_TO_PROTECT%
    IF ERRORLEVEL 1 (
        echo Warning: Failed to stash some files, continuing with reset...
    )
)

echo Fetching latest changes from remote...
REM Fetch the latest updates from the remote and reset the local repo
git fetch
IF ERRORLEVEL 1 (
    echo Failed to fetch from remote.
    exit /b 1
)

echo Resetting local repository to match remote...
git reset --hard origin/main
IF ERRORLEVEL 1 (
    echo Failed to reset the repository.
    exit /b 1
)

REM Apply the stash to restore the stashed files, ignoring errors
IF NOT "%FILES_TO_PROTECT%"=="" (
    echo Restoring stashed files...
    git stash apply
    IF ERRORLEVEL 1 (
        echo Warning: Failed to restore some stashed files, continuing...
    )
    REM Drop the stash to clean up, ignore errors if drop fails
    git stash drop
    IF ERRORLEVEL 1 (
        echo Warning: Failed to drop the stash, continuing...
    )
    echo Stashed files restored successfully.
)

echo Repository updated successfully.

REM Start the service if it was stopped
sc query %SERVICE_NAME% | find "RUNNING"
IF ERRORLEVEL 1 (
    echo Starting service: %SERVICE_NAME%
    sc start %SERVICE_NAME%
    IF ERRORLEVEL 1 (
        echo Failed to start the service.
        exit /b 1
    )
    echo Service started successfully.
) ELSE (
    echo Service is already running, no need to start.
)

ENDLOCAL
