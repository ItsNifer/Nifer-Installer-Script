
@echo off
color 0C
@C:\Windows\System32\chcp 28591 > nul
@C:\Windows\System32\mode con cols=105 lines=35
@Title Start as Admin 
:: function for colored lines using ascii
@Echo Off & Setlocal DisableDelayedExpansion
::: { Creates variable /AE = Ascii-27 escape code.
::: - %/AE% can be used  with and without DelayedExpansion.
    For /F %%a in ('echo prompt $E ^| cmd')do set "/AE=%%a"
::: }

(Set \n=^^^
%=Newline DNR=%
)
::: / Color Print Macro -
::: Usage: %Print%{RRR;GGG;BBB}text to output
::: \n at the end of the string echo's a new line
::: valid range for RGB values: 0 - 255
  Set Print=For %%n in (1 2)Do If %%n==2 (%\n%
    For /F "Delims=" %%G in ("!Args!")Do (%\n%
      For /F "Tokens=1 Delims={}" %%i in ("%%G")Do Set "Output=%/AE%[0m%/AE%[38;2;%%im!Args:{%%~i}=!"%\n%
      ^< Nul set /P "=!Output:\n=!%/AE%[0m"%\n%
      If "!Output:~-2!"=="\n" (Echo/^&Endlocal)Else (Endlocal)%\n%
    )%\n%
  )Else Setlocal EnableDelayedExpansion ^& Set Args=
::: / Erase Macro -
::: Usage: %Erase%{string of the length to be erased}
  Set Erase=For %%n in (1 2)Do If %%n==2 (%\n%
    For /F "Tokens=1 Delims={}" %%G in ("!Args!")Do (%\n%
      Set "Nul=!Args:{%%G}=%%G!"%\n%
      For /L %%# in (0 1 100) Do (If Not "!Nul:~%%#,1!"=="" ^< Nul set /P "=%/AE%[D%/AE%[K")%\n%
    )%\n%
    Endlocal%\n%
  )Else Setlocal EnableDelayedExpansion ^& Set Args=
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
set wget="%~dp0Installer-files\Installer-Scripts\wget.exe"
@cls
GOTO initial-extract-check

:initial-extract-check
if not exist ".\Installer-files\" GOTO initial-extract-check-error
GOTO curl-check

:initial-extract-check-error
cls
color 0C
echo/                                                        
%Print%{231;72;86}             Error: Script contents not found. \n
%Print%{0;185;255}        Please ensure script contents are properly \n
%Print%{0;185;255}              extracted from it's zipped file. \n
%Print%{231;72;86}\n
%Print%{231;72;86}To extract files: Right click on "Nifer Installer Script.rar" and press "Extract files" \n
%Print%{231;72;86}   Choose a destination to extract the files to, or extract to the current directory. \n
%Print%{231;72;86}\n
%Print%{231;72;86}If you have WinRAR or 7zip installed, simply extract the zipped contents. \n
pause

:curl-check
:: checks system for curl. This is not needed for the latest windows versions... however if a user doesn't have curl for some reason, it will copy curl into system32 to work in env paths.
:: the curl.exe given apart of this download is from and signed by microsoft.
if not exist "C:\Windows\System32\curl.exe" xcopy "%~dp0Installer-files\Installer-Scripts\curl.exe" "C:\Windows\System32\curl.exe*" /I /Q /Y /F
GOTO set-variables

:set-variables
:: Sets variables used throughout the script.
set jrepl="%~dp0Installer-files\Installer-Scripts\jrepl.bat"
set mediafire="%~dp0Installer-files\Installer-Scripts\MediaFireDownloader.exe"
set wget="%~dp0Installer-files\Installer-Scripts\wget.exe"
set UnRAR="%~dp0Installer-files\Installer-Scripts\UnRAR.exe"
:: Get's current date and time to use later for any logging files (for any potential errors)
set _my_datetime=%date%_%time%
set _my_datetime=%_my_datetime: =_%
set _my_datetime=%_my_datetime::=%
set _my_datetime=%_my_datetime:/=_%
set _my_datetime=%_my_datetime:.=_%
:: Get's latest release tag from github repo, and compares with current version.
for /f "tokens=1,* delims=:" %%A in ('curl -kLs https://api.github.com/repos/itsnifer/Nifer-Installer-Script/releases/latest ^| find "tag_name"') do (set ScriptVersionGit=%%B)
set ScriptVersionGit=%ScriptVersionGit:",=%
set ScriptVersionGit=%ScriptVersionGit:"=%
set ScriptVersionGit=%ScriptVersionGit:v=%
set ScriptVersionGit=%ScriptVersionGit: =%
set ScriptVersion=v7.1.1
set ScriptVersion2=%ScriptVersion:v=%
set ScriptVersionDisplay=Version - %ScriptVersion2%
GOTO check-auto-up

:: 1=yes, 0=default, 2=no
:check-auto-up
if not exist ".\Installer-files\Installer-Scripts\Settings\auto-update*.txt" break>".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt"
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" GOTO check-auto-1
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" GOTO check-auto-0
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" GOTO check-auto-1
:check-auto-0
cls
color 0C
echo/                                                        
%Print%{231;72;86}             Auto Updating is Not Enabled. \n
%Print%{0;185;255}    Note: Auto Updating will only check for updates \n
%Print%{0;185;255}              when the script is running. \n
%Print%{231;72;86}\n
%Print%{231;72;86}            1) Enable Auto Updating \n
%Print%{231;72;86}\n
%Print%{231;72;86}            2) Disable Auto Updating \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what option you want." /N
IF ERRORLEVEL 2  REN ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" "auto-update-2.txt" 2>nul & GOTO Main
IF ERRORLEVEL 1  REN ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" "auto-update-1.txt" 2>nul & GOTO check-auto-1
:check-auto-1
if %ScriptVersion2% LSS %ScriptVersionGit% GOTO check-auto-2
if %ScriptVersion2% EQU %ScriptVersionGit% echo Script is up to date. & timeout /T 3 /nobreak >nul & GOTO Main
if %ScriptVersion2% GTR %ScriptVersionGit% GOTO Main
GOTO Main
:check-auto-2
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" GOTO check-auto-3
cls
color 0C
echo/                                                        
%Print%{231;72;86}		       Current Script Version is: 
%Print%{244;255;0}%ScriptVersion2% \n
%Print%{231;72;86}		       Latest Script Version is: 
%Print%{244;255;0}%ScriptVersionGit% \n
%Print%{231;72;86}\n
%Print%{231;72;86}            1) Update to the Latest Version \n
%Print%{231;72;86}\n
%Print%{231;72;86}            2) Skip this update \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what option you want." /N
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO check-auto-3
:check-auto-3
if not exist "%~dp0Installer-files\Nifer Installer Script\" mkdir "%~dp0Installer-files\Nifer Installer Script"
cd /d "%~dp0Installer-files\Nifer Installer Script"
cls
color 0C
%Print%{231;72;86} Getting Latest Version \n
echo/
for /f "tokens=1,* delims=:" %%A in ('curl -kLs https://api.github.com/repos/itsnifer/Nifer-Installer-Script/releases/latest ^| find "browser_download_url"') do (curl -kOL %%B)
echo/
%Print%{231;72;86} Applying Update \n
FOR %%A in ("*.rar") do (set "updateextract=%%A")
if defined updateextract %UnRAR% x -u -y -inul "%updateextract%"
if defined updateextract del "%updateextract%" 2>nul
Start "" "%~dp0Installer-files\Nifer Installer Script\Installer-files\Installer-Scripts\Update.cmd"
@exit

::------------------------------------------
:Main
cd /d "%~dp0"
if defined MainPluginSelection set MainPluginSelection=
if defined MainMagixSelection set MainMagixSelection=

@Title Installer Script by Nifer
cls
color 0C
echo/                                                        
%Print%{231;72;86}		   Installer Script by Nifer \n
%Print%{231;72;86}		   Patch and Script by Nifer \n
%Print%{244;255;0}                        %ScriptVersionDisplay% \n
%Print%{231;72;86}		     Twitter - @NiferEdits \n
%Print%{231;72;86}\n
%Print%{231;72;86}            1) Magix Vegas Software \n
%Print%{231;72;86}\n
%Print%{231;72;86}            2) 3rd Party Plugins \n
%Print%{231;72;86}\n
%Print%{231;72;86}            3) Settings \n
%Print%{231;72;86}\n
%Print%{231;72;86}\n
%Print%{0;185;255}            4) Donate to support (Paypal) \n
%Print%{231;72;86}\n
%Print%{255;112;0}            5) Quit \n
echo/
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what option you want." /N
cls
echo/
IF ERRORLEVEL 5  GOTO Quit
IF ERRORLEVEL 4  GOTO Donate
IF ERRORLEVEL 3  GOTO 3
IF ERRORLEVEL 2  set MainPluginSelection=1 & GOTO 2
IF ERRORLEVEL 1  set MainMagixSelection=1 & GOTO 2
echo/

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:2
color 0c
if not defined MainPluginSelection set MainPluginSelection=0
if not defined MainMagixSelection set MainMagixSelection=0

if %MainMagixSelection% EQU 1 Echo ******************************************************************
if %MainMagixSelection% EQU 1 Echo ***             (Option #1) MAGIX Vegas Software               ***
if %MainMagixSelection% EQU 1 Echo ******************************************************************
if %MainMagixSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 Echo *****************************************************************
if %MainPluginSelection% EQU 1 Echo ***          (Option #2) 3rd Party Plugins for OFX            ***
if %MainPluginSelection% EQU 1 Echo *****************************************************************
if %MainPluginSelection% EQU 1 echo/
GOTO SelectPlugins

:SelectPlugins
cd /d "%~dp0"
color 0C
if not exist ".\Installer-files\Installer-Scripts\Settings\System-Check*.txt" break> ".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt"
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" set getOptionPlugSkip=1
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt" set getOptionPlugSkip=0
if not defined getOptionPlugSkip set getOptionPlugSkip=0
GOTO Plugin-Select-Start
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LogPlugList
:: Reg Query for all supported plugins, output to logfile3.
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "Boris FX"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugbfxlist=%%L
	echo !plugbfxlist! 2>nul | findstr /v /C:"After Effects" /C:"Adobe" /C:"Photoshop" /C:"Optics" 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "BorisFX"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugbfx2list=%%L
	echo !plugbfx2list! 2>nul | findstr /v /C:"After Effects" /C:"Adobe" /C:"Photoshop" /C:"Optics" 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "Silhouette"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugbfsilolist=%%L
	echo !plugbfsilolist! 2>nul
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "VEGAS Pro 21.0 (Mocha VEGAS)"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugvpmochalist=%%L
	echo !plugvpmochalist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "Ignite"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugfxhlist=%%L
	echo !plugfxhlist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "Magic Bullet Suite"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugmbllist=%%L
	echo !plugmbllist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "Universe"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugunilist=%%L
	echo !plugunilist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "NewBlue Titler Pro 7 Ultimate"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugnbxtitlerlist=%%L
	echo !plugnbxtitlerlist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "NewBlue TotalFX 7"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugnbxtfxlist=%%L
	echo !plugnbxtfxlist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "RE:Vision Effections Fusion"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set plugnbxtitlerlist=%%L
	echo !plugnbxtitlerlist! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
exit /b

:LogMagixList
:: Reg Query for all supported programs, output to logfilemagix.
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "VEGAS Pro"^
') do (
    if "%%J"=="DisplayName" (
        set vpver=%%L
	echo !vpver! 2>nul | findstr /v /C:"Voukoder" /C:"Mocha" 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "VEGAS Effects"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set vpeff=%%L
	echo !vpeff! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "VEGAS Image"^
') do (
    if "%%J"=="DisplayName" (
	::echo %%L
        set vpimg=%%L
	echo !vpimg! 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
exit /b

:Plugin-Select-Start
setlocal ENABLEDELAYEDEXPANSION
color 0C
if %getOptionPlugSkip% EQU 1 GOTO Plug-Select-Continue-0
echo/
echo/
echo                 Loading...
cd /d "%~dp0"
::Go to a call, otherwise script will crash
if %MainPluginSelection% EQU 1 GOTO PlugScan-Pre
if %MainMagixSelection% EQU 1 GOTO MagixScan-Pre
:MagixScan-Pre
SET LOGFILEMagix=".\Installer-files\Installer-Scripts\Settings\Magix-Installations-found.txt"
call :LogMagixList > %LOGFILEMagix%
GOTO Scan-Continue
:PlugScan-Pre
SET LOGFILE3=".\Installer-files\Installer-Scripts\Settings\Plug-Installations-found.txt"
call :LogPlugList > %LOGFILE3%
GOTO Scan-Continue
:Scan-Continue
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
:: Trims duplicate entries found in Magix-Installations-found.txt
if %MainMagixSelection% EQU 1 type nul>Magix-Installations-found-output.txt
if %MainMagixSelection% EQU 1 for /f "tokens=* delims=" %%g in (Magix-Installations-found.txt) do (
  if %MainMagixSelection% EQU 1 findstr /ixc:"%%g" Magix-Installations-found-output.txt || >>Magix-Installations-found-output.txt echo.%%g
)
if %MainMagixSelection% EQU 1 cls
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 echo                 Loading...
if %MainMagixSelection% EQU 1 setlocal enabledelayedexpansion
if %MainMagixSelection% EQU 1 set Counter=1
if %MainMagixSelection% EQU 1 for /f "tokens=* delims=" %%x in (Magix-Installations-found-output.txt) do (
  if %MainMagixSelection% EQU 1 set "Line_Plug_Select_!Counter!=%%x"
  if %MainMagixSelection% EQU 1 set /a Counter+=1
)
:: Trims duplicate entries found in Plug-Installations-found.txt
if %MainPluginSelection% EQU 1 type nul>Plug-Installations-found-output.txt
if %MainPluginSelection% EQU 1 for /f "tokens=* delims=" %%g in (Plug-Installations-found.txt) do (
  if %MainPluginSelection% EQU 1 findstr /ixc:"%%g" Plug-Installations-found-output.txt || >>Plug-Installations-found-output.txt echo.%%g
)
if %MainPluginSelection% EQU 1 cls
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 echo                 Loading...
if %MainPluginSelection% EQU 1 setlocal enabledelayedexpansion
if %MainPluginSelection% EQU 1 set Counter=1
if %MainPluginSelection% EQU 1 for /f "tokens=* delims=" %%x in (Plug-Installations-found-output.txt) do (
  if %MainPluginSelection% EQU 1 set "Line_Plug_Select_!Counter!=%%x"
  if %MainPluginSelection% EQU 1 set /a Counter+=1
)
:: Parses each line in Plug-Installations-found.txt to a number counter
:: sets variables for each plugin to 0, counts later when checked.
set PlugNumber=0
if %MainPluginSelection% EQU 1 for /F %%a in ('findstr /R . Plug-Installations-found-output.txt') do (set /A PlugNumber+=1)
if %MainMagixSelection% EQU 1 for /F %%a in ('findstr /R . Magix-Installations-found-output.txt') do (set /A PlugNumber+=1)
set PlugNumberFinal=%PlugNumber%
set getOptionsPlugCountCheck=0
set plugcountbfxsaph=0
set plugcountbfxmocha=0
set plugcountvpbfxmocha=0
set plugcountbfxcontin=0
set plugcountbfxsilho=0
set plugcountignite=0
set plugcountignitenifer=0
set plugcountmbl=0
set plugcountuni=0
set plugcountnfxtitler=0
set plugcountnfxtotal=0
set plugcountrfxeff=0
set magixcountvp=0
set magixcountvpdlm=0
set magixcountve=0
set magixcountvi=0
GOTO Plug-Select-Counter
:Plug-Select-Counter
IF %PlugNumber% EQU 0 GOTO Plug-Select-Continue-0
IF %PlugNumber% GEQ 1 GOTO Plug-Select-Loop-1
:Plug-Select-Loop-1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,26!" == "Boris FX Sapphire Plug-ins" set /a plugcountbfxsaph+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,23!" == "Boris FX Mocha Plug-ins" set /a plugcountbfxmocha+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,28!" == "VEGAS Pro 21.0 (Mocha VEGAS)" set plugcountvpbfxmocha=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,18!" == "Boris FX Continuum" set /a plugcountbfxcontin+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,17!" == "BorisFX Continuum" set /a plugcountbfxcontin+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,19!" == "Boris FX Silhouette" set /a plugcountbfxsilho+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,10!" == "Silhouette" set /a plugcountbfxsilho+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,10!" == "Ignite Pro" set /a plugcountignite+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,19!" == "Ignite Pro by Nifer" set /a plugcountignitenifer+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,18!" == "Magic Bullet Suite" set /a plugcountmbl+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,8!" == "Universe" set /a plugcountuni+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,29!" == "NewBlue Titler Pro 7 Ultimate" set /a plugcountnfxtitler+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,17!" == "NewBlue TotalFX 7" set /a plugcountnfxtotal+=1
if %MainPluginSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,20!" == "RE:Vision Effections" set /a plugcountrfxeff+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 22.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 21.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 20.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 19.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 18.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 17.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 16.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 15.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 14.0  " set /a magixcountvp+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 22.0 (Deep Learning Models)  " set /a magixcountvpdlm+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 21.0 (Deep Learning Models)  " set /a magixcountvpdlm+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 20.0 (Deep Learning Models)  " set /a magixcountvpdlm+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 19.0 (Deep Learning Models)  " set /a magixcountvpdlm+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%!" == "VEGAS Pro 18.0 (Deep Learning Models)  " set /a magixcountvpdlm+=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,13!" == "VEGAS Effects" set magixcountve=1
if %MainMagixSelection% EQU 1 if /I "!Line_Plug_Select_%PlugNumber%:~0,11!" == "VEGAS Image" set /a magixcountvi+=1
set /a PlugNumber-=1
GOTO Plug-Select-Counter

:Plug-Select-Continue-0
if not defined getOptionPlugSkip set getOptionPlugSkip=0
if not defined getOptionsPlugCountCheck set getOptionsPlugCountCheck=0
if not defined getOptionsMagixCountCheck set getOptionsMagixCountCheck=0
if not defined plugcountbfxsaph set plugcountbfxsaph=0
if not defined plugcountbfxmocha set plugcountbfxmocha=0
if not defined plugcountvpbfxmocha set plugcountvpbfxmocha=0
if not defined plugcountbfxcontin set plugcountbfxcontin=0
if not defined plugcountbfxsilho set plugcountbfxsilho=0
if not defined plugcountignite set plugcountignite=0
if not defined plugcountignitenifer set plugcountignitenifer=0
if not defined plugcountmbl set plugcountmbl=0
if not defined plugcountuni set plugcountuni=0
if not defined plugcountnfxtitler set plugcountnfxtitler=0
if not defined plugcountnfxtotal set plugcountnfxtotal=0
if not defined plugcountrfxeff set plugcountrfxeff=0
if not defined magixcountvp set magixcountvp=0
if not defined magixcountvpdlm set magixcountvpdlm=0
if not defined magixcountve set magixcountve=0
if not defined magixcountvi set magixcountvi=0
GOTO Plug-Select-Continue-1

:Plug-Select-Continue-1
::0=none 1=ofx 2=vegas 3=both
if %plugcountbfxmocha% EQU 0 if %plugcountvpbfxmocha% EQU 0 set mochadisplay=0
if %plugcountbfxmocha% EQU 1 if %plugcountvpbfxmocha% EQU 0 set mochadisplay=1
if %plugcountbfxmocha% EQU 0 if %plugcountvpbfxmocha% EQU 1 set mochadisplay=2
if %plugcountbfxmocha% EQU 1 if %plugcountvpbfxmocha% EQU 1 set mochadisplay=3
if defined plugcountbfxsapfinal set plugcountbfxsapfinal=0
if defined plugcountbfxmochafinal set plugcountbfxmochafinal=0
if defined plugcountbfxcontinfinal set plugcountbfxcontinfinal=0
if defined plugcountbfxsilhofinal set plugcountbfxsilhofinal=0
if defined plugcountignitefinal set plugcountignitefinal=0
if defined plugcountmblfinal set plugcountmblfinal=0
if defined plugcountunifinal set plugcountunifinal=0
if defined plugcountnfxtitlerfinal set plugcountnfxtitlerfinal=0
if defined plugcountnfxtotalfinal set plugcountnfxtotalfinal=0
if defined plugcountrfxefffinal set plugcountrfxefffinal=0
if defined magixcountvpfinal set magixcountvpfinal=0
if defined magixcountvpdlmfinal set magixcountvpdlmfinal=0
if defined magixcountvefinal set magixcountvefinal=0
if defined magixcountvifinal set magixcountvifinal=0
cls
echo/
color 0C
if %MainMagixSelection% EQU 1 Echo ******************************************************************
if %MainMagixSelection% EQU 1 Echo ***             (Option #1) MAGIX Vegas Software               ***
if %MainMagixSelection% EQU 1 Echo ******************************************************************
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 %Print%{255;255;255}	 Available software to Download: \n
if %MainPluginSelection% EQU 1 Echo *****************************************************************
if %MainPluginSelection% EQU 1 Echo ***          (Option #2) 3rd Party Plugins for OFX            ***
if %MainPluginSelection% EQU 1 Echo *****************************************************************
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 %Print%{255;255;255}	 Available plugins to Download: \n
echo         --------------------------------
echo/
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            1) BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            1) BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            1) BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% GEQ 0 %Print%{0;185;255}(595 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{231;72;86}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{0;255;50}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{244;255;0}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 0 if %mochadisplay% LEQ 1 %Print%{0;185;255}(165 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{231;72;86}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{0;255;50}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{244;255;0}            2) BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 0 if %mochadisplay% EQU 3 %Print%{0;185;255}(165 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{231;72;86}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{0;255;50}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{244;255;0}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{231;72;86}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{0;255;50}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{244;255;0}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 0 if %mochadisplay% EQU 2 %Print%{0;185;255}(70 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{231;72;86}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{0;255;50}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{244;255;0}            BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{231;72;86}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{0;255;50}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{244;255;0}            2) BORIS FX - Mocha VEGAS 
if %MainPluginSelection% EQU 1 if %plugcountvpbfxmocha% GEQ 0 if %mochadisplay% EQU 3 %Print%{0;185;255}(70 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            3) BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            3) BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            3) BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% GEQ 0 %Print%{0;185;255}(790 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            4) BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            4) BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            4) BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% GEQ 0 %Print%{0;185;255}(1.45 GB) \n
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            5) FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            5) FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            5) FXHOME - Ignite Pro
if %MainPluginSelection% EQU 1 if %plugcountignite% GEQ 0 %Print%{0;185;255}(430 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            6) MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            6) MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            6) MAXON - Red Giant Magic Bullet Suite
if %MainPluginSelection% EQU 1 if %plugcountmbl% GEQ 0 %Print%{0;185;255}(385 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            7) MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            7) MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            7) MAXON - Red Giant Universe
if %MainPluginSelection% EQU 1 if %plugcountuni% GEQ 0 %Print%{0;185;255}(1.91 GB) \n
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            8) NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            8) NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            8) NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% GEQ 0 %Print%{0;185;255}(630 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            9) NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            9) NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            9) NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% GEQ 0 %Print%{0;185;255}(790 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            10) REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            10) REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            10) REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% GEQ 0 %Print%{0;185;255}(50 MB) \n
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;185;255}            11) ALL PLUGINS 
if %MainPluginSelection% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;185;255}(7 GB) \n
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 If %getOptionPlugSkip% EQU 0 echo         --------------------------------
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 0 If %getOptionsMagixCountCheck% EQU 0 %Print%{231;72;86}            VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 1 If %getOptionsMagixCountCheck% EQU 0 %Print%{0;255;50}            VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% GEQ 2 If %getOptionsMagixCountCheck% EQU 0 %Print%{244;255;0}            VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 0 If %getOptionsMagixCountCheck% GEQ 1 %Print%{231;72;86}            1) VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;255;50}            1) VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% GEQ 2 If %getOptionsMagixCountCheck% GEQ 1 %Print%{244;255;0}            1) VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% GEQ 0 %Print%{0;185;255}(665 MB) \n
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 0 If %getOptionsMagixCountCheck% EQU 0 %Print%{231;72;86}            VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 1 If %getOptionsMagixCountCheck% EQU 0 %Print%{0;255;50}            VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% GEQ 2 If %getOptionsMagixCountCheck% EQU 0 %Print%{244;255;0}            VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 0 If %getOptionsMagixCountCheck% GEQ 1 %Print%{231;72;86}            2) VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;255;50}            2) VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% GEQ 2 If %getOptionsMagixCountCheck% GEQ 1 %Print%{244;255;0}            2) VEGAS Pro Deep Learning Models 
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% GEQ 0 %Print%{0;185;255}(1.38 GB) \n
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 0 If %getOptionsMagixCountCheck% EQU 0 %Print%{231;72;86}            VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 1 If %getOptionsMagixCountCheck% EQU 0 %Print%{0;255;50}            VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% GEQ 2 If %getOptionsMagixCountCheck% EQU 0 %Print%{244;255;0}            VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 0 If %getOptionsMagixCountCheck% GEQ 1 %Print%{231;72;86}            3) VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;255;50}            3) VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% GEQ 2 If %getOptionsMagixCountCheck% GEQ 1 %Print%{244;255;0}            3) VEGAS Effects 
if %MainMagixSelection% EQU 1 if %magixcountve% GEQ 0 %Print%{0;185;255}(205 MB) \n
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 0 If %getOptionsMagixCountCheck% EQU 0 %Print%{231;72;86}            VEGAS Image 
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 1 If %getOptionsMagixCountCheck% EQU 0 %Print%{0;255;50}            VEGAS Image 
if %MainMagixSelection% EQU 1 if %magixcountvi% GEQ 2 If %getOptionsMagixCountCheck% EQU 0 %Print%{244;255;0}            VEGAS Image 
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 0 If %getOptionsMagixCountCheck% GEQ 1 %Print%{231;72;86}            4) VEGAS Image 
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;255;50}            4) VEGAS Image 
if %MainMagixSelection% EQU 1 if %magixcountvi% GEQ 2 If %getOptionsMagixCountCheck% GEQ 1 %Print%{244;255;0}            4) VEGAS Image
if %MainMagixSelection% EQU 1 if %magixcountvi% GEQ 0 %Print%{0;185;255}(105 MB) \n
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;185;255}            NOTE: VEGAS Pro Deep Learning Models are Optional. \n
if %MainMagixSelection% EQU 1 If %getOptionsMagixCountCheck% GEQ 1 %Print%{0;185;255}            These are used for new AI features within VEGAS Pro. \n
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 If %getOptionPlugSkip% EQU 0 echo         --------------------------------
set "PLUGKEY0="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountve% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF defined PLUGKEY0 (
if %MainPluginSelection% EQU 1 %Print%{231;72;86}        Red =        not installed \n
if %MainMagixSelection% EQU 1 %Print%{231;72;86}        Red =        not installed \n
)
set "PLUGKEY1="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountve% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% EQU 1 set PLUGKEY1=1
IF defined PLUGKEY1 (
if %MainPluginSelection% EQU 1 %Print%{0;255;50}        Green =      installed \n
if %MainMagixSelection% EQU 1 %Print%{0;255;50}        Green =      installed \n
)
set "PLUGKEY2="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% GEQ 2 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% GEQ 2 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% GEQ 2 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% GEQ 2 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountve% GEQ 2 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% GEQ 2 set PLUGKEY2=1
IF defined PLUGKEY2 (
if %MainPluginSelection% EQU 1 %Print%{244;255;0}        Yellow =     multiple installed [May detect AE plugins] \n
if %MainMagixSelection% EQU 1 %Print%{244;255;0}        Yellow =     multiple installed \n
)
if %MainPluginSelection% EQU 1 IF %getOptionsPlugCountCheck% EQU 1 GOTO getOptionsPlug
if %MainMagixSelection% EQU 1 If %getOptionsMagixCountCheck% EQU 1 GOTO getOptionsPlug
if %MainMagixSelection% EQU 1 If %getOptionsMagixCountCheck% EQU 0 GOTO Magix-Select-Prompt
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Download plugins \n
%Print%{204;204;204}            2) Uninstall plugins \n
%Print%{255;112;0}            3) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO Main
IF ERRORLEVEL 2  GOTO getOptionsPlugUninstall
IF ERRORLEVEL 1  set getOptionsPlugCountCheck=1 & GOTO Plug-Select-Continue-1
echo/

:Magix-Select-Prompt
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Download software \n
%Print%{204;204;204}            2) Uninstall software \n
%Print%{255;112;0}            3) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO Main
IF ERRORLEVEL 2  set Magix-Alr-Installed=1 & GOTO Magix-Already-Installed-Prompt
IF ERRORLEVEL 1  set getOptionsMagixCountCheck=1 & GOTO Plug-Select-Continue-1
echo/

:getOptionsPlugUninstall-Error-System
cls
color 0C
echo/
%Print%{231;72;86}To Uninstall plugins with the script, you need
%Print%{244;255;0} System Checks enabled
%Print%{231;72;86} under the script settings. \n
echo/
echo/
%Print%{231;72;86}Returning back to the Main Menu...
timeout /T 6 /nobreak >nul
GOTO Plug-Select-Continue-1

:getOptionsPlugUninstall-error
cls
color 0C
echo Plugin Queue is empty
echo Returning to main menu...
timeout /T 5 /nobreak >nul
GOTO Plug-Select-Continue-1

:getOptionsPlugUninstall
cls
if %getOptionPlugSkip% EQU 1 GOTO getOptionsPlugUninstall-Error-System
color 0c
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
:: loops through and trims duplicate entires.
type nul>Plug-Uninstall-found.txt
for /f "tokens=* delims=" %%a in (Plug-Installations-found-output.txt) do (
  findstr /ixc:"%%a" Plug-Uninstall-found.txt >nul || >>Plug-Uninstall-found.txt echo.%%a
)
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
>nul findstr "^" "Plug-Uninstall-found.txt" || getOptionsPlugUninstall-error
echo/
::::::::::::::::::::::::::::::::::::::::::::::::
:: Parses each line and puts into into a counter variable.
setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" Plug-Uninstall-found.txt | find /C ":""
for /f %%U in ('!cmd!') do set PlugUninstnumberCounter=%%U
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set Plug-Uninst-Select1="%~dp0Installer-files\Installer-Scripts\Settings\Plug-Uninstall-Selection.txt"
set Plug-Uninstall-found="%~dp0Installer-files\Installer-Scripts\Settings\Plug-Uninstall-found-output.txt"
set Plug-Uninstall-Select="%~dp0Installer-files\Installer-Scripts\Settings\Plug-Uninstall-Selection-output.txt"
if exist %Plug-Uninst-Select1% del %Plug-Uninst-Select1%
if exist %Plug-Uninstall-found% del %Plug-Uninstall-found%
if exist %Plug-Uninstall-Select% del %Plug-Uninstall-Select%
:: Set plugin list variables for reg query
set Counter=1
for /f "tokens=* delims=" %%x in (Plug-Uninstall-found.txt) do (
  set "Line_PlugUninst_!Counter!=%%x"
  set /a Counter+=1
)
set /a NumLines=Counter - 1
set PlugUninstnumber=1
set PlugUninstall1=0
set PlugUninstall2=0
set PlugUninstall3=0
set PlugUninstall4=0
set PlugUninstall5=0
set PlugUninstall6=0
set PlugUninstall7=0
set PlugUninstall8=0
set PlugUninstall9=0
set PlugUninstall10=0
set PlugUninstall11=0
set PlugUninstall12=0
GOTO Plug-Uninst-loopcheck
:Plug-Uninst-loopcheck
if %PlugUninstnumber% LEQ %PlugUninstnumberCounter% GOTO Plug-Uninst-Loop
if %PlugUninstnumber% GTR %PlugUninstnumberCounter% GOTO Plug-Uninst-Continue1
@pause

:Plug-Uninst-Loop
:: If plugin detected, echo the name into another logfile. Doing this so I can echo my own text and not the reg display names.
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,26!" == "Boris FX Sapphire Plug-ins" >> %Plug-Uninstall-found% echo BORIS FX - Sapphire & set "PlugUninstall1=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,23!" == "Boris FX Mocha Plug-ins" >> %Plug-Uninstall-found% echo BORIS FX - Mocha Pro & set "PlugUninstall2=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,18!" == "Boris FX Continuum" >> %Plug-Uninstall-found% echo BORIS FX - Continuum Complete & set "PlugUninstall3=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,17!" == "BorisFX Continuum" >> %Plug-Uninstall-found% echo BORIS FX - Continuum Complete & set "PlugUninstall3=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,19!" == "Boris FX Silhouette" >> %Plug-Uninstall-found% echo BORIS FX - Silhouette & set "PlugUninstall4=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,10!" == "Silhouette" >> %Plug-Uninstall-found% echo BORIS FX - Silhouette & set "PlugUninstall4=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,28!" == "VEGAS Pro 21.0 (Mocha VEGAS)" >> %Plug-Uninstall-found% echo BORIS FX - Mocha VEGAS & set "PlugUninstall5=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%!" == "Ignite Pro " >> %Plug-Uninstall-found% echo FXHOME - Ignite Pro & set "PlugUninstall6=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%!" == "Ignite Pro by Nifer " >> %Plug-Uninstall-found% echo FXHOME - Ignite Pro by Nifer & set "PlugUninstall7=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,18!" == "Magic Bullet Suite" >> %Plug-Uninstall-found% echo MAXON - Red Giant Magic Bullet Looks & set "PlugUninstall8=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,8!" == "Universe" >> %Plug-Uninstall-found% echo MAXON - Red Giant Universe & set "PlugUninstall9=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,29!" == "NewBlue Titler Pro 7 Ultimate" >> %Plug-Uninstall-found% echo NEWBLUEFX - Titler Pro 7 Ultimate & set "PlugUninstall10=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,17!" == "NewBlue TotalFX 7" >> %Plug-Uninstall-found% echo NEWBLUEFX - TotalFX 7 & set "PlugUninstall11=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,20!" == "RE:Vision Effections" >> %Plug-Uninstall-found% echo REVISIONFX - Effections & set "PlugUninstall12=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
set /a PlugUninstnumber+=1
GOTO Plug-Uninst-loopcheck

:Plug-Uninst-Continue1
:: Set Plug-Uninstall-found logfile to a counter, display each line for user input
set Counter=1
for /f "tokens=* delims=" %%x in (Plug-Uninstall-found-output.txt) do (
  set "Line_PlugUninstList_!Counter!=%%x"
  set /a Counter+=1
)
set /a NumLines=Counter - 1
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo/
for /l %%x in (1,1,%NumLines%) do echo  %%x - !Line_PlugUninstList_%%x!
%Print%{0;185;255} %Counter% - ALL OPTIONS \n
echo/
echo ---------------------------------
echo/
echo/
set MaxonMBLUninst=0
set MaxonUNIUninst=0
set CounterMax=%Counter%
set CounterPre=0
set CounterFinish=
GOTO Counter-loop
:Counter-loop
if %CounterPre% LSS %CounterMax% set /a CounterPre+=1 & set "CounterFinish=!CounterFinish!%CounterPre% " & GOTO Counter-loop
if %CounterPre% GTR %CounterMax% GOTO counter-finish
:counter-finish
:: Prompt user choices of all detected VP installations, and asks for multi-choice input
%Print%{231;72;86}Type your choices with a space after each choice 
%Print%{255;112;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "

if not defined choices ( 
    echo Please enter a valid option
    goto getOptions11
    )

::2=1 set 3, if fail-2/a+1) 1=optionPlugTest 2=optionPlugTestPre 3=optionPlugNumber
for %%a in (%choices%) do if %%a EQU %Counter% set "choices=!CounterFinish!"
for %%i in (%choices%) do set optionPlugTest=%%i & call :optionPlugUninst-1 2>nul
IF ERRORLEVEL 1 GOTO optionPlugUninstError11
GOTO Plug-uninstall-selection-prompt
exit

:optionPlugUninstError11
echo/
echo Exceeded max number of selections.
echo Selections (1-13)
@pause
GOTO getOptions11

:optionPlugUninst-1
set "optionPlugTestPre=1"
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=1" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=2" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=3" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=4" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=5" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=6" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=7" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=8" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=9" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=10" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=11" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
if %optionPlugTestPre% EQU %optionPlugTest% ( set "optionPlugNumber=12" & GOTO optionPlugUninst-1-Continue ) else ( set /a optionPlugTestPre+=1 )
:optionPlugUninst-1-Continue
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "BORIS FX - Sapphire " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall1%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "BORIS FX - Mocha Pro " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall2%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "BORIS FX - Continuum Complete " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall3%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "BORIS FX - Silhouette " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall4%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "BORIS FX - Mocha VEGAS " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall5%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "FXHOME - Ignite Pro " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall6%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "FXHOME - Ignite Pro by Nifer " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall7%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "MAXON - Red Giant Magic Bullet Looks " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall8% & set MaxonMBLUninst=1
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "MAXON - Red Giant Universe " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall9% & set MaxonUNIUninst=1
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "NEWBLUEFX - Titler Pro 7 Ultimate " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall10%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "NEWBLUEFX - TotalFX 7 " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall11%
if /I "!Line_PlugUninstList_%optionPlugNumber%!" == "REVISIONFX - Effections " >> %Plug-Uninst-Select1% echo  !Line_PlugUninstList_%optionPlugNumber%! & >> %Plug-Uninstall-Select% echo %PlugUninstall12%
exit /B

:Plug-uninstall-selection-prompt
color 0C
cls
echo/
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo/
type %Plug-Uninst-Select1%
echo/
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO Plug-Select-Continue-1
IF ERRORLEVEL 1  GOTO Plug-uninstall-selection-continue11
echo/

:Plug-uninstall-selection-continue11
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call %jrepl% "[ \t]+(?=\||$)" "" /f "Plug-Uninstall-Selection-output.txt" /o -
:: Parses each line in Plug-Uninstall-Selection-output.txt to a variable
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (Plug-Uninstall-Selection-output.txt) do (
  set "Line_PlugUninstSelect_!Counter!=%%x"
  set /a Counter+=1
)

:: Parses each line in Plug-Uninstall-Selection-output.txt to a variable number counter
:: Each loop will subtract -1 from the variable, until 0. Once 0 it continues the script
:: Changing directory is needed
cls
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
set "cmd=findstr /R /N "^^" Plug-Uninstall-Selection-output.txt | find /C ":""
for /f %%U in ('!cmd!') do set PlugUninstnumber=%%U
:Plug-Uninstall-Selection-loopcheck11
:: Loop to check if VPnumber variable is 0 or not.
%Print%{0;255;50} %PlugUninstnumber% Uninstalls Remaining \n
IF %PlugUninstnumber% EQU 0 GOTO Plug-uninstall-selection-fin-11
IF %PlugUninstnumber% GEQ 1 GOTO Plug-uninstall-selection-start11-1
:Plug-uninstall-selection-start11-1
color 0C
@echo off
cd /d "%~dp0"
set "PLUGKEY10="
if %MaxonMBLUninst% EQU 1 set PLUGKEY10=1
if %MaxonUNIUninst% EQU 1 set PLUGKEY10=1
IF defined PLUGKEY10 > ".\Installer-files\Installer-Scripts\uninstall-prompt.txt" echo If the uninstaller stopped or is frozen: & >> ".\Installer-files\Installer-Scripts\uninstall-prompt.txt" echo manually close the uninstaller CMD window. & >> ".\Installer-files\Installer-Scripts\uninstall-prompt.txt" echo Go back to my auto-installer script and type "n" and & >> ".\Installer-files\Installer-Scripts\uninstall-prompt.txt" echo press enter when it asks to "terminate batch job" & start "" ".\Installer-files\Installer-Scripts\uninstall-prompt.txt"
%Print%{244;255;0} !Line_PlugUninstSelect_%PlugUninstnumber%! 2>nul \n
For /F Delims^=^ EOL^=^  %%G In ('%SystemRoot%\System32\reg.exe Query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "!Line_PlugUninstSelect_%PlugUninstnumber%!" /D /E 2^>NUL') Do @For /F "EOL=H Tokens=2,*" %%H In ('%SystemRoot%\System32\reg.exe Query "%%G" /V "UninstallString" 2^>NUL') Do @Set MsiStr=%%I && set MsiStr=!MsiStr:/I=/X! && start "" /wait !MsiStr!
if %MaxonMBLUninst% EQU 1 forfiles /P "C:\Program Files\Common Files\OFX\Plugins" /M Magic Bullet Suite /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul & set MaxonMBLUninst=0
if %MaxonUNIUninst% EQU 1 forfiles /P "C:\Program Files\Common Files\OFX\Plugins" /M Red Giant Universe /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul & set MaxonUNIUninst=0
set /a PlugUninstnumber-=1
GOTO Plug-Uninstall-Selection-loopcheck11
@pause

:Plug-uninstall-selection-fin-11
if exist ".\Installer-files\Installer-Scripts\uninstall-prompt.txt" del "".\Installer-files\Installer-Scripts\uninstall-prompt.txt""
echo Finished all tasks
echo Returning to main menu...
cd /d "%~dp0"
timeout /T 5 /nobreak >nul
GOTO Pre-SelectPlugins
pause

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:getOptionsPlug
set plugcountbfxsaphfinal=0
set plugcountbfxmochafinal=0
set plugcountbfxcontinfinal=0
set plugcountbfxsilhofinal=0
set plugcountignitefinal=0
set plugcountmblfinal=0
set plugcountunifinal=0
set plugcountnfxtitlerfinal=0
set plugcountnfxtotalfinal=0
set plugcountrfxefffinal=0
set magixcountvpfinal=0
set magixcountvpdlmfinal=0
set magixcountvefinal=0
set magixcountvifinal=0
:: This entire process is for multi-selection when user chooses to install desired plugins
:: Deletes text preference for selection, if made previously
::set Plug-Inst-Select1="%~dp0Installer-files\Installer-Scripts\Settings\Plug-Install-Selection.txt"
::if exist %Plug-Inst-Select1% del %Plug-Inst-Select1%
echo         --------------------------------
echo/
echo/
%Print%{204;204;204}Type your choices with a space after each choice 
%Print%{255;112;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "

if not defined choices ( 
    echo Please enter a valid option
    goto getOptionsPlug
    )

for %%a in (%choices%) do if %%a EQU 11 set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :optionPlug-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionErrorPlug
GOTO getOptionPlug-Confirm-Prompt
exit

:optionErrorPlug
echo/
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptionsPlug

:optionPlug-1
if %MainPluginSelection% EQU 1 set plugcountbfxsaphfinal=1 
if %MainMagixSelection% EQU 1 set magixcountvpfinal=1
exit /B

:optionPlug-2
if %MainPluginSelection% EQU 1 set plugcountbfxmochafinal=1
if %MainMagixSelection% EQU 1 set magixcountvpdlmfinal=1
exit /B

:optionPlug-3
if %MainPluginSelection% EQU 1 set plugcountbfxcontinfinal=1
if %MainMagixSelection% EQU 1 set magixcountvefinal=1
exit /B

:optionPlug-4
if %MainPluginSelection% EQU 1 set plugcountbfxsilhofinal=1
if %MainMagixSelection% EQU 1 set magixcountvifinal=1
exit /B

:optionPlug-5
if %MainPluginSelection% EQU 1 set plugcountignitefinal=1
exit /B

:optionPlug-6
if %MainPluginSelection% EQU 1 set plugcountmblfinal=1
exit /B

:optionPlug-7
if %MainPluginSelection% EQU 1 set plugcountunifinal=1
exit /B

:optionPlug-8
if %MainPluginSelection% EQU 1 set plugcountnfxtitlerfinal=1
exit /B

:optionPlug-9
if %MainPluginSelection% EQU 1 set plugcountnfxtotalfinal=1
exit /B

:optionPlug-10
if %MainPluginSelection% EQU 1 set plugcountrfxefffinal=1
exit /B

:getOptionPlug-Confirm-Prompt
if %MainPluginSelection% EQU 1 if %plugcountbfxsaphfinal% EQU 1 if %plugcountbfxmochafinal% EQU 1 if %plugcountbfxcontinfinal% EQU 1 if %plugcountbfxsilhofinal% EQU 1 if %plugcountignitefinal% EQU 1 if %plugcountmblfinal% EQU 1 if %plugcountunifinal% EQU 1 if %plugcountnfxtitlerfinal% EQU 1 if %plugcountnfxtotalfinal% EQU 1 if %plugcountrfxefffinal% EQU 1 set plugcountall=1
if not defined plugcountall set plugcountall=0
color 0C
cls
echo/
if %MainPluginSelection% EQU 1 %Print%{231;72;86} Are you sure you want to install these selected plugins? \n
if %MainMagixSelection% EQU 1 %Print%{231;72;86} Are you sure you want to install these selected programs? \n
echo         --------------------------------
echo/
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 0 If %plugcountbfxsaphfinal% EQU 1 %Print%{231;72;86}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% EQU 1 If %plugcountbfxsaphfinal% EQU 1 %Print%{0;255;50}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% GEQ 2 If %plugcountbfxsaphfinal% EQU 1 %Print%{244;255;0}            BORIS FX - Sapphire 
if %MainPluginSelection% EQU 1 if %plugcountbfxsaph% GEQ 0 If %plugcountbfxsaphfinal% EQU 1 %Print%{0;185;255}(595 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 0 If %plugcountbfxmochafinal% EQU 1 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% EQU 1 If %plugcountbfxmochafinal% EQU 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 2 If %plugcountbfxmochafinal% EQU 1 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %MainPluginSelection% EQU 1 if %plugcountbfxmocha% GEQ 0 If %plugcountbfxmochafinal% EQU 1 %Print%{0;185;255}(165 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 0 If %plugcountbfxcontinfinal% EQU 1 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% EQU 1 If %plugcountbfxcontinfinal% EQU 1 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% GEQ 2 If %plugcountbfxcontinfinal% EQU 1 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %MainPluginSelection% EQU 1 if %plugcountbfxcontin% GEQ 0 If %plugcountbfxcontinfinal% EQU 1 %Print%{0;185;255}(790 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 0 If %plugcountbfxsilhofinal% EQU 1 %Print%{231;72;86}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% EQU 1 If %plugcountbfxsilhofinal% EQU 1 %Print%{0;255;50}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% GEQ 2 If %plugcountbfxsilhofinal% EQU 1 %Print%{244;255;0}            BORIS FX - Silhouette 
if %MainPluginSelection% EQU 1 if %plugcountbfxsilho% GEQ 0 If %plugcountbfxsilhofinal% EQU 1 %Print%{0;185;255}(1.45 GB) \n
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 0 If %plugcountignitefinal% EQU 1 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% EQU 1 If %plugcountignitefinal% EQU 1 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% GEQ 2 If %plugcountignitefinal% EQU 1 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %MainPluginSelection% EQU 1 if %plugcountignite% GEQ 0 If %plugcountignitefinal% EQU 1 %Print%{0;185;255}(430 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 0 If %plugcountmblfinal% EQU 1 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% EQU 1 If %plugcountmblfinal% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% GEQ 2 If %plugcountmblfinal% EQU 1 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %MainPluginSelection% EQU 1 if %plugcountmbl% GEQ 0 If %plugcountmblfinal% EQU 1 %Print%{0;185;255}(385 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 0 If %plugcountunifinal% EQU 1 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% EQU 1 If %plugcountunifinal% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% GEQ 2 If %plugcountunifinal% EQU 1 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %MainPluginSelection% EQU 1 if %plugcountuni% GEQ 0 If %plugcountunifinal% EQU 1 %Print%{0;185;255}(1.91 GB) \n
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 0 If %plugcountnfxtitlerfinal% EQU 1 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% EQU 1 If %plugcountnfxtitlerfinal% EQU 1 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% GEQ 2 If %plugcountnfxtitlerfinal% EQU 1 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtitler% GEQ 0 If %plugcountnfxtitlerfinal% EQU 1 %Print%{0;185;255}(630 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 0 If %plugcountnfxtotalfinal% EQU 1 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% EQU 1 If %plugcountnfxtotalfinal% EQU 1 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% GEQ 2 If %plugcountnfxtotalfinal% EQU 1 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %MainPluginSelection% EQU 1 if %plugcountnfxtotal% GEQ 0 If %plugcountnfxtotalfinal% EQU 1 %Print%{0;185;255}(790 MB) \n
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 0 If %plugcountrfxefffinal% EQU 1 %Print%{231;72;86}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% EQU 1 If %plugcountrfxefffinal% EQU 1 %Print%{0;255;50}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% GEQ 2 If %plugcountrfxefffinal% EQU 1 %Print%{244;255;0}            REVISIONFX - Effections 
if %MainPluginSelection% EQU 1 if %plugcountrfxeff% GEQ 0 If %plugcountrfxefffinal% EQU 1 %Print%{0;185;255}(50 MB) \n
if %MainPluginSelection% EQU 1 echo/
if %MainPluginSelection% EQU 1 If %getOptionPlugSkip% EQU 0 echo         --------------------------------
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 0 If %magixcountvpfinal% EQU 1 %Print%{231;72;86}            VEGAS Pro 
if %MainMagixSelection% EQU 1 if %magixcountvp% EQU 1 If %magixcountvpfinal% EQU 1 %Print%{0;255;50}            VEGAS Pro
if %MainMagixSelection% EQU 1 if %magixcountvp% GEQ 2 If %magixcountvpfinal% EQU 1 %Print%{244;255;0}            VEGAS Pro
if %MainMagixSelection% EQU 1 if %magixcountvp% GEQ 0 If %magixcountvpfinal% EQU 1 %Print%{0;185;255}(665 MB) \n
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 0 If %magixcountvpdlmfinal% EQU 1 %Print%{231;72;86}            VEGAS Pro Deep Learning Models
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% EQU 1 If %magixcountvpdlmfinal% EQU 1 %Print%{0;255;50}            VEGAS Pro Deep Learning Models
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% GEQ 2 If %magixcountvpdlmfinal% EQU 1 %Print%{244;255;0}            VEGAS Pro Deep Learning Models
if %MainMagixSelection% EQU 1 if %magixcountvpdlm% GEQ 0 If %magixcountvpdlmfinal% EQU 1 %Print%{0;185;255}(1.38 GB) \n
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 0 If %magixcountvefinal% EQU 1 %Print%{231;72;86}            VEGAS Effects
if %MainMagixSelection% EQU 1 if %magixcountve% EQU 1 If %magixcountvefinal% EQU 1 %Print%{0;255;50}            VEGAS Effects
if %MainMagixSelection% EQU 1 if %magixcountve% GEQ 2 If %magixcountvefinal% EQU 1 %Print%{244;255;0}            VEGAS Effects
if %MainMagixSelection% EQU 1 if %magixcountve% GEQ 0 If %magixcountvefinal% EQU 1 %Print%{0;185;255}(205 MB) \n
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 0 If %magixcountvifinal% EQU 1 %Print%{231;72;86}            VEGAS Image
if %MainMagixSelection% EQU 1 if %magixcountvi% EQU 1 If %magixcountvifinal% EQU 1 %Print%{0;255;50}            VEGAS Image
if %MainMagixSelection% EQU 1 if %magixcountvi% GEQ 2 If %magixcountvifinal% EQU 1 %Print%{244;255;0}            VEGAS Image
if %MainMagixSelection% EQU 1 if %magixcountvi% GEQ 0 If %magixcountvifinal% EQU 1 %Print%{0;185;255}(105 MB) \n
if %MainMagixSelection% EQU 1 echo/
if %MainMagixSelection% EQU 1 If %getOptionPlugSkip% EQU 0 echo         --------------------------------
set "PLUGKEY0="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% EQU 0 if %plugcountbfxsaphfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% EQU 0 if %plugcountbfxcontinfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% EQU 0 if %plugcountbfxmochafinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% EQU 0 if %plugcountbfxsilhofinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% EQU 0 if %plugcountignitefinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% EQU 0 if %plugcountmblfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% EQU 0 if %plugcountunifinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% EQU 0 if %plugcountnfxtitlerfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% EQU 0 if %plugcountnfxtotalfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% EQU 0 if %plugcountrfxefffinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% EQU 0 if %magixcountvpfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% EQU 0 if %magixcountvpdlmfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountve% EQU 0 if %magixcountvefinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% EQU 0 if %magixcountvifinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF defined PLUGKEY0 (
if %MainPluginSelection% EQU 1 %Print%{231;72;86}        Red =        not installed \n
if %MainMagixSelection% EQU 1 %Print%{231;72;86}        Red =        not installed \n
)
set "PLUGKEY1="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% EQU 1 if %plugcountbfxsaphfinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% EQU 1 if %plugcountbfxcontinfinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% EQU 1 if %plugcountbfxmochafinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% EQU 1 if %plugcountbfxsilhofinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% EQU 1 if %plugcountignitefinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% EQU 1 if %plugcountmblfinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% EQU 1 if %plugcountunifinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% EQU 1 if %plugcountnfxtitlerfinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% EQU 1 if %plugcountnfxtotalfinal% EQU 1 set PLUGKEY1=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% EQU 1 if %plugcountrfxefffinal% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% EQU 1 if %magixcountvpfinal% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% EQU 1 if %magixcountvpdlmfinal% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountve% EQU 1 if %magixcountvefinal% EQU 1 set PLUGKEY1=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% EQU 1 if %magixcountvifinal% EQU 1 set PLUGKEY1=1
IF defined PLUGKEY1 (
if %MainPluginSelection% EQU 1 %Print%{0;255;50}        Green =      installed \n
if %MainMagixSelection% EQU 1 %Print%{0;255;50}        Green =      installed \n
)
set "PLUGKEY2="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaph% GEQ 2 if %plugcountbfxsaphfinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontin% GEQ 2 if %plugcountbfxcontinfinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmocha% GEQ 2 if %plugcountbfxmochafinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilho% GEQ 2 if %plugcountbfxsilhofinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountignite% GEQ 2 if %plugcountignitefinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountmbl% GEQ 2 if %plugcountmblfinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountuni% GEQ 2 if %plugcountunifinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitler% GEQ 2 if %plugcountnfxtitlerfinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotal% GEQ 2 if %plugcountnfxtotalfinal% EQU 1 set PLUGKEY2=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeff% GEQ 2 if %plugcountrfxefffinal% EQU 1 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvp% GEQ 2 if %magixcountvpfinal% EQU 1 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlm% GEQ 2 if %magixcountvpdlmfinal% EQU 1 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountve% GEQ 2 if %magixcountvefinal% EQU 1 set PLUGKEY2=1
if %MainMagixSelection% EQU 1 IF %magixcountvi% GEQ 2 if %magixcountvifinal% EQU 1 set PLUGKEY2=1
IF defined PLUGKEY2 (
if %MainPluginSelection% EQU 1 %Print%{244;255;0}        Yellow =     multiple installed [May detect AE plugins] \n
if %MainMagixSelection% EQU 1 %Print%{244;255;0}        Yellow =     multiple installed \n
)
if %MainMagixSelection% EQU 1 GOTO getOption-Magix-Confirm-Prompt
echo         --------------------------------
echo/
if %plugcountall% EQU 1 %Print%{0;185;255}         ALL plugins are around
if %plugcountall% EQU 1 %Print%{244;255;0} 7 GB \n
echo/
%Print%{204;204;204}            1) Yes, install these plugins \n
echo/
%Print%{255;112;0}            2) No, Cancel and Go back \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  set getOptionsPlugCountCheck=0 & GOTO Plug-Select-Continue-1
IF ERRORLEVEL 1  GOTO Plug-Select-Queue-Setup
echo/
:getOption-Magix-Confirm-Prompt
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Yes, install these software \n
echo/
%Print%{255;112;0}            2) No, Cancel and Go back \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  set getOptionsMagixCountCheck=0 & GOTO Plug-Select-Continue-1
IF ERRORLEVEL 1  GOTO Plug-Select-Queue-Setup
echo/


:Plug-Already-Installed-Prompt
cls
color 0C
echo/
%Print%{231;72;86} You already have these items downloaded \n
echo/
if %plugcountbfxsaphAlr% EQU 1 %Print%{244;255;0} BORIS FX - Sapphire \n
if %plugcountbfxmochaAlr% EQU 1 %Print%{244;255;0} BORIS FX - Mocha Pro \n
if %plugcountbfxcontinAlr% EQU 1 %Print%{244;255;0} BORIS FX - Continuum Complete \n
if %plugcountbfxsilhoAlr% EQU 1 %Print%{244;255;0} BORIS FX - Silhouette \n
if %plugcountigniteAlr% EQU 1 %Print%{244;255;0} FXHOME - Ignite Pro \n
if %plugcountmblAlr% EQU 1 %Print%{244;255;0} MAXON - Red Giant Magic Bullet Suite \n
if %plugcountuniAlr% EQU 1 %Print%{244;255;0} MAXON - Red Giant Universe \n
if %plugcountnfxtitlerAlr% EQU 1 %Print%{244;255;0} NEWBLUEFX - Titler Pro 7 \n
if %plugcountnfxtotalAlr% EQU 1 %Print%{244;255;0} NEWBLUEFX - TotalFX 7 \n
if %plugcountrfxeffAlr% EQU 1 %Print%{244;255;0} REVISIONFX - Effections \n
if %magixcountvpAlr% EQU 1 %Print%{244;255;0} VEGAS Pro \n
if %magixcountvpdlmAlr% EQU 1 %Print%{244;255;0} VEGAS Pro Deep Learning Models \n
if %magixcountveAlr% EQU 1 %Print%{244;255;0} VEGAS Effects \n
if %magixcountviAlr% EQU 1 %Print%{244;255;0} VEGAS Image \n
echo/
%Print%{231;72;86} Do you want to re-download? \n
echo/
%Print%{231;72;86} 1) Re-download these items \n
%Print%{231;72;86} 2) Skip these items \n
%Print%{231;72;86} 3) No, Back to Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  set getOptionsPlugCountCheck=0 & GOTO Pre-SelectPlugins
IF ERRORLEVEL 2  GOTO Plug-Already-Installed-skip
IF ERRORLEVEL 1  GOTO Plug-Select-Queue-Setup-1
echo/

:: Creates a Log File for scanning any Vegas Pro Installations
:LogVPVers
for /f "tokens=1,2*" %%J in ('^
    reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /d /f "VEGAS Pro"^
') do (
    if "%%J"=="DisplayName" (
        set vpver=%%L
	echo !vpver! 2>nul | findstr /v Voukoder 2>nul
    ) else (
        set str=%%J
        if "!str:~0,4!"=="HKEY" set key=%%J
    )
)
exit /b

:Magix-Already-Installed-Prompt
cd /d "%~dp0"
cls
color 0C
if not defined Magix-Alr-Installed set Magix-Alr-Installed=0
::setting to 2 to skip if user comes to this function from elsewhere, then unsets the variable after to avoid issues.
if not defined plugkeymagixinstallcheck set plugkeymagixinstallcheck=2
IF %plugkeymagixinstallcheck% EQU 0 set plugkeymagixinstallcheck=1
IF %plugkeymagixinstallcheck% EQU 2 set plugkeymagixinstallcheck=
if %getOptionPlugSkip% EQU 1 GOTO Plug-Select-Queue-Setup-1
echo/
:: Check if vegas is already installed
if %Magix-Alr-Installed% EQU 0 echo Checking for other installations...
GOTO VP-Install-Check-12

:VP-Install-Check-12
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
>nul findstr "^" "VP-Installations-found.txt" || Plug-Select-Queue-Setup
GOTO alrDown-12

:alrDown-12
cls
echo/
color 0C
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
type nul>VP-Installations-found-output.txt
for /f "tokens=* delims=" %%g in (VP-Installations-found.txt) do (
  findstr /ixc:"%%g" VP-Installations-found-output.txt || >>VP-Installations-found-output.txt echo.%%g
)
cls
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo/
setLocal
:: Trims down output and removes duplicate entries
for /f "eol=- tokens=* delims= " %%T in ('find "VEGAS Pro" VP-Installations-found-output.txt') do (
	set tempvar12=%%T
   ::echo.%%T
   echo  !tempvar12:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
cd /d "%~dp0"
if %Magix-Alr-Installed% EQU 1 GOTO select-vp-uninstall-12
echo/
echo ---------------------------------
echo/
%Print%{0;185;255}NOTE: You will need to Un-Install Previous Versions of VEGAS Pro if they match VEGAS Pro 21 \n
%Print%{0;185;255}      Otherwise, Installing VP21 will not work, Older Versions of VP are okay to keep. \n
echo/
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall and Continue \n
%Print%{231;72;86} 2 = Don't uninstall anything and Continue \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo/
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO Pre-SelectPlugins
IF ERRORLEVEL 2  GOTO Plug-Select-Queue-Setup
IF ERRORLEVEL 1  GOTO select-vp-uninstall-12
echo/
:select-vp-uninstall-12
color 0C
cls
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
echo/
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo/
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call %jrepl% "[ \t]+(?=\||$)" "" /f "VP-Installations-found-output.txt" /o -
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set VP-Uninst-Select1="%~dp0Installer-files\Installer-Scripts\Settings\VP-Uninstall-Selection.txt"
if exist %VP-Uninst-Select1% del %VP-Uninst-Select1%
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (VP-Installations-found-output.txt) do (
  set "Line_!Counter!=%%x"
  set /a Counter+=1
)
set /a NumLines=Counter - 1
rem or, for arbitrary file lengths:
for /l %%x in (1,1,%NumLines%) do echo  %%x - !Line_%%x!
%Print%{0;185;255} %Counter% - ALL OPTIONS \n
echo/
echo ---------------------------------
GOTO getOptions12
:: Prompt user choices of all detected VP installations, and asks for multi-choice input
:getOptions12
%Print%{231;72;86}Type your choices with a space after each choice 
%Print%{244;255;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "

if not defined choices ( 
    echo Please enter a valid option
    goto getOptions12
    )

for %%a in (%choices%) do if %%a EQU %Counter% set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError12
GOTO vp-uninstall-selection-prompt12
exit

:optionError12
color 0C
echo/
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptions12


:vp-uninstall-selection-prompt12
color 0C
cls
echo/
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo/
type %VP-Uninst-Select1%
echo/
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO alrDown-12
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue12
echo/

:vp-uninstall-selection-continue12
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
:: Parses each line in VP-Uninstall-Selection.txt to a variable
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (VP-Uninstall-Selection.txt) do (
  set "Line_Select_!Counter!=%%x"
  set /a Counter+=1
)

:: Parses each line in VP-Uninstall-Selection.txt to a variable number counter
:: Each loop will subtract -1 from the variable, until 0. Once 0 it continues the script
:: Changing directory is needed
cls
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" VP-Uninstall-Selection.txt | find /C ":""
for /f %%U in ('!cmd!') do set VPnumber=%%U
GOTO vp-uninstall-selection-check-12
:vp-uninstall-selection-check-12
:: Loop to check if VPnumber variable is 0 or not.
%Print%{0;255;50} %VPnumber% Uninstalls Remaining \n
IF %VPnumber% EQU 0 GOTO vp-uninstall-selection-fin-12
IF %VPnumber% GEQ 1 GOTO vp-uninstall-selection-start12-1

:vp-uninstall-selection-start12-1
color 0C
@echo off
%Print%{244;255;0} !Line_Select_%VPnumber%! 2>nul \n
For /F Delims^=^ EOL^=^  %%G In ('%SystemRoot%\System32\reg.exe Query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "!Line_Select_%VPnumber%!" /D /E 2^>NUL') Do @For /F "EOL=H Tokens=2,*" %%H In ('%SystemRoot%\System32\reg.exe Query "%%G" /V "UninstallString" 2^>NUL') Do @Set MsiStr=%%I && set MsiStr=!MsiStr:/I=/X! && !MsiStr!
set /a VPnumber-=1
GOTO vp-uninstall-selection-check-12
@pause


:vp-uninstall-selection-fin-12
echo Finished all tasks
cd /d "%~dp0"
timeout /T 5 /nobreak >nul
if %Magix-Alr-Installed% EQU 0 GOTO Plug-Select-Queue-Setup
if %Magix-Alr-Installed% EQU 1 GOTO Pre-SelectPlugins

:Plug-Already-Installed-skip
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaphAlr% EQU 1 set plugcountbfxsaphfinal=0
if %MainPluginSelection% EQU 1 IF %plugcountbfxmochaAlr% EQU 1 set plugcountbfxmochafinal=0
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontinAlr% EQU 1 set plugcountbfxcontinfinal=0
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilhoAlr% EQU 1 set plugcountbfxsilhofinal=0
if %MainPluginSelection% EQU 1 IF %plugcountigniteAlr% EQU 1 set plugcountignitefinal=0
if %MainPluginSelection% EQU 1 IF %plugcountmblAlr% EQU 1 set plugcountmblfinal=0
if %MainPluginSelection% EQU 1 IF %plugcountuniAlr% EQU 1 set plugcountunifinal=0
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitlerAlr% EQU 1 set plugcountnfxtitlerfinal=0
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotalAlr% EQU 1 set plugcountnfxtotalfinal=0
if %MainPluginSelection% EQU 1 IF %plugcountrfxeffAlr% EQU 1 set plugcountrfxefffinal=0
if %MainMagixSelection% EQU 1 IF %magixcountvpAlr% EQU 1 set magixcountvpfinal=0
if %MainMagixSelection% EQU 1 IF %magixcountvpdlmAlr% EQU 1 set magixcountvpdlmfinal=0
if %MainMagixSelection% EQU 1 IF %magixcountveAlr% EQU 1 set magixcountvefinal=0
if %MainMagixSelection% EQU 1 IF %magixcountviAlr% EQU 1 set magixcountvifinal=0

set "PLUGKEY11="
IF %plugcountbfxsaphfinal% EQU 1 set PLUGKEY11=1
IF %plugcountbfxmochafinal% EQU 1 set PLUGKEY11=1
IF %plugcountbfxcontinfinal% EQU 1 set PLUGKEY11=1
IF %plugcountbfxsilhofinal% EQU 1 set PLUGKEY11=1
IF %plugcountignitefinal% EQU 1 set PLUGKEY11=1
IF %plugcountmblfinal% EQU 1 set PLUGKEY11=1
IF %plugcountunifinal% EQU 1 set PLUGKEY11=1
IF %plugcountnfxtitlerfinal% EQU 1 set PLUGKEY11=1
IF %plugcountnfxtotalfinal% EQU 1 set PLUGKEY11=1
IF %plugcountrfxefffinal% EQU 1 set PLUGKEY11=1
IF %magixcountvpfinal% EQU 1 set PLUGKEY11=1
IF %magixcountvpdlmfinal% EQU 1 set PLUGKEY11=1
IF %magixcountvefinal% EQU 1 set PLUGKEY11=1
IF %magixcountvifinal% EQU 1 set PLUGKEY11=1
IF defined PLUGKEY11 (
GOTO Plug-Select-Queue-Setup-1
)
GOTO Plug-Select-error
:Plug-Select-error
cls
color 0C
echo Error
echo Plugin Queue is empty
@pause
set getOptionsPlugCountCheck=0 & GOTO Pre-SelectPlugins

:Plug-Select-Queue-Setup
cd /d "%~dp0"
if not defined plugkeymagixinstallcheck set plugkeymagixinstallcheck=0
if not defined plugcountbfxsaphAlr set plugcountbfxsaphAlr=0
if not defined plugcountbfxmochaAlr set plugcountbfxmochaAlr=0
if not defined plugcountbfxcontinAlr set plugcountbfxcontinAlr=0
if not defined plugcountbfxsilhoAlr set plugcountbfxsilhoAlr=0
if not defined plugcountigniteAlr set plugcountigniteAlr=0
if not defined plugcountmblAlr set plugcountmblAlr=0
if not defined plugcountuniAlr set plugcountuniAlr=0
if not defined plugcountnfxtitlerAlr set plugcountnfxtitlerAlr=0
if not defined plugcountnfxtotalAlr set plugcountnfxtotalAlr=0
if not defined plugcountrfxeffAlr set plugcountrfxeffAlr=0
if not defined magixcountvpAlr set magixcountvpAlr=0
if not defined magixcountvpdlmAlr set magixcountvpdlmAlr=0
if not defined magixcountveAlr set magixcountveAlr=0
if not defined magixcountviAlr set magixcountviAlr=0
:: Check selected programs if its already installed previously
set "PLUGKEYMAGIXINST="
IF %plugkeymagixinstallcheck% EQU 0 IF %magixcountvpfinal% EQU 1 set PLUGKEYMAGIXINST=1
IF %plugkeymagixinstallcheck% EQU 0 IF %magixcountvpdlmfinal% EQU 1 set PLUGKEYMAGIXINST=1
IF %plugkeymagixinstallcheck% EQU 0 IF %magixcountvefinal% EQU 1 set PLUGKEYMAGIXINST=1
IF %plugkeymagixinstallcheck% EQU 0 IF %magixcountvifinal% EQU 1 set PLUGKEYMAGIXINST=1
IF defined PLUGKEYMAGIXINST (
set Magix-Alr-Installed=0 & GOTO Magix-Already-Installed-Prompt
)
:: Check selected plugins if it's already downloaded previously
if %plugcountbfxsaphfinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX - Sapph*" set plugcountbfxsaphAlr=1
if %plugcountbfxmochafinal% EQU 1  if exist ".\Installer-files\Plugins\Boris FX - Mocha*" set plugcountbfxmochaAlr=1
if %plugcountbfxcontinfinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX - Cont*" set plugcountbfxcontinAlr=1
if %plugcountbfxsilhofinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX - Silho*" set plugcountbfxsilhoAlr=1
if %plugcountignitefinal% EQU 1 if exist ".\Installer-files\Plugins\FXHOME - Ign*" set plugcountigniteAlr=1
if %plugcountmblfinal% EQU 1 if exist ".\Installer-files\Plugins\MAXON - Red Giant Magic Bull*" set plugcountmblAlr=1
if %plugcountunifinal% EQU 1 if exist ".\Installer-files\Plugins\MAXON - Red Giant Uni*" set plugcountuniAlr=1
if %plugcountnfxtitlerfinal% EQU 1 if exist ".\Installer-files\Plugins\NewBlueFX - Titler*" set plugcountnfxtitlerAlr=1
if %plugcountnfxtotalfinal% EQU 1 if exist ".\Installer-files\Plugins\NewBlueFX - Total*" set plugcountnfxtotalAlr=1
if %plugcountrfxefffinal% EQU 1 if exist ".\Installer-files\Plugins\REVisionFX - Eff*" set plugcountrfxeffAlr=1
if %magixcountvpfinal% EQU 1 if exist ".\Installer-files\Magix Vegas Software\VEGAS Pro" set magixcountvpAlr=1
if %magixcountvpdlmfinal% EQU 1  if exist ".\Installer-files\Magix Vegas Software\Deep Learning Models" set magixcountvpdlmAlr=1
if %magixcountvefinal% EQU 1 if exist ".\Installer-files\Magix Vegas Software\VEGAS Effects" set magixcountveAlr=1
if %magixcountvifinal% EQU 1 if exist ".\Installer-files\Magix Vegas Software\VEGAS Image" set magixcountviAlr=1
set "PLUGKEY8="
if %MainPluginSelection% EQU 1 IF %plugcountbfxsaphAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxmochaAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxcontinAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountbfxsilhoAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountigniteAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountmblAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountuniAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtitlerAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountnfxtotalAlr% EQU 1 set PLUGKEY8=1
if %MainPluginSelection% EQU 1 IF %plugcountrfxeffAlr% EQU 1 set PLUGKEY8=1
if %MainMagixSelection% EQU 1 IF %magixcountvpAlr% EQU 1 set PLUGKEY8=1
if %MainMagixSelection% EQU 1 IF %magixcountvpdlmAlr% EQU 1 set PLUGKEY8=1
if %MainMagixSelection% EQU 1 IF %magixcountveAlr% EQU 1 set PLUGKEY8=1
if %MainMagixSelection% EQU 1 IF %magixcountviAlr% EQU 1 set PLUGKEY8=1
IF defined PLUGKEY8 (
GOTO Plug-Already-Installed-Prompt
)
GOTO Plug-Select-Queue-Setup-1
:Plug-Select-Queue-Setup-1
:: Set variables for each selected plugin, add counter for task countdown
:: set first found selected plugin in queue, after queue, minus 1 from queue counter.
set PlugQueueCounter=0
set PlugQueueCounterPre=1
if not defined Mocha-veg-ofx set Mocha-veg-ofx=0
if %plugcountbfxmochafinal% EQU 1 if %Mocha-veg-ofx% EQU 0 GOTO Mocha-veg-ofx-prompt
if %plugcountbfxsaphfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin1queue=1 & set plugin1queueInst=1
if %plugcountbfxmochafinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin2queue=1 & set plugin2queueInst=1
if %plugcountbfxcontinfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin3queue=1 & set plugin3queueInst=1
if %plugcountbfxsilhofinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin4queue=1 & set plugin4queueInst=1
if %plugcountignitefinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin5queue=1 & set plugin5queueInst=1
if %plugcountmblfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin6queue=1 & set plugin6queueInst=1
if %plugcountunifinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin7queue=1 & set plugin7queueInst=1
if %plugcountnfxtitlerfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin8queue=1 & set plugin8queueInst=1
if %plugcountnfxtotalfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin9queue=1 & set plugin9queueInst=1
if %plugcountrfxefffinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin10queue=1 & set plugin10queueInst=1
if %magixcountvpfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin11queue=1 & set plugin11queueInst=1
if %magixcountvpdlmfinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin12queue=1 & set plugin12queueInst=1
if %magixcountvefinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin13queue=1 & set plugin13queueInst=1
if %magixcountvifinal% EQU 1 set /a PlugQueueCounter+=1 & set plugin14queue=1 & set plugin14queueInst=1
cls
GOTO Plug-Select-Queue-Setup-2-1

:Plug-Select-Queue-Setup-2-1
::downloads data of each plugin name, so we can rename the rar files to the proper names
cd /d "%~dp0Installer-files\Installer-Scripts"
%wget% --quiet --no-check-certificate --output-document=Names.txt "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/export?gid=1501927928&format=csv"
setlocal enabledelayedexpansion 
:: Trims Names.txt to only keep the names
if exist Names2.txt del Names2.txt
for /f "skip=1 delims=*" %%A IN (Names.txt) do echo %%A >> Names2.txt
:: Parses each line of Sizes.txt and saves it as a variable counting by each line "
For /F tokens^=* %%i in ('type "Names2.txt"
')do set /a "_cont+=1+0" && call set "_vari!_cont!=%%~i"
For /L %%L in (1 1 !_cont!)do For /F tokens^=*usebackq %%i in (
`echo[!_vari%%~L!`)do if not defined _vari_ (set "_vari_=_vari%%L=!_vari%%~L!"
     ) else set "_vari_=!_vari_!, _vari%%~L=!_vari%%~L!"
)
GOTO Plug-Select-Queue-Setup-2-2

:Plug-Select-Queue-Setup-2-2
::downloads data of each plugin size, so we can parse each size as a variable and verify if the download reached the size
cd /d "%~dp0Installer-files\Installer-Scripts"
%wget% --quiet --no-check-certificate --output-document=Sizes.txt "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/export?gid=689881134&format=csv"
setlocal enabledelayedexpansion 
:: Trims Sizes.txt to only keep the sizes and remove the names
if exist Sizes2.txt del Sizes2.txt
for /f "skip=1 delims=*, tokens=2" %%A IN (Sizes.txt) do echo %%A >> Sizes2.txt
:: Parses each line of Sizes.txt and saves it as a variable counting by each line "
For /F tokens^=* %%i in ('type "Sizes2.txt"
')do set /a "_cnt+=1+0" && call set "_var!_cnt!=%%~i"
For /L %%L in (1 1 !_cnt!)do For /F tokens^=*usebackq %%i in (
`echo[!_var%%~L!`)do if not defined _var_ (set "_var_=_var%%L=!_var%%~L!"
     ) else set "_var_=!_var_!, _var%%~L=!_var%%~L!"
)
:: Checks if selected options have a directory, if not Continue
:: if yes, markdown the number of subdir's, and compare later to verify download succeeded or not.
setlocal enabledelayedexpansion
if %plugcountbfxsaphfinal% EQU 1 if exist "%~dp0Installer-files\Plugins\Boris FX - Sapphire" set dircheck="%~dp0Installer-files\Plugins\Boris FX - Sapphire\*" && call :countdir && set plugin1dir1=!countnum!
if %plugcountbfxmochafinal% EQU 1 if exist "%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS" set dircheck="%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS\*" && call :countdir && set plugin2-1dir1=!countnum!
if %plugcountbfxmochafinal% EQU 1 if exist "%~dp0Installer-files\Plugins\Boris FX - Mocha Pro" set dircheck="%~dp0Installer-files\Plugins\Boris FX - Mocha Pro\*" && call :countdir && set plugin2-2dir1=!countnum!
if %plugcountbfxcontinfinal% EQU 1 if exist "%~dp0Installer-files\Plugins\Boris FX - Continuum Complete" set dircheck="%~dp0Installer-files\Plugins\Boris FX - Continuum Complete\*" && call :countdir && set plugin3dir1=!countnum!
if %plugcountbfxsilhofinal% EQU 1 if exist "%~dp0Installer-files\Plugins\Boris FX - Silhouette" set dircheck="%~dp0Installer-files\Plugins\Boris FX - Silhouette\*" && call :countdir && set plugin4dir1=!countnum!
if %plugcountignitefinal% EQU 1 if exist "%~dp0Installer-files\Plugins\FXHOME - Ignite Pro" set dircheck="%~dp0Installer-files\Plugins\FXHOME - Ignite Pro\*" && call :countdir && set plugin5dir1=!countnum!
if %plugcountmblfinal% EQU 1 if exist "%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite" set dircheck="%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite\*" && call :countdir && set plugin6dir1=!countnum!
if %plugcountunifinal% EQU 1 if exist "%~dp0Installer-files\Plugins\MAXON - Red Giant Universe" set dircheck="%~dp0Installer-files\Plugins\MAXON - Red Giant Universe\*" && call :countdir && set plugin7dir1=!countnum!
if %plugcountnfxtitlerfinal% EQU 1 if exist "%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate" set dircheck="%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate\*" && call :countdir && set plugin8dir1=!countnum!
if %plugcountnfxtotalfinal% EQU 1 if exist "%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7" set dircheck="%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7\*" && call :countdir && set plugin9dir1=!countnum!
if %plugcountrfxefffinal% EQU 1 if exist "%~dp0Installer-files\Plugins\REVisionFX - Effections Suite" set dircheck="%~dp0Installer-files\Plugins\REVisionFX - Effections Suite\*" && call :countdir && set plugin10dir1=!countnum!
if %magixcountvpfinal% EQU 1 if exist "%~dp0Installer-files\Magix Vegas Software\VEGAS Pro" set dircheck="%~dp0Installer-files\Magix Vegas Software\VEGAS Pro\*" && call :countdir && set plugin11dir1=!countnum!
if %magixcountvpdlmfinal% EQU 1 if exist "%~dp0Installer-files\Magix Vegas Software\Deep Learning Models" set dircheck="%~dp0Installer-files\Magix Vegas Software\Deep Learning Models\*" && call :countdir && set plugin12dir1=!countnum!
if %magixcountvefinal% EQU 1 if exist "%~dp0Installer-files\Magix Vegas Software\VEGAS Effects" set dircheck="%~dp0Installer-files\Magix Vegas Software\VEGAS Effects\*" && call :countdir && set plugin13dir1=!countnum!
if %magixcountvifinal% EQU 1 if exist "%~dp0Installer-files\Magix Vegas Software\VEGAS Image" set dircheck="%~dp0Installer-files\Magix Vegas Software\VEGAS Image\*" && call :countdir && set plugin14dir1=!countnum!
if not defined plugin1dir1 set plugin1dir1=0
if not defined plugin2-1dir1 set plugin2-1dir1=0
if not defined plugin2-2dir1 set plugin2-2dir1=0
if not defined plugin3dir1 set plugin3dir1=0
if not defined plugin4dir1 set plugin4dir1=0
if not defined plugin5dir1 set plugin5dir1=0
if not defined plugin6dir1 set plugin6dir1=0
if not defined plugin7dir1 set plugin7dir1=0
if not defined plugin8dir1 set plugin8dir1=0
if not defined plugin9dir1 set plugin9dir1=0
if not defined plugin10dir1 set plugin10dir1=0
if not defined plugin11dir1 set plugin11dir1=0
if not defined plugin12dir1 set plugin12dir1=0
if not defined plugin13dir1 set plugin13dir1=0
if not defined plugin14dir1 set plugin14dir1=0
GOTO Plug-Select-Queue-Setup-2
:countdir
if not defined dircheck echo ERROR, No variable dircheck & pause
set count=0
for /d %%a in (%dircheck%) do (
set /a count += 1
)
set countnum=!count!
exit /b
:CHECKSIZE
:: set the size of the file to a variable
set "fsize=%~z1"
:: check to see if the file size is the same. IF it is then leave the function
if not defined CheckSizeVar set CheckSizeVar=0
if %fSize% GEQ %CheckSizeVar% GOTO :EOF
:: Go back to the check if the file size is not the same
if %plugin1queue% EQU 1 GOTO Plug-Queue-1-error
if %plugin2queue% EQU 1 if %Mocha-veg-ofx% EQU 2 GOTO Plug-Queue-2-1-error
if %plugin2queue% EQU 1 if %Mocha-veg-ofx% EQU 1 GOTO Plug-Queue-2-2-error
if %plugin3queue% EQU 1 GOTO Plug-Queue-3-error
if %plugin4queue% EQU 1 GOTO Plug-Queue-4-error
if %plugin5queue% EQU 1 GOTO Plug-Queue-5-error
if %plugin6queue% EQU 1 GOTO Plug-Queue-6-error
if %plugin7queue% EQU 1 GOTO Plug-Queue-7-error
if %plugin8queue% EQU 1 GOTO Plug-Queue-8-error
if %plugin9queue% EQU 1 GOTO Plug-Queue-9-error
if %plugin10queue% EQU 1 GOTO Plug-Queue-10-error
if %plugin11queue% EQU 1 GOTO Plug-Queue-11-error
if %plugin12queue% EQU 1 GOTO Plug-Queue-12-error
if %plugin13queue% EQU 1 GOTO Plug-Queue-13-error
if %plugin14queue% EQU 1 GOTO Plug-Queue-14-error
exit /b

:Plug-Select-Queue-Setup-2
if not defined plugin1queue set plugin1queue=0
if not defined plugin2queue set plugin2queue=0
if not defined plugin3queue set plugin3queue=0
if not defined plugin4queue set plugin4queue=0
if not defined plugin5queue set plugin5queue=0
if not defined plugin6queue set plugin6queue=0
if not defined plugin7queue set plugin7queue=0
if not defined plugin8queue set plugin8queue=0
if not defined plugin9queue set plugin9queue=0
if not defined plugin10queue set plugin10queue=0
if not defined plugin11queue set plugin11queue=0
if not defined plugin12queue set plugin12queue=0
if not defined plugin13queue set plugin13queue=0
if not defined plugin14queue set plugin14queue=0
if not defined plugin1queueInst set plugin1queueInst=0
if not defined plugin2queueInst set plugin2queueInst=0
if not defined plugin3queueInst set plugin3queueInst=0
if not defined plugin4queueInst set plugin4queueInst=0
if not defined plugin5queueInst set plugin5queueInst=0
if not defined plugin6queueInst set plugin6queueInst=0
if not defined plugin7queueInst set plugin7queueInst=0
if not defined plugin8queueInst set plugin8queueInst=0
if not defined plugin9queueInst set plugin9queueInst=0
if not defined plugin10queueInst set plugin10queueInst=0
if not defined plugin11queueInst set plugin11queueInst=0
if not defined plugin12queueInst set plugin12queueInst=0
if not defined plugin13queueInst set plugin13queueInst=0
if not defined plugin14queueInst set plugin14queueInst=0
if not defined plugin1results set plugin1results=0
if not defined plugin2results set plugin2results=0
if not defined plugin3results set plugin3results=0
if not defined plugin4results set plugin4results=0
if not defined plugin5results set plugin5results=0
if not defined plugin6results set plugin6results=0
if not defined plugin7results set plugin7results=0
if not defined plugin8results set plugin8results=0
if not defined plugin9results set plugin9results=0
if not defined plugin10results set plugin10results=0
if not defined plugin11results set plugin11results=0
if not defined plugin12results set plugin12results=0
if not defined plugin13results set plugin13results=0
if not defined plugin14results set plugin14results=0

echo/
set "PLUGKEY4="
IF %plugin1queue% EQU 1 set PLUGKEY4=1
IF %plugin2queue% EQU 1 set PLUGKEY4=1
IF %plugin3queue% EQU 1 set PLUGKEY4=1
IF %plugin4queue% EQU 1 set PLUGKEY4=1
IF %plugin5queue% EQU 1 set PLUGKEY4=1
IF %plugin6queue% EQU 1 set PLUGKEY4=1
IF %plugin7queue% EQU 1 set PLUGKEY4=1
IF %plugin8queue% EQU 1 set PLUGKEY4=1
IF %plugin9queue% EQU 1 set PLUGKEY4=1
IF %plugin10queue% EQU 1 set PLUGKEY4=1
IF %plugin11queue% EQU 1 set PLUGKEY4=1
IF %plugin12queue% EQU 1 set PLUGKEY4=1
IF %plugin13queue% EQU 1 set PLUGKEY4=1
IF %plugin14queue% EQU 1 set PLUGKEY4=1
IF defined PLUGKEY4 GOTO Plug-Queue-Install
IF not defined PLUGKEY4 GOTO Plugin-Select-Extract


:Mocha-veg-ofx-prompt
cls
color 0C
echo  Before continuing...
echo  There are two available verisons of Boris FX Mocha
echo/
%Print%{204;204;204} 1 is a specially made version of Mocha by Boris FX for Vegas Pro 21 ONLY. \n
%Print%{244;255;0} has better integration with VP, although it's missing a few mocha modules \n
%Print%{0;185;255} Downlad size = (70 MB) \n
echo/
%Print%{204;204;204} 2 is the OFX version of Mocha by Boris FX. \n
%Print%{244;255;0} It works for ALL versions of Vegas Pro, \n
%Print%{244;255;0} and has all modules like 3d camera tracker. \n
%Print%{0;185;255} Downlad size = (165 MB) \n
echo/
%Print%{231;72;86}  1) Mocha Vegas \n
%Print%{231;72;86}  2) Mocha Pro OFX \n
%Print%{231;72;86}  3) Comparison of both (Open's Web Browser) \n
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  start "" https://vfx.borisfx.com/mochavegas & GOTO Mocha-veg-ofx-prompt
IF ERRORLEVEL 2  set Mocha-veg-ofx=2 & GOTO Plug-Select-Queue-Setup-1
IF ERRORLEVEL 1  set Mocha-veg-ofx=1 & GOTO Plug-Select-Queue-Setup-1
echo/

:Plug-Queue-Install
color 0C
%Print%{0;255;50}%PlugQueueCounterPre% out of %PlugQueueCounter% \n
%Print%{0;185;255}Initializing Download... \n
if %plugin1queue% EQU 1 GOTO Plug-Queue-1
if %plugin2queue% EQU 1 if %Mocha-veg-ofx% EQU 2 GOTO Plug-Queue-2-1
if %plugin2queue% EQU 1 if %Mocha-veg-ofx% EQU 1 GOTO Plug-Queue-2-2
if %plugin3queue% EQU 1 GOTO Plug-Queue-3
if %plugin4queue% EQU 1 GOTO Plug-Queue-4
if %plugin5queue% EQU 1 GOTO Plug-Queue-5
if %plugin6queue% EQU 1 GOTO Plug-Queue-6
if %plugin7queue% EQU 1 GOTO Plug-Queue-7
if %plugin8queue% EQU 1 GOTO Plug-Queue-8
if %plugin9queue% EQU 1 GOTO Plug-Queue-9
if %plugin10queue% EQU 1 GOTO Plug-Queue-10
if %plugin11queue% EQU 1 GOTO Plug-Queue-11
if %plugin12queue% EQU 1 GOTO Plug-Queue-12
if %plugin13queue% EQU 1 GOTO Plug-Queue-13
if %plugin14queue% EQU 1 GOTO Plug-Queue-14

:Plug-Queue-1
:: Boris FX Sapphire
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/MkziKReb" -P ".\Plugins\Boris FX - Sapphire"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\Boris FX - Sapphire"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari9%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var9!"
for %%G in ("%~dp0Installer-files\Plugins\Boris FX - Sapphire\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountbfxsaphfinal=0
set plugin1queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-1-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin1results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin1results% LEQ 1 echo/
if %plugin1results% LEQ 1 set plugin1results=2 & GOTO Plug-Queue-1
if %plugin1results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin1results% EQU 2 echo/
if %plugin1results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountbfxsaphfinal=0 & set plugin1queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-2-1
:: Boris FX Mocha Pro OFX
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/4etrsASn" -P ".\Plugins\Boris FX - Mocha Pro"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\Boris FX - Mocha Pro"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari7%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var7!"
for %%G in ("%~dp0Installer-files\Plugins\Boris FX - Mocha Pro\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountbfxmochafinal=0
set plugin2queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-2-1-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin2results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin2results% LEQ 1 echo/
if %plugin2results% LEQ 1 set plugin2results=2 & GOTO Plug-Queue-2-1
if %plugin2results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin2results% EQU 2 echo/
if %plugin2results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountbfxmochafinal=0 & set plugin2queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-2-2
:: Boris FX Mocha Vegas
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/WUyebEQD" -P ".\Plugins\Boris FX - Mocha VEGAS"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\Boris FX - Mocha VEGAS"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari8%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var8!"
for %%G in ("%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountbfxmochafinal=0
set plugin2queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-2-2-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin2results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin2results% LEQ 1 echo/
if %plugin2results% LEQ 1 set plugin2results=2 & GOTO Plug-Queue-2-2
if %plugin2results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin2results% EQU 2 echo/
if %plugin2results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountbfxmochafinal=0 & set plugin2queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-3
:: Boris FX Continuum
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/P1xTXJT3" -P ".\Plugins\Boris FX - Continuum Complete"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\Boris FX - Continuum Complete"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari6%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var6!"
for %%G in ("%~dp0Installer-files\Plugins\Boris FX - Continuum Complete\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountbfxcontinfinal=0
set plugin3queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-3-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin3results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin3results% LEQ 1 echo/
if %plugin3results% LEQ 1 set plugin3results=2 & GOTO Plug-Queue-3
if %plugin3results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin3results% EQU 2 echo/
if %plugin3results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountbfxcontinfinal=0 & set plugin3queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-4
:: Boris FX Silhouette
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/gLbinhBV" -P ".\Plugins\Boris FX - Silhouette"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\Boris FX - Silhouette"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari10%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var10!"
for %%G in ("%~dp0Installer-files\Plugins\Boris FX - Silhouette\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountbfxsilhofinal=0
set plugin4queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-4-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin4results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin4results% LEQ 1 echo/
if %plugin4results% LEQ 1 set plugin4results=2 & GOTO Plug-Queue-4
if %plugin4results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin4results% EQU 2 echo/
if %plugin4results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountbfxsilhofinal=0 & set plugin4queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-5
:: FXHome Ignite Pro
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/3iT9T18Z" -P ".\Plugins\FXHOME - Ignite Pro"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\FXHOME - Ignite Pro"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari11%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var11!"
for %%G in ("%~dp0Installer-files\Plugins\FXHOME - Ignite Pro\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountignitefinal=0
set plugin5queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-5-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin5results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin5results% LEQ 1 echo/
if %plugin5results% LEQ 1 set plugin5results=2 & GOTO Plug-Queue-5
if %plugin5results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin5results% EQU 2 echo/
if %plugin5results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountignitefinal=0 & set plugin5queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-6
:: Maxon Red Giant Magic Bullet Suite
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/ysg6ZBnT" -P ".\Plugins\MAXON - Red Giant Magic Bullet Suite"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\MAXON - Red Giant Magic Bullet Suite"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari12%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var12!"
for %%G in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountmblfinal=0
set plugin6queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-6-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin6results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin6results% LEQ 1 echo/
if %plugin6results% LEQ 1 set plugin6results=2 & GOTO Plug-Queue-6
if %plugin6results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin6results% EQU 2 echo/
if %plugin6results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountmblfinal=0 & set plugin6queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-7
:: Maxon Red Giant Universe
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/eYMouNf4" -P ".\Plugins\MAXON - Red Giant Universe"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\MAXON - Red Giant Universe"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari13%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var13!"
for %%G in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Universe\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountunifinal=0
set plugin7queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-7-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin7results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin7results% LEQ 1 echo/
if %plugin7results% LEQ 1 set plugin7results=2 & GOTO Plug-Queue-7
if %plugin7results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin7results% EQU 2 echo/
if %plugin7results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountunifinal=0 & set plugin7queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-8
:: NewBlue FX Titler Pro
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/UHJ6PYTP" -P ".\Plugins\NewBlueFX - Titler Pro 7 Ultimate"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\NewBlueFX - Titler Pro 7 Ultimate"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari14%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var14!"
for %%G in ("%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountnfxtitlerfinal=0
set plugin8queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-8-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin8results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin8results% LEQ 1 echo/
if %plugin8results% LEQ 1 set plugin8results=2 & GOTO Plug-Queue-8
if %plugin8results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin8results% EQU 2 echo/
if %plugin8results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountnfxtitlerfinal=0 & set plugin8queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-9
:: NewBlue FX TotalFX
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/G61gUBhS" -P ".\Plugins\NewBlueFX - TotalFX 7"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\NewBlueFX - TotalFX 7"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari15%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var15!"
for %%G in ("%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountnfxtotalfinal=0
set plugin9queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-9-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin9results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin9results% LEQ 1 echo/
if %plugin9results% LEQ 1 set plugin9results=2 & GOTO Plug-Queue-9
if %plugin9results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin9results% EQU 2 echo/
if %plugin9results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountnfxtotalfinal=0 & set plugin9queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-10
:: REVision FX Effections
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/pygxrhhN" -P ".\Plugins\REVisionFX - Effections Suite"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Plugins\REVisionFX - Effections Suite"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari16%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var16!"
for %%G in ("%~dp0Installer-files\Plugins\REVisionFX - Effections Suite\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set plugcountrfxefffinal=0
set plugin10queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-14-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin10results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin10results% LEQ 1 echo/
if %plugin10results% LEQ 1 set plugin10results=2 & GOTO Plug-Queue-10
if %plugin10results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin10results% EQU 2 echo/
if %plugin10results% EQU 2 set /a PlugQueueCounterPre+=1 & set plugcountrfxefffinal=0 & set plugin10queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-11
:: VEGAS Pro
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/mgyNdxKS" -P ".\Magix Vegas Software\Vegas Pro"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Magix Vegas Software\Vegas Pro"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari2%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var2!"
for %%G in ("%~dp0Installer-files\Magix Vegas Software\Vegas Pro\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set magixcountvpfinal=0
set plugin11queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-11-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin11results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin11results% LEQ 1 echo/
if %plugin11results% LEQ 1 set plugin11results=2 & GOTO Plug-Queue-11
if %plugin11results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin11results% EQU 2 echo/
if %plugin11results% EQU 2 set /a PlugQueueCounterPre+=1 & set magixcountvpfinal=0 & set plugin11queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-12
:: VEGAS Pro Deep Learning Models
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/2UZcZPVS" -P ".\Magix Vegas Software\Deep Learning Models"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Magix Vegas Software\Deep Learning Models"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari3%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var3!"
for %%G in ("%~dp0Installer-files\Magix Vegas Software\Deep Learning Models\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set magixcountvpdlmfinal=0
set plugin12queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-12-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin12results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin12results% LEQ 1 echo/
if %plugin12results% LEQ 1 set plugin12results=2 & GOTO Plug-Queue-12
if %plugin12results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin12results% EQU 2 echo/
if %plugin12results% EQU 2 set /a PlugQueueCounterPre+=1 & set magixcountvpdlmfinal=0 & set plugin12queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-13
:: VEGAS Effects
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/9S3AYo9L" -P ".\Magix Vegas Software\Vegas Effects"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Magix Vegas Software\Vegas Effects"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari4%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var4!"
for %%G in ("%~dp0Installer-files\Magix Vegas Software\Vegas Effects\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set magixcountvefinal=0
set plugin13queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-13-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin13results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin13results% LEQ 1 echo/
if %plugin13results% LEQ 1 set plugin13results=2 & GOTO Plug-Queue-13
if %plugin13results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin13results% EQU 2 echo/
if %plugin13results% EQU 2 set /a PlugQueueCounterPre+=1 & set magixcountvefinal=0 & set plugin13queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plug-Queue-14
:: VEGAS Image
cd /d "%~dp0Installer-files"
%Print%{0;185;255}Downloading, please be patient... \n
%wget% "https://pixeldrain.com/api/file/ATHL5d4Y" -P ".\Magix Vegas Software\Vegas Image"
:: Parses the most recent file in the downloads folder to rename.
cd /d ".\Magix Vegas Software\Vegas Image"
for /f %%i in ('dir /b/a/od/t:c') do set RECENT_FILE=%%i >NUL
REN "%RECENT_FILE%" "%_vari5%.rar"
cd /d "%~dp0Installer-files"
set CheckSizeVar="!_var5!"
for %%G in ("%~dp0Installer-files\Magix Vegas Software\Vegas Image\*.rar") DO (
    CALL :CHECKSIZE "%%G"
)
set /a PlugQueueCounterPre+=1
set magixcountvifinal=0
set plugin14queue=0
GOTO Plug-Select-Queue-Setup-2
:Plug-Queue-14-error
echo/
%Print%{255;0;0}Download Failed!
if %plugin14results% LEQ 1 %Print%{231;72;86}Re-trying download... \n
if %plugin14results% LEQ 1 echo/
if %plugin14results% LEQ 1 set plugin14results=2 & GOTO Plug-Queue-14
if %plugin14results% EQU 2 %Print%{231;72;86}Skipping Queue \n
if %plugin14results% EQU 2 echo/
if %plugin14results% EQU 2 set /a PlugQueueCounterPre+=1 & set magixcountvifinal=0 & set plugin14queue=0 & GOTO Plug-Select-Queue-Setup-2
GOTO Plug-Select-Queue-Setup-2

:Plugin-Select-Extract
cd /d "%~dp0"
::set UnRAR variable
set UnRAR="%~dp0Installer-files\Installer-Scripts\UnRAR.exe"
cls
color 0C
echo Downloads Finished!
echo Extracting .rar files
color 0C
set pluginresultsEcounter=0
if %plugin1results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin2results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin3results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin4results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin5results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin6results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin7results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin8results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin9results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin10results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin11results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin12results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin13results% EQU 2 set /a pluginresultsEcounter+=1
if %plugin14results% EQU 2 set /a pluginresultsEcounter+=1
if defined qextract1 set qextract1=
if defined qextract2 set qextract2=
if defined qextract3 set qextract3=
if defined qextract4 set qextract4=
if defined qextract5 set qextract5=
if defined qextract6 set qextract6=
if defined qextract7 set qextract7=
if defined qextract8 set qextract8=
if defined qextract9 set qextract9=
if defined qextract10 set qextract10=
if defined qextract11 set qextract11=
if defined qextract12 set qextract12=
if defined qextract13 set qextract13=
if defined qextract14 set qextract14=

if %plugin1queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\Boris FX - Sapphire\.rar") do (set "qextract1=%%A")
if defined qextract1 cd "%~dp0Installer-files\Plugins\Boris FX - Sapphire" & %Print%{244;255;0} Extracting Boris FX - Sapphire \n
if defined qextract1 %UnRAR% x -u -y -inul "%qextract1%"
if defined qextract1 del "%qextract1%" 2>nul
if defined qextract1 echo Finished
color 0c
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 2 FOR %%A in ("%~dp0Installer-files\Plugins\Boris FX - Mocha Pro\*.rar") do (set "qextract2-1=%%A")
if defined qextract2-1 cd "%~dp0Installer-files\Plugins\Boris FX - Mocha Pro" & %Print%{244;255;0} Extracting Boris FX - Mocha Pro \n
if defined qextract2-1 %UnRAR% x -u -y -inul "%qextract2-1%"
if defined qextract2-1 del "%qextract2-1%" 2>nul
if defined qextract2-1 echo Finished
color 0c
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS\*.rar") do (set "qextract2-2=%%A")
if defined qextract2-2 cd "%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS" & %Print%{244;255;0} Extracting Boris FX - Mocha VEGAS \n
if defined qextract2-2 %UnRAR% x -u -y -inul "%qextract2-2%"
if defined qextract2-2 del "%qextract2-2%" 2>nul
if defined qextract2-2 echo Finished
color 0c
if %plugin3queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\Boris FX - Continuum Complete\*.rar") do (set "qextract3=%%A")
if defined qextract3 cd "%~dp0Installer-files\Plugins\Boris FX - Continuum Complete" & %Print%{244;255;0} Extracting Boris FX - Continuum Complete \n
if defined qextract3 %UnRAR% x -u -y -inul "%qextract3%"
if defined qextract3 del "%qextract3%" 2>nul
if defined qextract3 echo Finished
color 0c
if %plugin4queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\Boris FX - Silhouette\*.rar") do (set "qextract4=%%A")
if defined qextract4 cd "%~dp0Installer-files\Plugins\Boris FX - Silhouette" & %Print%{244;255;0} Extracting Boris FX - Silhouette \n
if defined qextract4 %UnRAR% x -u -y -inul "%qextract4%"
if defined qextract4 del "%qextract4%" 2>nul
if defined qextract4 echo Finished
color 0c
if %plugin5queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\FXHOME - Ignite Pro\*.rar") do (set "qextract5=%%A")
if defined qextract5 cd "%~dp0Installer-files\Plugins\FXHOME - Ignite Pro" & %Print%{244;255;0} Extracting FXHOME - Ignite Pro \n
if defined qextract5 %UnRAR% x -u -y -inul "%qextract5%"
if defined qextract5 del "%qextract5%" 2>nul
if defined qextract5 echo Finished
color 0c
if %plugin6queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite\*.rar") do (set "qextract6=%%A")
if defined qextract6 cd "%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite" & %Print%{244;255;0} Extracting MAXON - Red Giant Magic Bullet Suite \n
if defined qextract6 %UnRAR% x -u -y -inul "%qextract6%"
if defined qextract6 del "%qextract6%" 2>nul
if defined qextract6 echo Finished
color 0c
if %plugin7queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Universe\*.rar") do (set "qextract7=%%A")
if defined qextract7 cd "%~dp0Installer-files\Plugins\MAXON - Red Giant Universe" & %Print%{244;255;0} Extracting MAXON - Red Giant Universe \n
if defined qextract7 %UnRAR% x -u -y -inul "%qextract7%"
if defined qextract7 del "%qextract7%" 2>nul
if defined qextract7 echo Finished
color 0c
if %plugin8queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate\*.rar") do (set "qextract8=%%A")
if defined qextract8 cd "%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate" & %Print%{244;255;0} Extracting NewBlueFX - Titler Pro 7 Ultimate \n
if defined qextract8 %UnRAR% x -u -y -inul "%qextract8%"
if defined qextract8 del "%qextract8%" 2>nul
if defined qextract8 echo Finished
color 0c
if %plugin9queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7\*.rar") do (set "qextract9=%%A")
if defined qextract9 cd "%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7" & %Print%{244;255;0} Extracting NewBlueFX - TotalFX 7 \n
if defined qextract9 %UnRAR% x -u -y -inul "%qextract9%"
if defined qextract9 del "%qextract9%" 2>nul
if defined qextract9 echo Finished
color 0c
if %plugin10queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Plugins\REVisionFX - Effections Suite\*.rar") do (set "qextract10=%%A")
if defined qextract10 cd "%~dp0Installer-files\Plugins\REVisionFX - Effections Suite" & %Print%{244;255;0} Extracting REVisionFX - Effections Suite \n
if defined qextract10 %UnRAR% x -u -y -inul "%qextract10%"
if defined qextract10 del "%qextract10%" 2>nul
if defined qextract10 echo Finished
color 0c
if %plugin11queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Pro\*.rar") do (set "qextract11=%%A")
if defined qextract11 cd "%~dp0Installer-files\Magix Vegas Software\VEGAS Pro" & %Print%{244;255;0} Extracting VEGAS Pro \n
if defined qextract11 %UnRAR% x -u -y -inul "%qextract11%"
if defined qextract11 del "%qextract11%" 2>nul
if defined qextract11 echo Finished
color 0c
if %plugin12queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Magix Vegas Software\Deep Learning Models\*.rar") do (set "qextract12=%%A")
if defined qextract12 cd "%~dp0Installer-files\Magix Vegas Software\Deep Learning Models" & %Print%{244;255;0} Extracting VEGAS Pro Deep Learning Models \n
if defined qextract12 %UnRAR% x -u -y -inul "%qextract12%"
if defined qextract12 del "%qextract12%" 2>nul
if defined qextract12 echo Finished
color 0c
if %plugin13queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Effects\*.rar") do (set "qextract13=%%A")
if defined qextract13 cd "%~dp0Installer-files\Magix Vegas Software\VEGAS Effects" & %Print%{244;255;0} Extracting VEGAS Effects \n
if defined qextract13 %UnRAR% x -u -y -inul "%qextract13%"
if defined qextract13 del "%qextract13%" 2>nul
if defined qextract13 echo Finished
color 0c
if %plugin14queueInst% EQU 1 FOR %%A in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Image\*.rar") do (set "qextract14=%%A")
if defined qextract14 cd "%~dp0Installer-files\Magix Vegas Software\VEGAS Image" & %Print%{244;255;0} Extracting VEGAS Image \n
if defined qextract14 %UnRAR% x -u -y -inul "%qextract14%"
if defined qextract14 del "%qextract14%" 2>nul
if defined qextract14 echo Finished

Timeout /T 5 /Nobreak >nul
if %MainMagixSelection% EQU 1 cls & color 0C & GOTO Plug-Select-autoinst0
GOTO Plug-Select-auto-prompt

:Plug-Select-auto-prompt
set PlugQueueCounterPre=1
cls
color 0C
echo/
echo How do you want to install the plugins?
echo/
echo 1) Auto Install
echo 2) Manual Install
echo/
if %pluginresultsEcounter% GEQ 1 %Print%{244;255;0} %pluginresultsEcounter% out of %PlugQueueCounter% plugins failed to download. \n
if %pluginresultsEcounter% GEQ 1 %Print%{244;255;0} If you decide to Auto Install, failed plugins will be skipped. \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO Plug-Select-manualinst
IF ERRORLEVEL 1  cls & color 0C & GOTO Plug-Select-autoinst0
echo/
:Plug-Select-manualinst
color 0c
cls
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
echo/
@pause
GOTO Pre-SelectPlugins

:Plug-Select-autoinst0
echo/
set "PLUGKEY5="
IF %plugin1queueInst% EQU 1 set PLUGKEY5=1
IF %plugin2queueInst% EQU 1 set PLUGKEY5=1
IF %plugin3queueInst% EQU 1 set PLUGKEY5=1
IF %plugin4queueInst% EQU 1 set PLUGKEY5=1
IF %plugin5queueInst% EQU 1 set PLUGKEY5=1
IF %plugin6queueInst% EQU 1 set PLUGKEY5=1
IF %plugin7queueInst% EQU 1 set PLUGKEY5=1
IF %plugin8queueInst% EQU 1 set PLUGKEY5=1
IF %plugin9queueInst% EQU 1 set PLUGKEY5=1
IF %plugin10queueInst% EQU 1 set PLUGKEY5=1
IF %plugin11queueInst% EQU 1 set PLUGKEY5=1
IF %plugin12queueInst% EQU 1 set PLUGKEY5=1
IF %plugin13queueInst% EQU 1 set PLUGKEY5=1
IF %plugin14queueInst% EQU 1 set PLUGKEY5=1
IF defined PLUGKEY5 (
GOTO Plug-Select-autoinst
)
IF not defined PLUGKEY5 GOTO Plug-Queue-Results

:Plug-Select-autoinst
color 0C
%Print%{0;255;50}%PlugQueueCounterPre% out of %PlugQueueCounter% \n
if %plugin1queueInst% EQU 1 GOTO Plug-Queue-Install-1
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 2 GOTO Plug-Queue-Install-2-1
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 1 GOTO Plug-Queue-Install-2-2
if %plugin3queueInst% EQU 1 GOTO Plug-Queue-Install-3
if %plugin4queueInst% EQU 1 GOTO Plug-Queue-Install-4
if %plugin5queueInst% EQU 1 GOTO Plug-Queue-Install-5
if %plugin6queueInst% EQU 1 GOTO Plug-Queue-Install-6
if %plugin7queueInst% EQU 1 GOTO Plug-Queue-Install-7
if %plugin8queueInst% EQU 1 GOTO Plug-Queue-Install-8
if %plugin9queueInst% EQU 1 GOTO Plug-Queue-Install-9
if %plugin10queueInst% EQU 1 GOTO Plug-Queue-Install-10
if %plugin11queueInst% EQU 1 GOTO Plug-Queue-Install-11
if %plugin12queueInst% EQU 1 GOTO Plug-Queue-Install-12
if %plugin13queueInst% EQU 1 GOTO Plug-Queue-Install-13
if %plugin140queueInst% EQU 1 GOTO Plug-Queue-Install-14
GOTO Plug-Select-autoinst0

:: 1st auto install
:Plug-Queue-Install-1
echo Launching auto install script for Boris FX Sapphire
cd /d "%~dp0Installer-files\Plugins\Boris FX - Sapphire"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Sapphire\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-1
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Sapphire\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin1queueInst=0
set plugin1results=1
GOTO Plug-Select-autoinst0
:no-auto-1
if %plugin1results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin1queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Sapphire.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin1queueInst=0
set plugin1results=3
GOTO Plug-Select-autoinst0

:: 2nd-1 auto install
:Plug-Queue-Install-2-1
echo Launching auto install script for Boris FX Mocha Pro OFX
cd /d "%~dp0Installer-files\Plugins\Boris FX - Mocha Pro"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Mocha Pro\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Mocha Pro\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=1
GOTO Plug-Select-autoinst0
:no-auto-2
if %plugin2results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin2queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Mocha Pro OFX.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=3
GOTO Plug-Select-autoinst0

:: 2nd-2 auto install
:Plug-Queue-Install-2-2
echo Launching auto install script for Boris FX Mocha Vegas
cd /d "%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2-2
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Mocha VEGAS\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=1
GOTO Plug-Select-autoinst0
:no-auto-2-2
if %plugin2results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin2queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Mocha Vegas.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=3
GOTO Plug-Select-autoinst0

:: 3rd auto install
:Plug-Queue-Install-3
echo Launching auto install script for Boris FX Continuum Complete
cd /d "%~dp0Installer-files\Plugins\Boris FX - Continuum Complete"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Continuum Complete\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-3
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Continuum Complete\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin3queueInst=0
set plugin3results=1
GOTO Plug-Select-autoinst0
:no-auto-3
if %plugin3results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin3queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Continuum Complete.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin3queueInst=0
set plugin3results=3
GOTO Plug-Select-autoinst0

:: 4th auto install
:Plug-Queue-Install-4
echo Launching auto install script for Boris FX Silhouette
cd /d "%~dp0Installer-files\Plugins\Boris FX - Silhouette"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Silhouette\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-4
for /D %%I in ("%~dp0Installer-files\Plugins\Boris FX - Silhouette\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin4queueInst=0
set plugin4results=1
GOTO Plug-Select-autoinst0
:no-auto-4
if %plugin4results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin4queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Silhouette.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin4queueInst=0
set plugin4results=3
GOTO Plug-Select-autoinst0

:: 5th auto install
:Plug-Queue-Install-5
echo Launching auto install script for FXHOME Ignite Pro
cd /d "%~dp0Installer-files\Plugins\Boris FX - Ignite Pro"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\FXHOME - Ignite Pro\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-5
for /D %%I in ("%~dp0Installer-files\Plugins\FXHOME - Ignite Pro\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin5queueInst=0
set plugin5results=1
GOTO Plug-Select-autoinst0
:no-auto-5
if %plugin5results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin5queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for FXHOME Ignite Pro.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin5queueInst=0
set plugin5results=3
GOTO Plug-Select-autoinst0

:: 6th auto install
:Plug-Queue-Install-6
echo Launching auto install script for MAXON Red Giant Magic Bullet Suite
cd /d "%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-6
for /D %%I in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Magic Bullet Suite\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin6queueInst=0
set plugin6results=1
GOTO Plug-Select-autoinst0
:no-auto-6
if %plugin6results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin6queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for MAXON Red Giant Magic Bullet Suite.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin6queueInst=0
set plugin6results=3
GOTO Plug-Select-autoinst0

:: 7th auto install
:Plug-Queue-Install-7
echo Launching auto install script for MAXON Red Giant Universe
cd /d "%~dp0Installer-files\Plugins\MAXON - Red Giant Universe"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Universe\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-7
for /D %%I in ("%~dp0Installer-files\Plugins\MAXON - Red Giant Universe\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin7queueInst=0
set plugin7results=1
GOTO Plug-Select-autoinst0
:no-auto-7
if %plugin7results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin7queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for MAXON Red Giant Universe.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin7queueInst=0
set plugin7results=3
GOTO Plug-Select-autoinst0

:: 8th auto install
:Plug-Queue-Install-8
echo Launching auto install script for NewBlueFX Titler Pro 7 Ultimate
cd /d "%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-8
for /D %%I in ("%~dp0Installer-files\Plugins\NewBlueFX - Titler Pro 7 Ultimate\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin8queueInst=0
set plugin8results=1
GOTO Plug-Select-autoinst0
:no-auto-8
if %plugin8results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin8queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for NewBlueFX Titler Pro 7 Ultimate.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin8queueInst=0
set plugin8results=3
GOTO Plug-Select-autoinst0

:: 9th auto install
:Plug-Queue-Install-9
echo Launching auto install script for NewBlueFX TotalFX 7
cd /d "%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-9
for /D %%I in ("%~dp0Installer-files\Plugins\NewBlueFX - TotalFX 7\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin9queueInst=0
set plugin9results=1
GOTO Plug-Select-autoinst0
:no-auto-9
if %plugin9results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin9queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for NewBlueFX TotalFX 7.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin9queueInst=0
set plugin9results=3
GOTO Plug-Select-autoinst0

:: 10th auto install
:Plug-Queue-Install-10
echo Launching auto install script for REVisionFX Effections
cd /d "%~dp0Installer-files\Plugins\REVisionFX - Effections Suite"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Plugins\REVisionFX - Effections Suite\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-10
for /D %%I in ("%~dp0Installer-files\Plugins\REVisionFX - Effections Suite\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin10queueInst=0
set plugin10results=1
GOTO Plug-Select-autoinst0
:no-auto-10
if %plugin10results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin10queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for REVisionFX Effections.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin10queueInst=0
set plugin10results=3
GOTO Plug-Select-autoinst0

:: 11th auto install
:Plug-Queue-Install-11
echo Launching auto install script for VEGAS Pro
cd /d "%~dp0Installer-files\Magix Vegas Software\VEGAS Pro"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Pro\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-11
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Pro\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin11queueInst=0
set plugin11results=1
GOTO Plug-Select-autoinst0
:no-auto-11
if %plugin11results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin11queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for VEGAS Pro.
echo For manual installation, please open this directory
echo "Installer-files > Magix Vegas Software > VEGAS Pro"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin11queueInst=0
set plugin11results=3
GOTO Plug-Select-autoinst0

:: 12th auto install
:Plug-Queue-Install-12
echo Launching auto install script for VEGAS Pro Deep Learning Models
cd /d "%~dp0Installer-files\Magix Vegas Software\Deep Learning Models"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\Deep Learning Models\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-12
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\Deep Learning Models\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin12queueInst=0
set plugin12results=1
GOTO Plug-Select-autoinst0
:no-auto-12
if %plugin12results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin12queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for VEGAS Pro Deep Learning Models.
echo For manual installation, please open this directory
echo "Installer-files > Magix Vegas Software > Deep Learning Models"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin12queueInst=0
set plugin12results=3
GOTO Plug-Select-autoinst0

:: 13th auto install
:Plug-Queue-Install-13
echo Launching auto install script for VEGAS Effects
cd /d "%~dp0Installer-files\Magix Vegas Software\VEGAS Effects"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Effects\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-13
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Effects\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin13queueInst=0
set plugin13results=1
GOTO Plug-Select-autoinst0
:no-auto-13
if %plugin13results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin13queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for VEGAS Effects.
echo For manual installation, please open this directory
echo "Installer-files > Magix Vegas Software > VEGAS Effects"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin13queueInst=0
set plugin13results=3
GOTO Plug-Select-autoinst0

:: 14th auto install
:Plug-Queue-Install-14
echo Launching auto install script for VEGAS Image
cd /d "%~dp0Installer-files\Magix Vegas Software\VEGAS Image"
FOR /F "delims=" %%i IN ('dir /b /ad-h /t:c /od') DO SET installdir=%%i
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Image\%installdir%") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-14
for /D %%I in ("%~dp0Installer-files\Magix Vegas Software\VEGAS Image\%installdir%") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin14queueInst=0
set plugin14results=1
GOTO Plug-Select-autoinst0
:no-auto-14
if %plugin14results% EQU 2 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin14queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for VEGAS Image.
echo For manual installation, please open this directory
echo "Installer-files > Magix Vegas Software > VEGAS Image"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin14queueInst=0
set plugin14results=3
GOTO Plug-Select-autoinst0



:: Display results of plugin process
:: 1=downloaded/installed, 2=downloaded, 3=failed
:Plug-Queue-Results
cd /d "%~dp0"
cls
echo/
%Print%{204;204;204}           Queue Report - Results: \n
echo/
echo/
set "PLUGKEY3="
IF %plugin1results% EQU 1 set PLUGKEY3=1
IF %plugin2results% EQU 1 set PLUGKEY3=1
IF %plugin3results% EQU 1 set PLUGKEY3=1
IF %plugin4results% EQU 1 set PLUGKEY3=1
IF %plugin5results% EQU 1 set PLUGKEY3=1
IF %plugin6results% EQU 1 set PLUGKEY3=1
IF %plugin7results% EQU 1 set PLUGKEY3=1
IF %plugin8results% EQU 1 set PLUGKEY3=1
IF %plugin9results% EQU 1 set PLUGKEY3=1
IF %plugin10results% EQU 1 set PLUGKEY3=1
IF %plugin11results% EQU 1 set PLUGKEY3=1
IF %plugin12results% EQU 1 set PLUGKEY3=1
IF %plugin13results% EQU 1 set PLUGKEY3=1
IF %plugin14results% EQU 1 set PLUGKEY3=1
IF defined PLUGKEY3 (
%Print%{0;255;50}             Downloaded ^& Installed \n
%Print%{0;255;50}        -------------------------------- \n
)
echo/
if %plugin1results% EQU 1 %Print%{0;255;50}            BORIS FX - Sapphire 
if %plugin1results% EQU 1 %Print%{0;185;255}(595 MB) \n
if %plugin2results% EQU 1 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %plugin2results% EQU 1 %Print%{0;185;255}(790 MB) \n
if %plugin3results% EQU 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %plugin3results% EQU 1 %Print%{0;185;255}(165 MB) \n
if %plugin4results% EQU 1 %Print%{0;255;50}            BORIS FX - Silhouette 
if %plugin4results% EQU 1 %Print%{0;185;255}(1.45 GB) \n
if %plugin5results% EQU 1 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %plugin5results% EQU 1 %Print%{0;185;255}(430 MB) \n
if %plugin6results% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% EQU 1 %Print%{0;185;255}(385 MB) \n
if %plugin7results% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %plugin7results% EQU 1 %Print%{0;185;255}(1.91 GB) \n
if %plugin8results% EQU 1 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% EQU 1 %Print%{0;185;255}(630 MB) \n
if %plugin9results% EQU 1 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %plugin9results% EQU 1 %Print%{0;185;255}(790 MB) \n
if %plugin10results% EQU 1 %Print%{0;255;50}            REVISIONFX - Effections 
if %plugin10results% EQU 1 %Print%{0;185;255}(50 MB) \n
if %plugin11results% EQU 1 %Print%{0;255;50}            VEGAS Pro
if %plugin11results% EQU 1 %Print%{0;185;255}(665 MB) \n
if %plugin12results% EQU 1 %Print%{0;255;50}            VEGAS Pro Deep Learning Models 
if %plugin12results% EQU 1 %Print%{0;185;255}(1.38 GB) \n
if %plugin13results% EQU 1 %Print%{0;255;50}            VEGAS Effects
if %plugin13results% EQU 1 %Print%{0;185;255}(205 MB) \n
if %plugin14results% EQU 1 %Print%{0;255;50}            VEGAS Image
if %plugin14results% EQU 1 %Print%{0;185;255}(105 MB) \n
echo/
set "PLUGKEY6="
IF %plugin1results% EQU 2 set PLUGKEY6=1
IF %plugin2results% EQU 2 set PLUGKEY6=1
IF %plugin3results% EQU 2 set PLUGKEY6=1
IF %plugin4results% EQU 2 set PLUGKEY6=1
IF %plugin5results% EQU 2 set PLUGKEY6=1
IF %plugin6results% EQU 2 set PLUGKEY6=1
IF %plugin7results% EQU 2 set PLUGKEY6=1
IF %plugin8results% EQU 2 set PLUGKEY6=1
IF %plugin9results% EQU 2 set PLUGKEY6=1
IF %plugin10results% EQU 2 set PLUGKEY6=1
IF %plugin11results% EQU 2 set PLUGKEY6=1
IF %plugin12results% EQU 2 set PLUGKEY6=1
IF %plugin13results% EQU 2 set PLUGKEY6=1
IF %plugin14results% EQU 2 set PLUGKEY6=1
IF defined PLUGKEY6 (
%Print%{244;255;0}           Downloaded ^& Not Installed \n
%Print%{244;255;0}        -------------------------------- \n
)
if %plugin1results% GEQ 3 %Print%{244;255;0}            BORIS FX - Sapphire 
if %plugin1results% GEQ 3 %Print%{0;185;255}(595 MB) \n
if %plugin2results% GEQ 3 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %plugin2results% GEQ 3 %Print%{0;185;255}(790 MB) \n
if %plugin3results% GEQ 3 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %plugin3results% GEQ 3 %Print%{0;185;255}(165 MB) \n
if %plugin4results% GEQ 3 %Print%{244;255;0}            BORIS FX - Silhouette 
if %plugin4results% GEQ 3 %Print%{0;185;255}(1.45 GB) \n
if %plugin5results% GEQ 3 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %plugin5results% GEQ 3 %Print%{0;185;255}(430 MB) \n
if %plugin6results% GEQ 3 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% GEQ 3 %Print%{0;185;255}(385 MB) \n
if %plugin7results% GEQ 3 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %plugin7results% GEQ 3 %Print%{0;185;255}(1.91 GB) \n
if %plugin8results% GEQ 3 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% GEQ 3 %Print%{0;185;255}(630 MB) \n
if %plugin9results% GEQ 3 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %plugin9results% GEQ 3 %Print%{0;185;255}(790 MB) \n
if %plugin10results% GEQ 3 %Print%{244;255;0}            REVISIONFX - Effections 
if %plugin10results% GEQ 3 %Print%{0;185;255}(50 MB) \n
if %plugin11results% GEQ 3 %Print%{244;255;0}            VEGAS Pro 
if %plugin11results% GEQ 3 %Print%{0;185;255}(665 MB) \n
if %plugin12results% GEQ 3 %Print%{244;255;0}            VEGAS Pro Deep Learning Models 
if %plugin12results% GEQ 3 %Print%{0;185;255}(1.38 GB) \n
if %plugin13results% GEQ 3 %Print%{244;255;0}            VEGAS Effects 
if %plugin13results% GEQ 3 %Print%{0;185;255}(205 MB) \n
if %plugin14results% GEQ 3 %Print%{244;255;0}            VEGAS Image 
if %plugin14results% GEQ 3 %Print%{0;185;255}(105 MB) \n
echo/
set "PLUGKEY7="
IF %plugin1results% GEQ 3 set PLUGKEY7=1
IF %plugin2results% GEQ 3 set PLUGKEY7=1
IF %plugin3results% GEQ 3 set PLUGKEY7=1
IF %plugin4results% GEQ 3 set PLUGKEY7=1
IF %plugin5results% GEQ 3 set PLUGKEY7=1
IF %plugin6results% GEQ 3 set PLUGKEY7=1
IF %plugin7results% GEQ 3 set PLUGKEY7=1
IF %plugin8results% GEQ 3 set PLUGKEY7=1
IF %plugin9results% GEQ 3 set PLUGKEY7=1
IF %plugin10results% GEQ 3 set PLUGKEY7=1
IF %plugin11results% GEQ 3 set PLUGKEY7=1
IF %plugin12results% GEQ 3 set PLUGKEY7=1
IF %plugin13results% GEQ 3 set PLUGKEY7=1
IF %plugin14results% GEQ 3 set PLUGKEY7=1
IF defined PLUGKEY7 (
%Print%{231;72;86}         Not Downloaded ^& Not Installed \n
%Print%{231;72;86}        -------------------------------- \n
)
if %plugin1results% EQU 2 %Print%{231;72;86}            BORIS FX - Sapphire 
if %plugin1results% EQU 2 %Print%{0;185;255}(595 MB) \n
if %plugin2results% EQU 2 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %plugin2results% EQU 2 %Print%{0;185;255}(790 MB) \n
if %plugin3results% EQU 2 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %plugin3results% EQU 2 %Print%{0;185;255}(165 MB) \n
if %plugin4results% EQU 2 %Print%{231;72;86}            BORIS FX - Silhouette 
if %plugin4results% EQU 2 %Print%{0;185;255}(1.45 GB) \n
if %plugin5results% EQU 2 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %plugin5results% EQU 2 %Print%{0;185;255}(430 MB) \n
if %plugin6results% EQU 2 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% EQU 2 %Print%{0;185;255}(385 MB) \n
if %plugin7results% EQU 2 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %plugin7results% EQU 2 %Print%{0;185;255}(1.91 GB) \n
if %plugin8results% EQU 2 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% EQU 2 %Print%{0;185;255}(630 MB) \n
if %plugin9results% EQU 2 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %plugin9results% EQU 2 %Print%{0;185;255}(790 MB) \n
if %plugin10results% EQU 2 %Print%{231;72;86}            REVISIONFX - Effections 
if %plugin10results% EQU 2 %Print%{0;185;255}(50 MB) \n
if %plugin11results% EQU 2 %Print%{231;72;86}            VEGAS Pro 
if %plugin11results% EQU 2 %Print%{0;185;255}(665 MB) \n
if %plugin12results% EQU 2 %Print%{231;72;86}            VEGAS Pro Deep Learning Models 
if %plugin12results% EQU 2 %Print%{0;185;255}(1.38 GB) \n
if %plugin13results% EQU 2 %Print%{231;72;86}            VEGAS Effects 
if %plugin13results% EQU 2 %Print%{0;185;255}(205 MB) \n
if %plugin14results% EQU 2 %Print%{231;72;86}            VEGAS Image 
if %plugin14results% EQU 2 %Print%{0;185;255}(105 MB) \n
echo/
echo/
%Print%{204;204;204}        -------------------------------- \n
echo/
C:\Windows\System32\CHOICE /C 1 /M "        1) Return to the Main Menu" /N
cls
echo/
IF ERRORLEVEL 1  GOTO Pre-SelectPlugins
echo/

:Pre-SelectPlugins
cd /d "%~dp0"
if not exist ".\Installer-files\Logs\" mkdir ".\Installer-files\Logs"
SET > ".\Installer-files\Logs\Logs_%_my_datetime%.txt
set plugin1results=
set plugin2results=
set plugin3results=
set plugin4results=
set plugin5results=
set plugin6results=
set plugin7results=
set plugin8results=
set plugin9results=
set plugin10results=
set plugin11results=
set plugin12results=
set plugin13results=
set plugin14results=
set PLUGKEY0=
set PLUGKEY1=
set PLUGKEY2=
set PLUGKEY3=
set PLUGKEY4=
set PLUGKEY5=
set PLUGKEY6=
set PLUGKEY7=
set plugin1queue=
set plugin2queue=
set plugin3queue=
set plugin4queue=
set plugin5queue=
set plugin6queue=
set plugin7queue=
set plugin8queue=
set plugin9queue=
set plugin10queue=
set plugin11queue=
set plugin12queue=
set plugin13queue=
set plugin14queue=
set plugin1queueInst=
set plugin2queueInst=
set plugin3queueInst=
set plugin4queueInst=
set plugin5queueInst=
set plugin6queueInst=
set plugin7queueInst=
set plugin8queueInst=
set plugin9queueInst=
set plugin10queueInst=
set plugin11queueInst=
set plugin12queueInst=
set plugin13queueInst=
set plugin14queueInst=
set PlugQueueCounter=
set PlugQueueCounterPre=
set pluginresultsEcounter=
set plugcountbfxsaphfinal=
set plugcountbfxmochafinal=
set plugcountbfxcontinfinal=
set plugcountbfxsilhofinal=
set plugcountignitefinal=
set plugcountmblfinal=
set plugcountunifinal=
set plugcountnfxtitlerfinal=
set plugcountnfxtotalfinal=
set plugcountrfxefffinal=
set magixcountvpfinal=
set magixcountvpdlmfinal=
set magixcountvefinal=
set magixcountvifinal=
set plugcountall=
set plugcountbfxsaph=
set plugcountbfxmocha=
set plugcountbfxcontin=
set plugcountbfxsilho=
set plugcountignite=
set plugcountmbl=
set plugcountuni=
set plugcountnfxtitler=
set plugcountnfxtotal=
set plugcountrfxeff=
set magixcountvp=
set magixcountvpdlm=
set magixcountve=
set magixcountvi=
set plugcountbfxsaphAlr=
set plugcountbfxmochaAlr=
set plugcountbfxcontinAlr=
set plugcountbfxsilhoAlr=
set plugcountigniteAlr=
set plugcountmblAlr=
set plugcountuniAlr=
set plugcountnfxtitlerAlr=
set plugcountnfxtotalAlr=
set plugcountrfxeffAlr=
set magixcountvpAlr=
set magixcountvpdlmAlr=
set magixcountveAlr=
set magixcountviAlr=
set PlugQueueCounterFinal=
set PlugQueueCounter=
set PlugQueueInstallCounter=
set PlugQueueInstallCounterFinal=
set Mocha-veg-ofx=
set getOptionsPlugCountCheck=
set PlugQueueCounterPre=
set pluginresultsEcounter=
set qextract1=
set qextract2=
set qextract3=
set qextract4=
set qextract5=
set qextract6=
set qextract7=
set qextract8=
set qextract9=
set qextract10=
set qextract11=
set qextract12=
set qextract13=
set qextract14=
set Magix-Alr-Installed=
set VPnumber=
set plugkeymagixinstallcheck=
cls
if %MainPluginSelection% EQU 1 if %MainMagixSelection% EQU 1 GOTO Main
if %MainPluginSelection% EQU 1 GOTO 2
if %MainMagixSelection% EQU 1 GOTO 2
GOTO Main


:::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:3-Main-check
:: Checks various preferences that are needed later in script, same as Main-check
:: VP-patch-1
cd /d "%~dp0"
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 3-Main
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" & GOTO 3-Main
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul del ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" >nul & GOTO 3-Main
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 3-Main
cls
GOTO 3-Main


:3
GOTO 3-Main-check
:3-Main
cd /d "%~dp0"
color 0C
cls
@ECHO OFF
color 0C
Echo            ************************************
Echo            ***    (Option #3) Settings      ***
Echo            ************************************
echo/
%Print%{255;255;255}		 Select what option you want. \n
echo/
%Print%{244;255;0}            1) Check Software Versions \n
echo/
%Print%{231;72;86}            2) Toggle Vegas Pro Patch:
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" %Print%{0;255;50} [Enabled] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" %Print%{255;0;50} [Disabled] \n
echo/
%Print%{231;72;86}            3) Toggle System Checks:
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" %Print%{255;0;50} [Disabled] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" %Print%{0;255;50} [Enabled] \n
echo/
%Print%{231;72;86}            4) Clear Vegas Pro Plugin Cache \n
echo/
%Print%{231;72;86}            5) Clean Installer Files \n
echo/
echo/
%Print%{231;72;86}            6) Preferences \n
echo/
%Print%{255;112;0}            7) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12345678 /M "Type the number (1-8) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 7  GOTO Main
IF ERRORLEVEL 6  GOTO 34
IF ERRORLEVEL 5  GOTO 33
IF ERRORLEVEL 4  GOTO 33-VPplugincache
IF ERRORLEVEL 3  GOTO 33-syscheck
IF ERRORLEVEL 2  GOTO 32
IF ERRORLEVEL 1  GOTO 31
echo/

:::::::::::::::::::::::::::::::::::::::
:31
start "" https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/edit?usp=sharing
GOTO 3-Main

:::::::::::::::::::::::::::::::::::::::
:32
cd /d "%~dp0"
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 32-enabled
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.UNBAK" >nul GOTO 32-disabled
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 32-disabled-prompt
GOTO 3

:32-enabled
color 0C
::Patch is enabled, proceeds to unpatch and save patched files for later
::Regular=patched > .UNBAK=patched copy, .bak=unpatched > Regular=unpatched, .UNBAK=patched copy
del "%~dp0Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "vegas210.exe" "vegas210.exe.UNBAK" >nul 2>nul
xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe*" /I /Q /Y /F
del "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK"

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "ScriptPortal.Vegas.dll" "ScriptPortal.Vegas.dll.UNBAK" >nul 2>nul
xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll*" /I /Q /Y /F >nul 2>nul
del "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK"

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein"
REN "Protein.4.2.dll" "Protein.4.2.dll.UNBAK" >nul 2>nul
xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll*" /I /Q /Y /F >nul 2>nul
del "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK"

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein"
REN "Protein_x64.4.2.dll" "Protein_x64.4.2.dll.UNBAK" >nul 2>nul
xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll*" /I /Q /Y /F >nul 2>nul
del "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK"

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "TransitionWPFLibrary.dll" "TransitionWPFLibrary.dll.UNBAK" >nul 2>nul
xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll*" /I /Q /Y /F >nul 2>nul
del "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK"
cd /d "%~dp0"
GOTO 3

:32-disabled
color 0C
::Patch is disable, proceeds to patch and save unpatched files for later
::Regular=unpatched > .bak=unpatched, .UNBAK=patched > Regular=patched
cd /d "%~dp0"
break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" >nul
cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "vegas210.exe" "vegas210.exe.BAK" >nul 2>nul
del "vegas210.exe" >nul 2>nul
REN "vegas210.exe.UNBAK" "vegas210.exe" >nul 2>nul
del "vegas210.exe.UNBAK" >nul 2>nul

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "ScriptPortal.Vegas.dll" "ScriptPortal.Vegas.dll.BAK" >nul 2>nul
del "ScriptPortal.Vegas.dll" >nul 2>nul
REN "ScriptPortal.Vegas.dll.UNBAK" "ScriptPortal.Vegas.dll" >nul 2>nul
del "ScriptPortal.Vegas.dll.UNBAK" >nul 2>nul

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein"
REN "Protein.4.2.dll" "Protein.4.2.dll.BAK" >nul 2>nul
del "Protein.4.2.dll" >nul 2>nul
REN "Protein.4.2.dll.UNBAK" "Protein.4.2.dll" >nul 2>nul
del "Protein.4.2.dll.UNBAK" >nul 2>nul

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein"
REN "Protein_x64.4.2.dll" "Protein_x64.4.2.dll.BAK" >nul 2>nul
del "Protein_x64.4.2.dll" >nul 2>nul
REN "Protein_x64.4.2.dll.UNBAK" "Protein_x64.4.2.dll" >nul 2>nul
del "Protein_x64.4.2.dll.UNBAK" >nul 2>nul

cd /d "C:\Program Files\VEGAS\VEGAS Pro 21.0"
REN "TransitionWPFLibrary.dll" "TransitionWPFLibrary.dll.BAK" >nul 2>nul
del "TransitionWPFLibrary.dll" >nul 2>nul
REN "TransitionWPFLibrary.dll.UNBAK" "TransitionWPFLibrary.dll" >nul 2>nul
del "TransitionWPFLibrary.dll.UNBAK" >nul 2>nul

cd /d "%~dp0"
GOTO 3

:32-disabled-prompt
color 0C
cls
echo/
echo No Backup patched files found.
echo Please run the patch through the Main Menu under Vegas Pro
timeout /T 6 /nobreak >nul
GOTO 3-Main
:::::::::::::::::::::::::::::::::::::::

:33-syscheck
cd /d "%~dp0"
if not exist ".\Installer-files\Installer-Scripts\Settings\System-Check*.txt" break>".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt"
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt" GOTO 33-syscheck-disable
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" GOTO 33-syscheck-enable

:33-syscheck-disable
REN ".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt" "System-Check-0.txt" 2>nul
GOTO 3-Main

:33-syscheck-enable
REN ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" "System-Check-1.txt" 2>nul
GOTO 3-Main

:::::::::::::::::::::::::::::::::::::::

:33-VPplugincache
cls
color 0C
echo/
%Print%{231;72;86}Are you sure you want to delete your
%Print%{244;255;0} VEGAS Pro Plugin Cache? \n
%Print%{231;72;86}This will remove the plugin cache for 
%Print%{244;255;0}all current installations of Vegas Pro 
%Print%{231;72;86}on your system. \n
%Print%{231;72;86}Upon re-opening VEGAS Pro, it will re-build your plugin cache \n
%Print%{231;72;86}(may take a while depending on how many plugins you have installed) \n
echo/
%Print%{231;72;86}Re-building your plugin cache may resolve issues with \n
%Print%{0;255;50} - Plugins not being detected by VP \n
%Print%{0;255;50} - Plugins crashing VP \n
%Print%{0;255;50} - Clearing up cache's of old or uninstalled plugins \n
echo/
echo/
%Print%{231;72;86} 1) Yes \n
%Print%{231;72;86} 2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO 3-Main
IF ERRORLEVEL 1  GOTO 33-VPplugincache-continue
echo/

:33-VPplugincache-continue
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_Ofx*.log) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (plugin_manager_cache.bin) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_plugin_cache.bin) do del "%%~fa" 2>nul
%Print%{0;255;50} Finished clearing your VEGAS Pro Plugin Cache \n
timeout /T 5 /nobreak >nul
GOTO 3-Main

:::::::::::::::::::::::::::::::::::::::
:33
color 0C
cls
echo Are you sure you want to clean all files from the installer?
echo This will remove all downloaded files, but will not uninstall any Vegas software or any Plugin.
echo 1 = Yes
echo 2 = No
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO clean-33
echo/
:clean-33
cd /d "%~dp0"
cls
color 0C
echo Cleaning up Vegas files
forfiles /P ".\Installer-files" /M Magix Vegas Software* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
echo Cleaning up Plugin files
forfiles /P ".\Installer-files" /M Plugins* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
echo Cleaning up extra files
del ".\Installer-files\*.rar" 2>nul
del ".\Installer-files\*.zip" 2>nul
echo Finished cleaning up all installer Files
timeout /T 3 /nobreak >nul
GOTO 3
:::::::::::::::::::::::::::::::::::::::

:34
cd /d "%~dp0"
color 0C
cls
@ECHO OFF
color 0C
Echo            ***************************
Echo            ***    Preferences      ***
Echo            ***************************
echo/
%Print%{255;255;255}		 Select what option you want. \n
echo/
%Print%{231;72;86}            1) Toggle Auto Updating:
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" %Print%{0;255;50} [Enabled] \n
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" %Print%{255;0;50} [Disabled] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\auto-update*.txt" %Print%{255;0;50} [N/A] \n
echo/
%Print%{231;72;86}            2) Reset All Preferences \n
echo/
%Print%{255;112;0}            3) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-4) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 3  GOTO Python-check
IF ERRORLEVEL 2  GOTO 333
IF ERRORLEVEL 1  GOTO 331
echo/
:::::::::::::::::::::::::::::::::::::::

:331
cd /d "%~dp0"
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" GOTO 331-enabled-toggle
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" GOTO 331-disabled-toggle
:331-enabled-toggle
REN ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" "auto-update-2.txt" 2>nul
GOTO 34
:331-disabled-toggle
REN ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" "auto-update-1.txt" 2>nul
GOTO 34
:::::::::::::::::::::::::::::::::::::::

:333
cls
cd /d "%~dp0"
color 0C
echo/
%Print%{231;72;86}Are you sure you want to delete
%Print%{244;255;0} ALL
%Print%{231;72;86} preferences? \n
%Print%{231;72;86}The script will ask you for these preferences when opened again. \n
echo/
%Print%{231;72;86}1 = Yes \n
%Print%{231;72;86}2 = No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO 34
IF ERRORLEVEL 1  GOTO 333-cont
echo/
:333-cont
color 0C
echo/
echo Deleting all user-made preferences
del ".\Installer-files\Installer-Scripts\Settings\*.txt" 2>nul
echo Finished.
timeout /T 3 /nobreak >nul
GOTO 34

:::::::::::::::::::::::::::::::::::::::
:Donate
start "" https://paypal.me/ItsNifer?country.x=US&locale.x=en_US
GOTO Main


:::::::::::::::::::::::::::::::::::::::
:Quit
cls
echo Quitting Nifer's Installer Script
echo Twitter - @NiferEdits
Timeout /T 3 /Nobreak >nul
@exit
