@echo off
set APP_PATH=%~dp0
set SPIRENT_TESTCENTER_INSTALL_DIR=C:\Program Files (x86)\Spirent Communications\Spirent TestCenter 4.50\Spirent TestCenter Application
set WIRESHARK_INSTALL_DIR=C:\Program Files\Wireshark

set TCLLIBPATH={%APP_PATH%common} {%APP_PATH%lib} {%APP_PATH%util} {%SPIRENT_TESTCENTER_INSTALL_DIR%}
set Path=%Path%;%WIRESHARK_INSTALL_DIR%

set LOG_LEVEL=DEBUG
set LOG_PATH=%APP_PATH%debug.log

start "DEBUG" cmd
