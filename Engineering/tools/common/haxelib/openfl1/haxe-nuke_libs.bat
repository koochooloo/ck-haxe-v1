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
@ECHO OFF
setlocal

::libraries ordered by alpha
ECHO Removing all dependent libraries...
ECHO.

IF NOT DEFINED HAXE_DIR SET HAXE_DIR=C:\HaxeToolkit\haxe\lib
IF EXIST "%HAXE_DIR%" RD /S /Q "%HAXE_DIR%"
IF %ERRORLEVEL% NEQ 0 GOTO :error

MD "%HAXE_DIR%"
IF %ERRORLEVEL% NEQ 0 GOTO :error

:success
ECHO.
ECHO DONE!
pause
endlocal & exit /b 0

:error
set MYERRORLEVEL=%ERRORLEVEL%
ECHO ------------------------------------------
ECHO ============== FAILURE ===================
ECHO ------------------------------------------
pause
endlocal & exit /b %MYERRORLEVEL%
