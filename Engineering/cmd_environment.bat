@echo off
setlocal

pushd %~dp0
IF %ERRORLEVEL% NEQ 0 endlocal & EXIT /b %ERRORLEVEL%

call %~dp0tools\env.bat
IF %ERRORLEVEL% NEQ 0 popd & endlocal & EXIT /b %ERRORLEVEL%

cmd
popd & endlocal & EXIT /b %ERRORLEVEL%