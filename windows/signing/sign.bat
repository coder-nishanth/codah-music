@echo off
setlocal

set "SIGNTOOL=C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"
set "PFX=%~dp0codah-music.pfx"
set "PASSWORD=codahmusic2026"
set "RELEASE_DIR=%~dp0..\..\..\build\windows\x64\runner\Release"

echo Signing all executables in %RELEASE_DIR%...

for %%f in ("%RELEASE_DIR%\*.exe") do (
    echo Signing %%f...
    "%SIGNTOOL%" sign /f "%PFX%" /p %PASSWORD% /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 "%%f"
)

echo Done!
pause
