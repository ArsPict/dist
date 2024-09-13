@echo off
setlocal

REM Set the service name and the path to the repository
set "SERVICE_NAME=watcher"
set "REPO_PATH=C:\watcher\dist"

REM Step 1: Stop the Windows service using sc
echo Stopping service: %SERVICE_NAME%
sc stop "%SERVICE_NAME%" || echo Failed to stop the service, continuing...

REM Step 2: Change to the repository directory and reset to origin/main
echo Resetting Git repository to origin/main
cd /d "%REPO_PATH%"
git fetch origin || echo Failed to fetch updates, continuing...
git reset --hard origin/main || echo Failed to reset to origin/main, continuing...

REM Step 3: Start the Windows service again using sc
echo Starting service: %SERVICE_NAME%
sc start "%SERVICE_NAME%" || echo Failed to start the service.

REM Step 4: End
echo Script execution completed.
