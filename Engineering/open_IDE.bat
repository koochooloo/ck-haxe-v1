@echo off
setlocal

call %~dp0tools/env.bat
IF %ERRORLEVEL% NEQ 0 endlocal & EXIT /b %ERRORLEVEL%

start "FlashDevelop" /d "%~dp0" "%~dp0tools\environment\FlashDevelop\FlashDevelop.exe" %1 %2 %3 %4 %5 %6 %7 %8 %9
endlocal & EXIT /b %ERRORLEVEL%
