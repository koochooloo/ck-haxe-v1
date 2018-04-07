@IF NOT DEFINED IS_AUTOBUILD SET IS_AUTOBUILD=0
@IF %IS_AUTOBUILD% EQU 0 echo off
SET PROJECT_DIR=%1
:: optional args if SUPPRESS_RUN_LIME_BUILD is defined
SET OUTPUT_FILE=%2
SET TARGET_BUILD=%3
SET BUILD_CONFIG=%4

:: Common environment, but trust HAXEPATH, NEKO_INSTPATH, PATH, etc from IDE
SET PRE_BUILD_ENV=1
call %~dp0env.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:: Lime version
"%HAXEPATH%/haxelib.exe" set lime 5.7.1
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:: Version stamp
call "%PROJECT_DIR%/tools/setVersionInfo.bat" "%PROJECT_DIR%/assets/data/version.txt" 
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:: Lime build (but not for autobuild)
IF NOT DEFINED SUPPRESS_RUN_LIME_BUILD "%HAXEPATH%/haxelib.exe" run lime build "%OUTPUT_FILE%" %TARGET_BUILD% -%BUILD_CONFIG% -Dfdb
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
