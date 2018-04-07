::Calls script to export png files into spritesheets
@setlocal
@IF NOT DEFINED IS_AUTOBUILD SET IS_AUTOBUILD=0
@IF %IS_AUTOBUILD% EQU 0 echo off

setlocal EnableDelayedExpansion

:: cd to ensure the batch starts in the batch file dir, since a lot of relative paths are used.
cd %~dp0 

set MAINTAINER=danielle@1stplayable.com

:: Allow us to skip this step, so that people without
:: TexturePacker installed can still make Paist and other data.
:: Run data_make_lite.bat to make use of this
IF NOT DEFINED MAKE_SPRITESHEETS SET MAKE_SPRITESHEETS=1

python --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 SET PATH=C:\Python27;%PATH%
python --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
   ECHO Python not found.
   EXIT /b 1
)

set SPRITE_SRC_PATH=.\2d
set ASSET_MANIFEST_FILE=.\AssetManifest.xls
set SPRITESHEET_DST_PATH=..\assets\2d
set TEMP_IMG_DIR=.\temp_images
set TEMP_LOG_PATH=.\TP-temp-log.txt
set PAIST_JSON_SRC_PATH=.\layouts
set PAIST_JSON_DST_PATH=..\assets\layouts
set HAXE_PAIST_MANIFEST_PATH=..\src\assets\PaistManifest.hx
set HAXE_VFX_MANIFEST_PATH=..\src\assets\VFXManifest.hx
set HAXE_RES_MAP_PATH=..\src\assets\ResourceMap.hx
set HAXE_JSONASSET_PATH=..\src\assets\JsonAssets.hx
set VFX_JSON_SRC_PATH=.\2d\vfx

set SOUND_LIST_HEADER_PATH=.\data\SoundLib.hx
set SOUND_LIST_FILE_PATH=..\src\assets\SoundLib.hx
set SOUND_FILE_ROOT=..\assets\sounds\
set SOUND_FILE_EXT=.ogg

set SCRIPT_ARGS="%ASSET_MANIFEST_FILE%" "%SPRITE_SRC_PATH%" "%SPRITESHEET_DST_PATH%" "%TEMP_IMG_DIR%" "%TEMP_LOG_PATH%" "%PAIST_JSON_SRC_PATH%" "%PAIST_JSON_DST_PATH%" "%HAXE_PAIST_MANIFEST_PATH%" "%HAXE_RES_MAP_PATH%" "%HAXE_VFX_MANIFEST_PATH%" "%VFX_JSON_SRC_PATH%"


IF %MAKE_SPRITESHEETS% EQU 1 (
	SET SCRIPT_ARGS=%SCRIPT_ARGS% -makeSpritesheets %MAKE_SPRITESHEETS%
	CALL :TexturePackerSub
)
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler


echo Starting MakeHaxeData...
:: Add "-v" or "-vv" (without quotes) below before %SCRIPT_ARGS% to increase verbosity.
python ../tools/common/spritesheet/MakeHaxeData.py %SCRIPT_ARGS%
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler


echo Writing %HAXE_JSONASSET_PATH%...
:: For hxcpp platforms, cannot currently use anonymous structures.
set JSONASSET_TO_STRING=1
python ../tools/common/bake_files/JsonToHaxe.py %HAXE_JSONASSET_PATH% %SPRITESHEET_DST_PATH% %PAIST_JSON_DST_PATH% %VFX_JSON_SRC_PATH%
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler


echo Fixing %HAXE_PAIST_MANIFEST_PATH% to support 4:3 and 16:9...
python ../tools/fixPaistManifest.py %SPRITESHEET_DST_PATH% %HAXE_PAIST_MANIFEST_PATH%
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler

echo Finding VFX files...
python ../tools/findVFX.py ../lib/2d/vfx/vfxlist.txt ../lib/2d/vfx
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler

echo Writing %SOUND_LIST_FILE_PATH%...
if exist %SOUND_LIST_FILE_PATH% del /F /Q %SOUND_LIST_FILE_PATH%
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler
copy %SOUND_LIST_HEADER_PATH% %SOUND_LIST_FILE_PATH% >Nul
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler
call :SoundLibSub %SOUND_FILE_ROOT%
echo 	]; >> %SOUND_LIST_FILE_PATH%
echo } >> %SOUND_LIST_FILE_PATH%
IF %ERRORLEVEL% NEQ 0 GOTO :errorhandler

goto :success


:TexturePackerSub
::verify TexturePacker is installed
:: TODO: verify version as well
::ECHO Verifying TexturePacker install...
TexturePacker --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 SET PATH=C:/Program Files/CodeAndWeb/TexturePacker/bin;%PATH%
TexturePacker --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
   ECHO TexturePacker not found.
   exit /b 1
) 

:: Recursively reads in sounds and builds the SoundLib.hx
:: TODO: Check errorlevel.
:SoundLibSub
set SOUND_DIR=%1

:: Using substring magic to extract the relative path of the sound files,
:: then substitute / for \, then strip the extension (last 4 chars)
FOR %%G IN (%SOUND_DIR%*%SOUND_FILE_EXT%) DO (
	SET snd=%%G
	SET snd=!snd:%SOUND_FILE_ROOT%=!
	SET snd=!snd:\=/!
	SET snd=!snd:~0,-4!
	ECHO			"!snd!", >> %SOUND_LIST_FILE_PATH%
)

for /D %%g in (%SOUND_DIR%*) do (
	call :SoundLibSub "%%g\"
)

exit /b 0

:: delete stale data
echo Deleting %SPRITESHEET_DST_PATH%...
if exist ".\%SPRITESHEET_DST_PATH%" RD /S /Q ".\%SPRITESHEET_DST_PATH%"
EXIT /b %ERRORLEVEL%

:success
echo.
echo Generation complete (success)!
echo.
IF %MAKE_SPRITESHEETS% NEQ 1 (
	ECHO You have skipped TexturePacker export!
	ECHO Any changes to lib/2d have been skipped.
	ECHO If this is not desired, run data_make.bat 
	ECHO instead of data_make_lite.bat; if you don't
	ECHO have TexturePacker installed, ask a friend 
	ECHO to datamake for you! 
	ECHO.
)
IF %IS_AUTOBUILD% EQU 0 pause
endlocal & EXIT /b 0



:errorhandler
SET MYERRORLEVEL=%ERRORLEVEL%
ECHO.
ECHO There was an error.  Errorlevel %MYERRORLEVEL%.
ECHO See %MAINTAINER%.
ECHO.
IF %IS_AUTOBUILD% EQU 0 pause
endlocal & EXIT /b %MYERRORLEVEL%