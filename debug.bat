@echo off
set APP_PATH=%~dp0
set TCLLIBPATH={%APP_PATH%common} {%APP_PATH%lib} {%APP_PATH%util} %TCLLIBPATH%
set LOG_LEVEL=DEBUG
set LOG_PATH=%APP_PATH%debug.log
start "DEBUG" cmd
