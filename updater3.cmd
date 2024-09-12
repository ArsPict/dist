@echo off
REM Set the service name and repo path
SET SERVICE_NAME=watcher
SET REPO_PATH=C:\users\arsenii\up_t\dist
SET UPDIGNORE_FILE=%REPO_PATH%\updignore.txt

REM Variable to track if the service was running initially
SET SERVICE_WAS_RUNNING=0

REM Check if the service is running
echo Checking if the service %SERVICE_NAME% is running...
sc query %SERVICE_NAME% | find "RUNNING"
IF ERRORLEVEL 1 (
    echo Service %SERVICE_NAME% is not running, continuing...
) ELSE (
    echo Stopping service: %SERVICE_NAME%
    REM Stop the service
    sc stop %SERVICE_NAME%
    IF ERRORLEVEL 0 (
        SET SERVICE_WAS_RUNNING=1
        echo Service stopped.
    ) ELSE (
        echo Failed to stop the service.
    )
)

REM Change to the repository directory
cd /d %REPO_PATH%
IF ERRORLEVEL 1 (
    echo Failed to change directory to %REPO_PATH%.
    goto :end
)

REM Check if updignore.txt exists
IF NOT EXIST "%UPDIGNORE_FILE%" (
    echo updignore.txt file not found!
    goto :end
)

REM Generate the list of ignored files from updignore.txt
echo Extracting files from updignore.txt...
SETLOCAL EnableDelayedExpansion
SET FILES_TO_PROTECT=
FOR /F "usebackq delims=" %%i IN ("%UPDIGNORE_FILE%") DO (
    REM Skip comments and empty lines
    IF NOT "%%i"=="" IF NOT "%%i"=="#" (
        REM Check if the file exists in the repo
        IF EXIST "%%i" (
            echo File %%i exists and will be stashed.
            SET FILES_TO_PROTECT=!FILES_TO_PROTECT! %%i
        ) ELSE (
            echo Warning: File %%i does not exist in the repo, skipping...
        )
    )
)

REM Check if there are files to protect
IF "%FILES_TO_PROTECT%"=="" (
    echo No valid files to protect found in updignore.txt.
) ELSE (
    REM Attempt to stash the files listed in updignore.txt
    echo Stashing files listed in updignore.txt: %FILES_TO_PROTECT%
    git stash push -m "Stash updignore.txt files" %FILES_TO_PROTECT%
    IF ERRORLEVEL 1 (
        echo Warning: Failed to stash some files, continuing with reset...
    )
)

echo Fetching latest changes from remote...
REM Fetch the latest updates from the remote and reset the local repo
git fetch
IF ERRORLEVEL 1 (
    echo Failed to fetch from remote.
    goto :end
)

echo Resetting local repository to match remote...
git reset --hard origin/main
IF ERRORLEVEL 1 (
    echo Failed to reset the repository.
    goto :end
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

:end
REM Always attempt to restart the service
IF "%SERVICE_WAS_RUNNING%"=="1" (
    echo Starting service: %SERVICE_NAME%
    sc start %SERVICE_NAME%
    IF ERRORLEVEL 1 (
        echo Failed to start the service.
    ) ELSE (
        echo Service started successfully.
    )
) ELSE (
    echo The service was not running before, no need to start it.
)

ENDLOCAL
