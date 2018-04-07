@echo off
setlocal

SET PROJECT=%~dp0speck.hxproj

call open_IDE.bat "%PROJECT%"
endlocal & EXIT /b %ERRORLEVEL%
