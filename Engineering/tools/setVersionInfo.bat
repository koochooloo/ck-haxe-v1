:: Slightly clunky version stamping...

IF [%1] == [] (
	ECHO Target file not passed in
	EXIT /b 1
)

@SETLOCAL

IF NOT DEFINED SVN_REVISION FOR /F %%I IN ('svnversion') DO SET SVN_REVISION=%%I
ECHO Revision: %SVN_REVISION%> %1

IF NOT DEFINED BUILD_NUMBER SET BUILD_NUMBER=0
ECHO Build: %BUILD_NUMBER%>> %1
ECHO Machine: %COMPUTERNAME%>> %1

ENDLOCAL

