SET PROJECT_FOLDER=fa22-capstone-2022-23-t11.svn
SET PROJECT_NAME=D7ragon
Set U_VERSION=UE_5.1

echo %PROJECT_FOLDER%
echo %PROJECT_NAME%
echo %U_VERSION%

cd C:\%PROJECT_FOLDER%

call :StartTimer

svn cleanup 
svn update --depth infinity -q

if NOT "%ERRORLEVEL%"=="0" EXIT /B %ERRORLEVEL%

call :StopTimer
call :DisplayTimerResult

cd %WORKSPACE%

cd fa22-capstone-2022-23-t11-build-commands

Call Generate.bat
if NOT "%ERRORLEVEL%"=="0" EXIT /B %ERRORLEVEL%

cmd /c call CompileEditor.bat
if NOT "%ERRORLEVEL%"=="0" EXIT /B %ERRORLEVEL%

cmd /c call CompileGame.bat
if NOT "%ERRORLEVEL%"=="0" EXIT /B %ERRORLEVEL%

Rem Call Build.bat
cmd /c call Build.bat
if NOT "%ERRORLEVEL%"=="0" EXIT /B %ERRORLEVEL%

cd C:\Build

Rem Archive
ren windows Stuffed%BUILD_NUMBER%
powershell Compress-Archive Stuffed%BUILD_NUMBER%\%WORKSPACE%\buildv%BUILD_NUMBER%.zip

cd %WORKSPACE%

Rem check file size
FOR /F "usebackq" %%A IN ('"buildv%BUILD_NUMBER%.zip"') DO set size=%%~zA
if %size% LSS 1000 (
    EXIT /B 1
)

Rem Copy
powershell Copy-Item %WORKSPACE%\buildv%BUILD_NUMBER%.zip -Destination %WORKSPACE%\build-latest.zip
EXIT /B %ERRORLEVEL%

EXIT /B 0

:StartTimer
:: Store start time
set StartTIME=%TIME%
for /f "usebackq tokens=1-4 delims=:., " %%f in (`echo %StartTIME: =0%`) do set /a Start100S=1%%f*360000+1%%g*6000+1%%h*100+1%%i-36610100
goto :EOF

:StopTimer
:: Get the end time
set StopTIME=%TIME%
for /f "usebackq tokens=1-4 delims=:., " %%f in (`echo %StopTIME: =0%`) do set /a Stop100S=1%%f*360000+1%%g*6000+1%%h*100+1%%i-36610100
:: Test midnight rollover. If so, add 1 day=8640000 1/100ths secs
if %Stop100S% LSS %Start100S% set /a Stop100S+=8640000
set /a TookTime=%Stop100S%-%Start100S%
set TookTimePadded=0%TookTime%
goto :EOF

:DisplayTimerResult
:: Show timer start/stop/delta
echo Started: %StartTime%
echo Stopped: %StopTime%
echo Elapsed: %TookTime:~0,-2%.%TookTimePadded:~-2% seconds
goto :EOF
