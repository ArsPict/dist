@echo off
REM Set the service name and repo path
SET SERVICE_NAME=watcher
SET REPO_PATH=C:\users\arsenii\up_t\dist

REM Check if the service is running
echo suck my balls
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
