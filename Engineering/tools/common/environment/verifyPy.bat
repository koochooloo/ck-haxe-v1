ECHO OFF
::verify python is installed
ECHO verifying Python install...
python --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 SET PATH=C:\Python27;%PATH%
python --version >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
   ECHO Python not found.
   EXIT /b 1
) ELSE (
ECHO Python found...
)
