@echo off

pushd ..\..\..

python tools/common/testing/FindAllTests.py tools/common/testing/TestSuite.hx test/TestSuite.hx test src/com/firstplayable/hxlib/test 
IF %ERRORLEVEL% NEQ 0 GOTO errorhandler

haxe test.hxml
IF %ERRORLEVEL% NEQ 0 GOTO errorhandler

haxelib run munit run -kill-browser
IF %ERRORLEVEL% NEQ 0 GOTO testerrorhandler

find /v "Tests FAILED" report/test/results.txt >nul
IF %ERRORLEVEL% NEQ 0 GOTO testerrorhandler

popd

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:success
ECHO .
ECHO Success! Unit tests passed!
endlocal & EXIT /b %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:testerrorhandler
SET MYERRORLEVEL=%ERRORLEVEL%
TYPE report\test\summary\js\summary.txt
ECHO.
ECHO Tests failed!
ECHO.

popd
endlocal & EXIT /b %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:errorhandler
SET MYERRORLEVEL=%ERRORLEVEL%

ECHO.
ECHO There was an error.  Errorlevel %MYERRORLEVEL%.
ECHO.

popd