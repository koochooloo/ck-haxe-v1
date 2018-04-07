@echo off

set MAINTAINER=james@1stplayable.com

:: Assumes we're running this from Engineering/tools
cd /d %~dp0
cd ..\

set ENG=%CD%
set TOOLS_DIR=%ENG%\tools
set IMAGE_DOWNLOADER_DIR=%TOOLS_DIR%\drive_file_downloader


set LOG_FILE=%TOOLS_DIR%\drive_file_downloader_log.txt
set IMAGE_CONFIG_FILE=%TOOLS_DIR%\drive_image_downloader_config.json
set AUDIO_CONFIG_FILE=%TOOLS_DIR%\drive_audio_downloader_config.json

echo Downloading images, please wait!
echo (your browser may open to authenticate; please click allow)

pushd "%IMAGE_DOWNLOADER_DIR%"
python DriveFileDownloader.py "%LOG_FILE%" "%IMAGE_CONFIG_FILE%"
python DriveFileDownloader.py "%LOG_FILE%" "%AUDIO_CONFIG_FILE%"
popd

echo.
echo.
echo drive_file_downloader complete! Log stored at "%LOG_FILE%"
echo See "%MAINTAINER%" if you think something went wrong.
echo.

pause
