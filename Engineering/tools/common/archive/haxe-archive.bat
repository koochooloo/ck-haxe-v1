@echo off

:: NOTES:
:: - this is a stripped down version of what was used for Ouroboros phase 1 (which was built off of what was used for Hamm)
:: - See :: TOFILLIN for things that should be changed per project
:: - for reference on archiving multiple independent builds, see: https://svn.1stplayable.com/hamm/trunk/Engineering/archive.bat
::	-- Hamm had an android build on trunk, and an iOS build on a branch; its archive script handled both
:: - for reference on archiving multiple dependent projects, see: https://svn.1stplayable.com/ouroboros/branches/archive-phase1/Game/archive.bat
::	-- Ouroboros had a separate project outside of Engineering (VariableSelection) that was part of autobuild and needed to be taken into consideration

setlocal
setlocal EnableDelayedExpansion

IF NOT DEFINED PAUSE_ERRORS SET PAUSE_ERRORS=1

SET MAINTAINER=Jon

SET 7ZIP=%CD%\tools\common\7-zip\7za

set ARCHIVE_ROOT=C:\archive

:: TOFILLIN
:: Note these are all directories, to be deleted with rmdir
::TODO -update with proper tools for project -jm
set DELETE_BEFORE_BUILD=patches ^
src\com ^
openfl-readme.txt ^
autobuild.bat ^
autobuild-full.bat ^
lib\fonts
tools\common

:: TOFILLIN
:: Note these are files and wildcards, not directories
::TODO -update with proper files for project -jm
set DELETE_AFTER_BUILD=archive.bat


:: TOFILLIN
set ENG_SVN="https://svn.1stplayable.com/bartlett/trunk/Engineering"
:: TOFILLIN
set PROJECTNAME=bartlett
set BUILDPATH=%ARCHIVE_ROOT%\%PROJECTNAME%
call :ARCHIVE_SUBROUTINE

goto :success



:::::::::::::::::::::
:ARCHIVE_SUBROUTINE
:::::::::::::::::::::

echo.
echo Archiving %PROJECTNAME%.
echo.

::
:: Export the codebase
::
echo Removing old directory and (re-)exporting Engineering (this may take some time)...
IF EXIST "%BUILDPATH%" rmdir /s /q "%BUILDPATH%"
IF %ERRORLEVEL% NEQ 0 GOTO :error

:: Get Engineering
svn export --quiet "%ENG_SVN%" "%BUILDPATH%"
IF %ERRORLEVEL% NEQ 0 goto :error

echo Done exporting.
echo.

pushd "%BUILDPATH%"

::
:: Build hxlib
::

echo Building hxlib...

call :HXLIB_SUBROUTINE

echo ... done.


::
:: Delete unneeded files
::
echo Deleting unneeded files...
for %%G in (%DELETE_BEFORE_BUILD%) DO (
   echo Cleaning %%G...
   if exist %%G rmdir /s /q "%%G"
   IF !ERRORLEVEL! NEQ 0 GOTO :error
)

echo Done deleting.
echo.


::
:: Autobuild
::
echo Autobuild (this may take a while)...
call autobuild.bat
IF %ERRORLEVEL% NEQ 0 GOTO :error
echo.
echo.
echo Done building.  Check for errors, look at bin directory outputs.
echo If there are errors, hit Ctrl-C to abort.  See %MAINTAINER% for help if needed.
echo.
pause

::
:: Delete intermediates
::

echo Deleting intermediate files...
for %%G in (%DELETE_AFTER_BUILD%) DO (
	ECHO Cleaning %%G...
	IF EXIST %%G del /F /Q %%G
	IF !ERRORLEVEL! NEQ 0 GOTO :error
)

echo Done.
echo.

::
:: Zip Archive
::
echo Zipping archive...
set ZIPFILE=%PROJECTNAME%-archive.zip
if exist "%ZIPFILE%" del /q %ZIPFILE%
IF %ERRORLEVEL% NEQ 0 goto :error
"%7ZIP%" a "%ZIPFILE%" "%PROJECTNAME%\"
IF %ERRORLEVEL% NEQ 0 goto :error
echo Done.
echo.

goto :success


:::::::::::::::::::::
:HXLIB_SUBROUTINE
:::::::::::::::::::::

:: TOFILLIN: check -source-path, -include-sources, each of the defines (these will likely be ok), and -optimize
:: taken from https://svn.1stplayable.com/aslib/trunk/autogen/gen-swcsrc.bat
:: paths are all relative to %BUILDPATH%
::-source-path, the source folder of the code to be converted to swc
::-include-sources, additional required source paths (libraries) needed
::-optimize -output, output swc file path

::TODO- update this subroutine for hxlib 8/7/14 -jm
"C:\Program Files (x86)\FlashDevelop\Tools\flexsdk\bin\compc" ^
-source-path "src" ^
-include-sources "src\aslib" ^
-define+=CONFIG::debug,false ^
-define+=CONFIG::release,true ^
-define+=CONFIG::timestamp,'$(TimeStamp)' ^
-define+=CONFIG::air,true ^
-define+=CONFIG::mobile,true ^
-define+=CONFIG::desktop,true ^
-external-library-path ${flexlib}/libs ${flexlib}/libs/air ${flexlib}/libs/mx ${flexlib}/locale/{locale} ${flexlib}/libs/player ^
-optimize -output "lib\swc\aslib.swc"



:success
if %PAUSE_ERRORS% NEQ 0 pause
popd
endlocal && EXIT /b 0



:error
SET MYERRORLEVEL=%ERRORLEVEL%
ECHO.
ECHO There was an error.  Errorlevel %MYERRORLEVEL%.
ECHO See %MAINTAINER%.
ECHO.
pause
popd
endlocal && EXIT /b %MYERRORLEVEL%
