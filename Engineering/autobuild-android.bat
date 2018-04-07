::
:: Copyright (C) 2015, 1st Playable Productions, LLC. All rights reserved.
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
IF %IS_AUTOBUILD% NEQ 0 SET PAUSE_ERRORS=0
IF NOT DEFINED PAUSE_ERRORS SET PAUSE_ERRORS=1

setlocal EnableDelayedExpansion


::
:: Environment
::

SET MAINTAINER=Danielle, Kris, Leander

call %~dp0\tools\env.bat
IF %ERRORLEVEL% NEQ 0 goto errorhandler

:: working directory
IF NOT DEFINED WORKSPACE (
	cd /d %~dp0
)
:: environment is evaluated on entry to ()
:: so we need to do the above cd separately
:: to get the results in %CD%
IF NOT DEFINED WORKSPACE SET ENG=%CD%
IF NOT DEFINED WORKSPACE SET WORKSPACE=%CD%

IF NOT DEFINED ENG SET ENG=%WORKSPACE%\Engineering

echo Workspace is: %WORKSPACE%
echo Engineering dir is: %ENG%

SET hxver=3.4.2
SET target=android
SET proj=speck
SET oflsrc=%ENG%\project.xml
SET WEB_FOLDER=\\bastion\demos\%proj%

ECHO.
ECHO The currently set haxelib versions are:
haxelib list
ECHO.

SET data_make=%ENG%\lib\data_make_lite.bat
SET BLD_TMP_LOCAL=build_tmp
SET BLD_TMP=%ENG%\%BLD_TMP_LOCAL%
IF %IS_AUTOBUILD% NEQ 0 SET ARCHIVE_PATH=%WORKSPACE%\%JOB_NAME%_%BUILD_NUMBER%_rev%SVN_REVISION%.zip
IF NOT DEFINED ARCHIVE_PATH SET ARCHIVE_PATH=%WORKSPACE%\%proj%_local.zip

::
:: Global Clean - final build outputs
::

FOR %%G IN (%ENG%\bin %BLD_TMP%) DO (
	ECHO Cleaning %%G...
	IF EXIST %%G rd /S /Q "%%G"
	IF !ERRORLEVEL! NEQ 0 goto errorhandler
)

::TODO GIZMO:: Clean data make results, delete and ignore them in svn
FOR %%G IN (%WORKSPACE%\*.zip %WORKSPACE%\*.log ^
 %WORKSPACE%\lib\data\CustomTunablesValues.json ^ 
 %WORKSPACE%\lib\data\DefaultTunablesSearch.json ^
 %WORKSPACE%\lib\*log.txt ^
 %WORKSPACE%\assets\data\version.txt ^
 %WORKSPACE%\src\assets\JsonAssets.hx ^
 %WORKSPACE%\src\assets\PaistManifest.hx ^
 %WORKSPACE%\src\assets\ResourceMap.hx ^
 %WORKSPACE%\src\assets\SoundLib.hx ) DO (
	ECHO Cleaning %%G...
	IF EXIST %%G del /F /Q "%%G"
	IF !ERRORLEVEL! NEQ 0 goto errorhandler
)

svn st --no-ignore "%ENG%"
::exit /b 0 :: uncomment me to test clean after one autobuild

SET AUTOBUILD_READY_FOR_ARCHIVE=1


::
:: Build
::

ECHO Making data...
ECHO.
call "%data_make%"
IF %ERRORLEVEL% NEQ 0 goto errorhandler
ECHO Data make completed successfully (as far as I can tell)!


pushd %ENG%
IF %ERRORLEVEL% NEQ 0 GOTO errorhandler

set SUPPRESS_RUN_LIME_BUILD=1
call "%ENG%\tools\preBuildCommand.bat" %ENG%
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET oflconfig=debug
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET oflconfig=release
SET ofldef=build_cheats
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET oflconfig=final
SET ofldef=build_shipping
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

call :copy_to_web_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

popd

::TODO docs?
::TODO lint

::                                                ::
:: DO NOT CALL goto errorhandler AFTER THIS POINT ::
::                                                ::

set DELAYED_ERRORLEVEL=0

::
:: Archive
::

ECHO.
ECHO Archiving...
ECHO (this may take a minute)
ECHO.

call :archive_sub
IF %ERRORLEVEL% NEQ 0 SET DELAYED_ERRORLEVEL=%ERRORLEVEL%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:success
IF %IS_AUTOBUILD% EQU 0 PAUSE
endlocal & EXIT /b %DELAYED_ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:errorhandler
SET MYERRORLEVEL=%ERRORLEVEL%
ECHO There was an error.  Errorlevel %MYERRORLEVEL%.
ECHO See %MAINTAINER%.
ECHO.

:: make sure we've cleaned up (since we may have come here before popd got called)
popd

IF NOT DEFINED AUTOBUILD_READY_FOR_ARCHIVE GOTO :skipcopy

ECHO Forcing copy for archival...
call :archive_sub
:: ignore errors
ECHO ...copy done.
ECHO.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:skipcopy

IF %PAUSE_ERRORS% NEQ 0 PAUSE
endlocal & EXIT /b %MYERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:archive_sub

:: TODO: break this at least into per-game archives, preferably also split by build type

pushd %ENG%
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

SET ARCHIVE_ERRORLEVEL=0

echo Zipping to %ARCHIVE_PATH%, output to 7z.log...
"%ENG%\tools\common\7-zip\7za" a -tzip -mx9 -- "%ARCHIVE_PATH%" "%BLD_TMP_LOCAL%\*" 1>7z.log
IF %ERRORLEVEL% NEQ 0 SET ARCHIVE_ERRORLEVEL=%ERRORLEVEL%

popd

exit /b %ARCHIVE_ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:test_sub

ECHO Testing ...
pushd %ENG%\tools\common\testing
:: TODO errorlevel handling

CALL run_tests.bat
set TEST_ERRORLEVEL=%ERRORLEVEL%

popd

exit /b %TEST_ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:build_sub

ECHO Building %oflconfig%...

SET use_ofldef=
IF DEFINED ofldef SET use_ofldef=-D%ofldef%

IF EXIST bin rd /s /q bin
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

"%HAXEPATH%\haxelib.exe" run openfl build "%oflsrc%" %target% -%oflconfig% -verbose -clean %use_ofldef%
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

SET BUILD_DIR=%BLD_TMP_LOCAL%\%oflconfig%
mkdir "%BUILD_DIR%"
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

IF NOT %target%==android xcopy /Y /S /E "%ENG%\bin\%target%\bin\*.*" "%BUILD_DIR%\" >NUL
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

IF %target%==android xcopy /Y "%ENG%\bin\%target%\bin\app\build\outputs\apk\*.apk" "%BUILD_DIR%\" >NUL
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

IF %target%==android xcopy /Y "%ENG%\bin\%target%\obj\*.so" "%BUILD_DIR%\" >NUL
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:copy_to_web_sub

IF %IS_AUTOBUILD% NEQ 0 (
	SET WEB_FOLDER=%WEB_FOLDER%\auto\android
) ELSE (
	SET WEB_FOLDER=%WEB_FOLDER%\local\%COMPUTERNAME%
)

ECHO Copying to internal website...
ECHO (This may take a minute)
:: Note robocopy errors are errorlevel 8 or higher.
ROBOCOPY "%BLD_TMP_LOCAL%" "%WEB_FOLDER%" /E /MIR /R:3 /W:10 /LOG:RCopy.log
IF %ERRORLEVEL% GEQ 8 exit /b %ERRORLEVEL%

exit /b 0
