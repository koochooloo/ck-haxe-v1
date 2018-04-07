::
:: Copyright (C) 2014, 1st Playable Productions, LLC. All rights reserved.
::
:: UNPUBLISHED -- Rights reserved under the copyright laws of the United
:: States. Use of a copyright notice is precautionary only and does not
:: imply publication or disclosure.
::
:: THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
:: OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
:: DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
:: EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@SETLOCAL
@IF NOT DEFINED IS_AUTOBUILD SET IS_AUTOBUILD=0
@IF %IS_AUTOBUILD% EQU 0 echo off

::libraries ordered by priority
ECHO Installing basic dependent libraries...
ECHO.

call :installset haxelib_client 3.1.0-rc.4
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset hxtools 1.1.6
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset openfl 1.2.3
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset openfl-tools 1.0.10
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset openfl-compatibility 1.0.1
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset lime-tools 1.3.0
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset actuate 1.7.2
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset spritesheet 1.2.0
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset sqlite 1.0.9
IF %ERRORLEVEL% NEQ 0 GOTO :error

:success
ECHO.
ECHO DONE!
ECHO Your libraries:
haxelib list
ECHO.
IF %IS_AUTOBUILD% EQU 0 pause
endlocal & exit /b 0

:error
set MYERRORLEVEL=%ERRORLEVEL%
ECHO ------------------------------------------
ECHO ============== FAILURE ===================
ECHO ------------------------------------------
IF %IS_AUTOBUILD% EQU 0 pause
endlocal & exit /b %MYERRORLEVEL%

:installset
set MYERRORLEVEL=0
haxelib install "%1" "%2"
IF %ERRORLEVEL% NEQ 0 set MYERRORLEVEL=%ERRORLEVEL%
haxelib set "%1" "%2"
IF %ERRORLEVEL% NEQ 0 set MYERRORLEVEL=%ERRORLEVEL%
exit /b %MYERRORLEVEL%

