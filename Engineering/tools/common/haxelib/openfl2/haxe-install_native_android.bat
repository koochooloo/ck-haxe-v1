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

ECHO Setting up android...
ECHO.

call :installset androidhx 0.1.0
IF %ERRORLEVEL% NEQ 0 GOTO :error

::lime setup
lime setup android
IF %ERRORLEVEL% NEQ 0 GOTO :error

::android sdk manager is invoked automatically by above

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

