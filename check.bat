Rem check file size
FOR /F "usebackq" %%A IN ('"Data\Builds.zip"') DO set size=%%~zA
if %size% LSS 1000 (
    EXIT /B 1
)