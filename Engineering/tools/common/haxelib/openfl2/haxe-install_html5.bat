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
ECHO Installing additional html5 libraries...
ECHO.
call :installset openfl-bitfive 2.1.6
IF %ERRORLEVEL% NEQ 0 GOTO :error

call :installset jquery 1.2.1
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

