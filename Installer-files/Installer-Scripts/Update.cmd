
@echo off
color 0C
@C:\Windows\System32\chcp 28591 > nul
@C:\Windows\System32\mode con cols=105 lines=35
@Title Start as Admin 
:: Checking for admin rights
::------------------------------------------
REM --> Checking Permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> Error: No admistrative privlages
if '%errorlevel%' NEQ '0' (
REM --> Checking administrative privileges
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
@echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"="
echo UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
@cls
GOTO continue

:continue
@Title Auto Update Initializer
cls
echo Cleaning up files
del "..\..\..\Installer-Scripts\*.txt" 2>nul
del "..\..\..\Installer-Scripts\*.bat" 2>nul
del "..\..\..\Installer-Scripts\*.json" 2>nul
del "..\..\..\Installer-Scripts\*.dll" 2>nul
del "..\..\..\Installer-Scripts\*.exe" 2>nul
del "..\..\..\Installer-Scripts\*.pdb" 2>nul
del "..\..\..\*.rar" 2>nul
del "..\..\..\..\*.txt" 2>nul
rmdir /S /Q "..\..\..\..\.git" 2>nul

echo Re-launching the Installer Script
cd /d "%~dp0"
cd /d "..\..\..\..\"
XCOPY ".\Installer-files\Nifer Installer Script" "%~dp0..\..\..\..\" /s /Y
Start "" "Installer Script by Nifer.cmd"
rmdir /S /Q ".\Installer-files\Nifer Installer Script" 2>nul & exit
if errorlevel 1 exit
@exit