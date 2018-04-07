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
@IF DEFINED IS_AUTOBUILD GOTO :installAll
::skip pauses by making use of IS_AUTOBUILD
@IF NOT DEFINED IS_AUTOBUILD SET IS_AUTOBUILD=1
@ECHO OFF

ECHO installing all haxe libraries...
ECHO.
ECHO The final installation requires your attention (installing native android);
ECHO please see Jon or Leander if you are unsure what to do.
ECHO.
ECHO Will take around 5 minutes to get to the final installation process.
pause

:installAll
call haxe-install_default.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
call haxe-install_flash.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
call haxe-install_html5.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
call haxe-install_native.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
call haxe-install_native_android.bat
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
