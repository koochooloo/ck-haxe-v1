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

:: Compiler version
SET hxver=3.4.2
SET fdtarg=html5
SET proj=speck
SET WEB_FOLDER=\\bastion\demos\%proj%
SET closure=.\tools\common\closure\compiler.jar


call %~dp0\tools\env.bat
IF %ERRORLEVEL% NEQ 0 goto errorhandler

set SED=%~dp0\tools\common\gnuwin32\bin\sed.exe


ECHO.
ECHO The currently set haxelib versions are:
haxelib.exe list
ECHO.

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

SET fdbuild=%ENG%\tools\environment\FlashDevelop\Tools\fdbuild\fdbuild.exe
SET fdsrc=%ENG%\%proj%.hxproj
SET fdcomp=%ENG%\tools\environment\HaxeToolkit\haxe.exe
SET fdlib=%ENG%\tools\environment\FlashDevelop\Library
SET data_make=%ENG%\lib\data_make_lite.bat
SET BLD_TMP=%ENG%\build_tmp
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

::exit /b 0 :: uncomment me and do "svn st --no-ignore" to test clean after one autobuild

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

:: Gather what we can in case of a build failure.
"%fdbuild%" -V
:: ignore errorlevel, above returns exit code 1

"%fdbuild%" "%fdsrc%" -version "%hxver%" -compiler "%fdcomp%" -library "%fdlib%" -target "%fdtarg%"
IF %ERRORLEVEL% NEQ 0 goto errorhandler

ECHO.



:: Create a cheats build config file
:: Copy the release config file and append the cheats flag
COPY "%ENG%\bin\%fdtarg%\haxe\release.hxml" "%ENG%\bin\%fdtarg%\haxe\cheats.hxml" >NUL
IF %ERRORLEVEL% NEQ 0 goto errorhandler
ECHO. >> "%ENG%\bin\%fdtarg%\haxe\cheats.hxml" 
IF %ERRORLEVEL% NEQ 0 goto errorhandler
ECHO -D build_cheats >> "%ENG%\bin\%fdtarg%\haxe\cheats.hxml" 
IF %ERRORLEVEL% NEQ 0 goto errorhandler

:: Create a shipping build config file
:: Copy the release config file and append the shipping flag
COPY "%ENG%\bin\%fdtarg%\haxe\release.hxml" "%ENG%\bin\%fdtarg%\haxe\shipping.hxml" >NUL
IF %ERRORLEVEL% NEQ 0 goto errorhandler
ECHO. >> "%ENG%\bin\%fdtarg%\haxe\shipping.hxml" 
IF %ERRORLEVEL% NEQ 0 goto errorhandler
ECHO -D build_shipping >> "%ENG%\bin\%fdtarg%\haxe\shipping.hxml" 
IF %ERRORLEVEL% NEQ 0 goto errorhandler



SET fdconfig=debug
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET fdconfig=release
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET fdconfig=cheats
call :build_sub
IF %ERRORLEVEL% NEQ 0 goto errorhandler

SET fdconfig=shipping
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
"%ENG%\tools\common\7-zip\7za" a -tzip -mx9 -- "%ARCHIVE_PATH%" ".\build_tmp\*" 1>7z.log
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

ECHO Building %fdconfig%...

SET BUILD_DIR=build_tmp\%fdconfig%
mkdir "%BUILD_DIR%"
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

haxe.exe "%ENG%\bin\%fdtarg%\haxe\%fdconfig%.hxml"
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

xcopy /Y /S /E "%ENG%\bin\%fdtarg%\bin\*.*" "%BUILD_DIR%\" >NUL
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:: CMD If statements lack boolean operators.  Hoops, here we come!
SET minify=true
IF "%fdconfig%"=="debug" SET minify=false
IF "%fdconfig%"=="release" SET minify=false

IF NOT "%minify%"=="true" goto skipminify

ECHO Closure compiling %fdconfig%...
java -jar %closure% --js ".\%BUILD_DIR%\%proj%.js" --js_output_file ".\%BUILD_DIR%\%proj%.js" --warning_level QUIET
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:skipminify

echo Zipping js to %BUILD_DIR%\%proj%.js.gz ...
"%ENG%\tools\common\7-zip\7za" a -tgzip -mx9 ".\%BUILD_DIR%\%proj%.js.gz" ".\%BUILD_DIR%\%proj%.js"
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

::echo Removing uncompressed js %BUILD_DIR%\%proj%.js...
::del /f ".\%BUILD_DIR%\%proj%.js"
::IF %ERRORLEVEL% NEQ 0 GOTO errorhandler

::echo Changing index.html to point at %proj%.js.gz...
::"%SED%" -e "s/%proj%.js/%proj%.js.gz/" "%ENG%\assets\data\index.html" > "%BUILD_DIR%\index.html"
::IF %ERRORLEVEL% NEQ 0 GOTO errorhandler

:: speck doesn't have any shipping-specific index.html changes (yet).
::COPY /Y "assets\data\index_shipping.html" "%BUILD_DIR%\index.html"

:skipzip

exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:copy_to_web_sub

IF %IS_AUTOBUILD% NEQ 0 (
	SET WEB_FOLDER=%WEB_FOLDER%\auto\web
) ELSE (
	SET WEB_FOLDER=%WEB_FOLDER%\local\%COMPUTERNAME%
)

ECHO Copying to internal website...
ECHO (This may take a minute)
:: Note robocopy errors are errorlevel 8 or higher.
ROBOCOPY "build_tmp" "%WEB_FOLDER%" /E /MIR /R:3 /W:10 /LOG:RCopy.log
IF %ERRORLEVEL% GEQ 8 exit /b %ERRORLEVEL%

exit /b 0
