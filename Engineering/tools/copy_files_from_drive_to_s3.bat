@echo off

set MAINTAINER=krispivin@1stplayable.com

:: Assumes we're running this from Engineering/tools
cd /d %~dp0
cd ..\

set ENG=%CD%
set TOOLS_DIR=%ENG%\tools
set IMAGE_DOWNLOADER_DIR=%TOOLS_DIR%\drive_file_downloader


set LOG_FILE=%TOOLS_DIR%\drive_s3_copy_log.txt
set IMAGE_CONFIG_FILE=%TOOLS_DIR%\drive_s3_copy_image_config.json
set AUDIO_CONFIG_FILE=%TOOLS_DIR%\drive_s3_copy_audio_config.json

echo.
echo Downloading files, please wait!
echo (your browser may open to authenticate; please click allow)

pushd "%IMAGE_DOWNLOADER_DIR%"
python DriveFileDownloader.py "%LOG_FILE%" "%IMAGE_CONFIG_FILE%"
python DriveFileDownloader.py "%LOG_FILE%" "%AUDIO_CONFIG_FILE%"
popd

echo.
echo.
echo File download complete! Log stored at "%LOG_FILE%"
echo See "%MAINTAINER%" if you think something went wrong.
echo.

set S3_COPY_DIR="%TOOLS_DIR%"\drive_s3_copy

echo.
echo Uploading files to S3...

pushd "%S3_COPY_DIR%"
python UploadToS3.py
popd

echo.
echo Done!
echo.

pause
