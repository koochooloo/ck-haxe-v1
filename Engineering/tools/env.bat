@IF NOT DEFINED IS_AUTOBUILD SET IS_AUTOBUILD=0
@IF %IS_AUTOBUILD% EQU 0 echo off

SET LOCAL_TOOLS_DIR=%~dp0

:: Do not set these if we're coming directly from IDE.
:: This allows them to be temporarily overriden there.
IF NOT DEFINED PRE_BUILD_ENV SET HAXETOOLKIT_PATH=%LOCAL_TOOLS_DIR%environment\HaxeToolkit
IF NOT DEFINED PRE_BUILD_ENV SET HAXEPATH=%HAXETOOLKIT_PATH%\haxe\
IF NOT DEFINED PRE_BUILD_ENV SET NEKO_INSTPATH=%HAXETOOLKIT_PATH%\neko
IF NOT DEFINED PRE_BUILD_ENV SET PATH=%HAXETOOLKIT_PATH%\haxe;%HAXETOOLKIT_PATH%\neko;%PATH%

IF NOT DEFINED JAVA_HOME SET JAVA_HOME=%ProgramFiles%\Java\jdk1.8.0_101
IF NOT EXIST "%JAVA_HOME%" echo %JAVA_HOME% not found, please install JDK 8u101
echo JAVA_HOME: %JAVA_HOME%

SET ANDROID_SDK_HOME=%LOCAL_TOOLS_DIR%environment\android-sdk
SET ANDROID_NDK_HOME=%LOCAL_TOOLS_DIR%environment\android-ndk

IF EXIST "%ANDROID_SDK_HOME%" goto :sdk_ok
echo %ANDROID_SDK_HOME% not found ...
SET ANDROID_SDK_HOME=%HOMEDRIVE%\android-variants\speck\sdk
echo Fallback to %ANDROID_SDK_HOME% ...
IF NOT EXIST "%ANDROID_SDK_HOME%" echo WARNING - android-sdk not found. 1>&2 
:sdk_ok
	
IF EXIST "%ANDROID_NDK_HOME%" goto :ndk_ok
echo %ANDROID_NDK_HOME% not found ...
SET ANDROID_NDK_HOME=%HOMEDRIVE%\android-variants\speck\ndk
echo Fallback to %ANDROID_NDK_HOME% ...
IF NOT EXIST "%ANDROID_NDK_HOME%" echo WARNING - android-ndk not found 1>&2
:ndk_ok

echo Android SDK: %ANDROID_SDK_HOME%
echo Android NDK: %ANDROID_NDK_HOME%

SET PATH=%ANDROID_NDK_HOME%;%ANDROID_SDK_HOME%\tools;%ANDROID_SDK_HOME%\platform-tools;%PATH%

SET LIME_CONFIG=%LOCAL_TOOLS_DIR%lime_config.xml
SET HXCPP_CONFIG=%LOCAL_TOOLS_DIR%.hxcpp_config.xml

SET ANDROID_NDK_ROOT=%ANDROID_NDK_HOME%
SET ANDROID_SDK=%ANDROID_SDK_HOME%

:: These two are likely legacy, but putting here based on generated %USERPROFILE%\.hxcpp_config.xml
SET SDK_ROOT=%LOCAL_TOOLS_DIR%environment
SET ANDROID_NDK_DIR=%LOCAL_TOOLS_DIR%environment

"%HAXEPATH%\haxelib.exe" setup "%HAXEPATH%\lib"
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%