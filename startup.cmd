@echo off
setlocal

REM Get the directory of the currently running script
set SCRIPT_DIR=%~dp0

REM Create message.txt and write "I'm a message" to it
echo I'm a message > "%SCRIPT_DIR%message.txt"

REM Copy config_basic to config.ini
copy "%SCRIPT_DIR%config_basic.ini" "%SCRIPT_DIR%config.ini"

REM Create a logs directory
mkdir "%SCRIPT_DIR%logs"

echo Files created and logs directory made in %SCRIPT_DIR%
