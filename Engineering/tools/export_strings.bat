@echo off

set MAINTAINER=danielle@1stplayable.com

:: Assumes we're running this from Engineering/tools
cd /d %~dp0
cd ..\

set ENG=%CD%
set TOOLS_DIR=%ENG%\tools
set STX_DIR=%TOOLS_DIR%\common\SpreadsheetToXml


set STRINGS_LOG_FILE=%ENG%\lib\strings\StringsExportLog.txt
set STRINGS_INPUT_FILE=%TOOLS_DIR%\StxConfig_Strings.txt

set QUESTION_DATABASE_LOG_FILE=%ENG%\lib\strings\QuestionDatabaseExportLog.txt
set QUESTION_DATABASE_INPUT_FILE=%TOOLS_DIR%\StxConfig_QuestionDatabase.txt


echo Exporting gamestrings...
echo Starting SpreadsheetToXML, please wait!
echo (your browser may open to authenticate; please click allow)

pushd "%STX_DIR%"
python SpreadsheetToXML.py "%STRINGS_LOG_FILE%" "%STRINGS_INPUT_FILE%"
python SpreadsheetToXML.py "%QUESTION_DATABASE_LOG_FILE%" "%QUESTION_DATABASE_INPUT_FILE%"
popd

echo.
echo.
echo SpreadsheetToXML complete! Log stored at "%LOG_FILE%"
echo See "%MAINTAINER%" if you think something went wrong.
echo.


pause
