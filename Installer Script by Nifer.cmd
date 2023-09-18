
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
@cls
set jrepl="%~dp0Installer-files\Installer-Scripts\jrepl.bat"
GOTO Python-check

:Python-check
:: Check for Python Installation
echo Checking Python
python --version 2>NUL
if errorlevel 1 GOTO errorNoPython
GOTO InstallGDown1

:errorNoPython
echo/
echo Error^: Python not installed
GOTO req-Install
:req-Install
cls
echo Required software for this installer is not detected.
echo Do you want to install the Required software?
%Print%{244;255;0}This will install (if you don't already have): \n
%Print%{0;255;50} - Python 3.11.4 \n
%Print%{0;255;50} - GDown (Google Drive Downloader) \n
%Print%{0;255;50} - WinRAR or 7Zip \n
echo/
%Print%{231;72;86} 1) Yes \n
%Print%{231;72;86} 2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO pre-autoup-prompt1
echo/

:pre-autoup-prompt1
if not defined pre-autoup set pre-autoup=0
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" GOTO Main
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" del ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" >nul
if %pre-autoup% EQU 2 if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" del ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" >nul
IF NOT EXIST ".\Installer-files\Installer-Scripts\Settings" mkdir ".\Installer-files\Installer-Scripts\Settings"
color 0C
echo/
echo Do you want to enable Auto Updates for this Installer Script?
echo This will only check for updates when you launch the Installer Script.
%Print%{244;255;0}This will install (if you don't already have): \n
%Print%{0;255;50} - Git 2.41 \n
echo/
%Print%{231;72;86} 1) Yes \n
%Print%{231;72;86} 2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  if %pre-autoup% EQU 2 GOTO auto-update-no
IF ERRORLEVEL 2  if %pre-autoup% EQU 0 break>".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" & GOTO errorNoPython2
IF ERRORLEVEL 1  if %pre-autoup% EQU 2 GOTO check-auto-1
IF ERRORLEVEL 1  if %pre-autoup% EQU 0 break>".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" & GOTO errorNoPython2
echo/


:errorNoPython2
color 0C
cls
echo Installing Python 3.11.4 to PATH
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\python-3.11.4-amd64.exe" /q InstallAllUsers=1 PrependPath=1
echo Python 3.11.4 has installed successfully
echo/
timeout /T 3 /nobreak >nul
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" GOTO errorNoGit-pre
%Print%{244;255;0} Please restart the installer script. \n
%Print%{244;255;0} Close out of this CMD window, and re-run the installer script. \n
timeout /T 3 /nobreak >nul
pause >nul


:InstallGDown1
color 0C
echo/
echo Checking GDown
:: Check for GDown Installation
gdown --version 2>NUL
if errorlevel 1 goto errorNoGDown1
echo GDown is installed
GOTO check-extract


:errorNoGDown1
color 0C
echo GDown is not installed
python --version >NUL
if errorlevel 1 GOTO errorNoPython2
echo Installing GDown
timeout /T 3 /nobreak >nul
pip install gdown
timeout /T 7 /nobreak >nul
cls
GOTO check-extract


:check-extract
::Variable for Extration method
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
set szip="C:\Program Files\7-Zip\7z.exe"
color 0C
echo/
echo Checking Archiving Method
if EXIST ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO WRAR-Installed1
if EXIST ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO SZip-Installed1
IF NOT EXIST ".\Installer-files\Installer-Scripts\Settings" mkdir ".\Installer-files\Installer-Scripts\Settings"
IF EXIST "C:\Program Files\WinRAR\WinRAR.exe" IF EXIST "C:\Program Files\7-Zip\7z.exe" GOTO Choose-Archive
IF EXIST "C:\Program Files\WinRAR\WinRAR.exe" GOTO WRAR-Installed1
IF EXIST "C:\Program Files\7-Zip\7z.exe" GOTO SZip-Installed1
GOTO Prompt-Archiver
:Prompt-Archiver
cls
echo File Archiver is not detected
echo Select which archiver that you'd prefer to install:
echo/
echo 1) WinRAR
echo 2) 7Zip
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO SZip-Install1
IF ERRORLEVEL 1  GOTO WRAR-Install1
echo/
:Choose-Archive
cls
echo Multiple File Archivers were detected
echo Select which archiver that you'd prefer to use for the Installer Script:
echo 1 - WinRAR
echo 2 - 7Zip
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO SZip-Installed1
IF ERRORLEVEL 1  GOTO WRAR-Installed1
echo/
:SZip-Installed1
IF NOT EXIST "C:\Program Files\7-Zip\7z.exe" GOTO SZip-Install1
color 0C
echo 7Zip is Installed.
:: Wait 3 seconds, arbitrary... but just enough time for user to read the instructions
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" break>".\Installer-files\Installer-Scripts\Settings\archive-szip.txt"
timeout /T 3 /nobreak >nul
GOTO check-auto-up
:SZip-Install1
color 0C
echo 7Zip is not installed
echo Launching the installer for 7Zip 64bit v23.01
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\7z-Installer.exe" /S
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" break>".\Installer-files\Installer-Scripts\Settings\archive-szip.txt"
:: Wait 10 seconds, arbitrary... but just enough time for user to read the instructions
timeout /T 10 /nobreak >nul
GOTO check-auto-up
:WRAR-Installed1
IF NOT EXIST "C:\Program Files\WinRAR\WinRAR.exe" GOTO WRAR-Install1
color 0C
echo WinRAR is Installed.
:: Wait 3 seconds, arbitrary... but just enough time for user to read the instructions
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" break>".\Installer-files\Installer-Scripts\Settings\archive-win.txt"
timeout /T 3 /nobreak >nul
GOTO check-auto-up
:WRAR-Install1
color 0C
echo WinRAR is not installed
echo Launching the installer for WinRAR 64bit v622
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\winrar-installer.exe" /S
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" break>".\Installer-files\Installer-Scripts\Settings\archive-win.txt"
:: Wait 10 seconds, arbitrary... but just enough time for user to read the instructions
timeout /T 10 /nobreak >nul
GOTO check-auto-up


:: 1=yes, 0=default, 2=no
:check-auto-up
echo/
echo Checking for auto updates.
if not exist ".\Installer-files\Installer-Scripts\Settings\auto-update*.txt" break>".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt"
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" GOTO check-auto-1
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" GOTO check-auto-0
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" GOTO Main
:check-auto-1
color 0C
git --version 2>NUL
if errorlevel 1 GOTO errorNoGit
echo Auto Updates are enabled.
GOTO auto-update-fin
:check-auto-0
color 0C
set pre-autoup=2
echo Auto Updates are not enabled.
GOTO pre-autoup-prompt1

:git-install
cls
color 0C
echo/
echo Checking for Git
git --version 2>NUL
if errorlevel 1 GOTO errorNoGit
GOTO git-installed1

:errorNoGit-pre
color 0C
echo/
echo Git is not installed
::echo Downloading the installer for Git 2.41
::%Print%{244;255;0}This may take a while... \n
::%Print%{244;255;0}If the script seems to be stuck and not progressing, wait patiently. It will continue eventually. \n
:: download git with gdown
::echo/
::gdown --folder 1N0qd0b77UqqrYFzEyXOf1uKQufHOla0e -O ".\Installer-files\Installer-Scripts"
::cls
::color 0C
::echo Download is finished
timeout /T 3 /nobreak >nul
echo Launching the installer for Git 2.41
start "" /wait ".\Installer-files\Installer-Scripts\Install-Git.cmd"
::echo Cleaning up extra files...
::del ".\Installer-files\Installer-Scripts\Git*.exe" 2>nul
echo/
%Print%{244;255;0} Please restart the installer script to initialize Python and Git. \n
%Print%{244;255;0} Close out of this CMD window, and re-run the installer script. \n
timeout /T 3 /nobreak >nul
pause >nul

:errorNoGit
color 0C
echo Git is not installed
::echo Downloading the installer for Git 2.41
::%Print%{244;255;0}This may take a while... \n
::%Print%{244;255;0}If the script seems to be stuck and not progressing, wait patiently. It will continue eventually. \n
:: download git with gdown
::echo/
::gdown --folder 1N0qd0b77UqqrYFzEyXOf1uKQufHOla0e -O ".\Installer-files\Installer-Scripts"
::cls
::color 0C
::echo Download is finished
timeout /T 3 /nobreak >nul
echo Launching the installer for Git 2.41
start "" /wait ".\Installer-files\Installer-Scripts\Install-Git.cmd"
echo Cleaning up extra files...
::del ".\Installer-files\Installer-Scripts\Git*.exe" 2>nul
echo/
%Print%{244;255;0} Please restart the installer script. \n
%Print%{244;255;0} Close out of this CMD window, and re-run the installer script. \n
timeout /T 3 /nobreak >nul
pause >nul

:git-installed1
color 0C
echo Git is installed
echo/
REN ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" "auto-update-1.txt" 2>nul
git --version 2>1 1>NUL
if errorlevel 1 GOTO errorNoGit
:: Creates local git repo
git init
git config --global --add safe.directory "*"
git pull https://github.com/ItsNifer/Nifer-Installer-Script.git
IF ERRORLEVEL 1 GOTO git-update-error
IF ERRORLEVEL 0 GOTO git-installed-cont
:git-installed-cont
echo Auto updates finished.
timeout /T 3 /nobreak >nul
GOTO Main
:: Runs update script if git pull fails
:git-update-error
cls
echo Downloading Auto Update Script
gdown --folder 1gXrwTtmrqNo8n_igHaEZykUI93wWqF9_ -O ".\Installer-files\Installer-Scripts"
echo/
echo Initializing Auto Update Script
start "" ".\Installer-files\Installer-Scripts\autoup.cmd"
timeout /T 5 /nobreak >nul
@Exit
:init-Git
git init
git config --global --add safe.directory "*"
git pull https://github.com/ItsNifer/Nifer-Installer-Script.git
IF ERRORLEVEL 1 GOTO git-update-error
GOTO auto-update-fin
:auto-update-fin
echo Checking for updates
if not exist ".\.git" GOTO init-Git
:: stashes local changes, pulls updates from github, pushes local changes after it pulls.
:: waits in between each git command. If error, it will continue to Main Menu, and ignore the update. This way, the script will still be functional.
:::::::::::::::::::::::::::::::::::::::::::::
git stash >nul
if %ERRORLEVEL% == 0 GOTO git-stash-cont
if %ERRORLEVEL% == 1 GOTO git-stash-error
:git-stash-cont
	git reset --hard
    GOTO git-pull-1
:git-stash-error
    echo no local changes
	git reset --hard
	timeout /T 3 /nobreak >nul
	GOTO git-pull-1
:git-pull-1
:::::::::::::::::::::::::::::::::::::::::::::
git pull https://github.com/ItsNifer/Nifer-Installer-Script.git >nul
if %ERRORLEVEL% == 0 GOTO git-pull-cont
if %ERRORLEVEL% == 1 GOTO git-pull-error
:git-pull-cont
    echo Auto update finished...
	timeout /T 3 /nobreak >nul
    GOTO git-stash-2
:git-pull-error
:: copy/paste of git-update-error
    echo Auto update failed...
cls
echo Downloading Auto Update Script
gdown --folder 1gXrwTtmrqNo8n_igHaEZykUI93wWqF9_ -O ".\Installer-files\Installer-Scripts"
echo/
echo Initializing Auto Update Script
start "" ".\Installer-files\Installer-Scripts\autoup.cmd"
timeout /T 5 /nobreak >nul
@Exit
:git-stash-2
:::::::::::::::::::::::::::::::::::::::::::::
git stash pop >nul
if %ERRORLEVEL% == 0 GOTO git-stash2-cont
if %ERRORLEVEL% == 1 GOTO git-stash2-error
:git-stash2-cont
    echo Pushed any known local changes to directory.
	echo/
	echo/
	git checkout HEAD^ "Installer Script by Nifer.cmd"
	echo Finished checking for updates.
	timeout /T 3 /nobreak >nul
    GOTO Main
:git-stash2-error
    echo no local changes
	echo/
	echo/
	git checkout HEAD^ "Installer Script by Nifer.cmd"
	echo Finished checking for updates.
	timeout /T 3 /nobreak >nul
	GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::
:auto-update-no
color 0C
echo/
echo Disabling auto Updates
if not exist ".\Installer-files\Installer-Scripts\Settings\auto-update*.txt" break>".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt"
REN ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" "auto-update-2.txt" 2>nul
echo The Installer will no longer ask you for auto updates.
timeout /T 3 /nobreak >nul
GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::




::------------------------------------------
:Main
@Title Installer Script by Nifer
cls
color 0C
echo/                                                        
%Print%{231;72;86}		   Installer Script by Nifer \n
%Print%{231;72;86}		   Patch and Script by Nifer \n
%Print%{244;255;0}                        Version - 6.3.5 \n
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
IF ERRORLEVEL 2  GOTO 2
IF ERRORLEVEL 1  GOTO 1
echo/

:1
color 0C
cls
@ECHO OFF
color 0C
Echo *******************************************************
Echo ***    (Option #1) Choose Magix Vegas Software      ***
Echo *******************************************************
echo/
%Print%{255;255;255}		 Select what to Download and Install \n
echo/
%Print%{231;72;86}            1) Vegas Pro \n
echo/
%Print%{231;72;86}            2) Vegas Effects \n
echo/
%Print%{231;72;86}            3) Vegas Image \n
echo/
%Print%{255;112;0}            4) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 1234 /M "Type the number (1-4) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 4  GOTO Main
IF ERRORLEVEL 3  GOTO SelectImage
IF ERRORLEVEL 2  GOTO SelectEffects
IF ERRORLEVEL 1  GOTO SelectVegas
echo/

:SelectEffects
color 0C
cls
@ECHO OFF
color 0C
Echo *****************************************
Echo ***    (Option #2) Vegas Effects      ***
%Print%{231;72;86}***      
%Print%{244;255;0}Current Build: v5.0.2
%Print%{231;72;86}        *** \n
%Print%{231;72;86}***************************************** \n
echo/
%Print%{231;72;86}  Are you sure you want to download and install Vegas Effects? \n
echo/
%Print%{231;72;86}            1) Yes \n
echo/
%Print%{231;72;86}            2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  GOTO VegasEffects1
echo/
:VegasEffects1
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Effects" mkdir ".\Installer-files\Vegas Effects" 
:: gdown command
gdown --folder 1lo4oIq7dY88cQZZZv1narhqWXweMAmwN -O ".\Installer-files\Vegas Effects"
cls
color 0c
echo Download is finished
echo Installing Vegas Effects
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Effects" %%a in (VEGAS_Effects*.msi) do "%%~fa" /wait
echo Installation is finished
echo Patching is finished
echo Vegas Effects is now installed and patched
echo/
%Print%{244;255;0}Please reboot your PC for the patch to take effect. \n
timeout /T 7 /nobreak >nul
GOTO 1

:SelectImage
color 0C
cls
@ECHO OFF
color 0C
Echo ***************************************
Echo ***    (Option #3) Vegas Image      ***
%Print%{231;72;86}***      
%Print%{244;255;0}Current Build: v5.0.0
%Print%{231;72;86}      *** \n
%Print%{231;72;86}***************************************** \n
echo/
%Print%{231;72;86}  Are you sure you want to download and install Vegas Image? \n
echo/
%Print%{231;72;86}            1) Yes \n
echo/
%Print%{231;72;86}            2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  GOTO VegasImage1
echo/
:VegasImage1
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Image" mkdir ".\Installer-files\Vegas Image" 
:: gdown command
gdown --folder 1UIwIG72njWUtTgg-3vmXbEBwmCD51V_7 -O ".\Installer-files\Vegas Image"
cls
color 0c
echo Download is finished
echo Installing Vegas Image
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Image" %%a in (VEGAS_Image*.exe) do "%%~fa" /wait
echo Installation is finished
echo Patching is finished
echo Vegas Image is now installed and patched
echo/
%Print%{244;255;0}Please reboot your PC for the patch to take effect. \n
timeout /T 7 /nobreak >nul
GOTO 1


:SelectVegas
cd /d "%~dp0"
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-0.txt" set getOptionPlugSkip=1
if exist ".\Installer-files\Installer-Scripts\Settings\System-Check-1.txt" set getOptionPlugSkip=0
if not defined getOptionPlugSkip set getOptionPlugSkip=0
color 0C
cls
@ECHO OFF
color 0C
Echo ****************************************************************
Echo ***    (Option #1) Downloading and Installing Vegas Pro      ***
%Print%{231;72;86}***        
%Print%{244;255;0}Current Build: Vegas Pro 21 Build 108
%Print%{231;72;86}             *** \n
%Print%{231;72;86}**************************************************************** \n
echo/
echo/
%Print%{255;255;255}		 Select what to Download and Install \n
echo/
%Print%{231;72;86}            1) Vegas Pro + Deep Learning Modules + Patch 
%Print%{244;255;0}(1.6 GB) \n
echo/
%Print%{231;72;86}            2) Vegas Pro + Patch Only 
%Print%{244;255;0}(630 MB) \n
echo/
%Print%{231;72;86}            3) Deep Learning Modules Only 
%Print%{244;255;0}(1 GB) \n
echo/
%Print%{231;72;86}            4) Patch Only 
%Print%{244;255;0}(18 MB) \n
echo/
echo/
%Print%{255;112;0}            5) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 5  GOTO 1
IF ERRORLEVEL 4  GOTO 14
IF ERRORLEVEL 3  GOTO 13
IF ERRORLEVEL 2  GOTO 12
IF ERRORLEVEL 1  GOTO 11
echo/


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 1
:11
cls
color 0C
if %getOptionPlugSkip% EQU 1 GOTO install-11
echo/
:: Check if vegas is already installed
echo Checking for other installations...
GOTO VP-Install-Check-11

:::::::::::::::::::::::::::::::::::::::
:: Creates a Log File for scanning any Vegas Pro Installations
@ECHO OFF
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

:VP-Install-Check-11
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
for /f %%i in ("%LOGFILE%") do set size=%%~zi
if %size% EQU 0 GOTO install-11
GOTO alrDown-11

:alrDown-11
cls
echo/
color 0C
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
type nul>VP-Installations-found-output.txt
for /f "tokens=* delims=" %%g in (VP-Installations-found.txt) do (
  findstr /ixc:"%%g" VP-Installations-found-output.txt || >>VP-Installations-found-output.txt echo.%%g
)
cls
echo/
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo/
setLocal
:: Trims down output and removes duplicate entries
for /f "eol=- tokens=* delims= " %%T in ('find "VEGAS Pro" VP-Installations-found-output.txt') do (
	set tempvar11=%%T
   ::echo.%%T
   echo  !tempvar11:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
cd /d "%~dp0"
echo/
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo/
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-11
IF ERRORLEVEL 1  GOTO select-vp-uninstall-11
echo/
:select-vp-uninstall-11
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
GOTO getOptions11
:: Prompt user choices of all detected VP installations, and asks for multi-choice input
:getOptions11
%Print%{231;72;86}Type your choices with a space after each choice 
%Print%{255;112;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "

if not defined choices ( 
    echo Please enter a valid option
    goto getOptions11
    )

for %%a in (%choices%) do if %%a EQU %Counter% set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError11
GOTO vp-uninstall-selection-prompt11
exit

:optionError11
color 0C
echo/
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptions11

:option-1
>> %VP-Uninst-Select1% echo !Line_1!
exit /B

:option-2
>> %VP-Uninst-Select1% echo !Line_2!
exit /B

:option-3
>> %VP-Uninst-Select1% echo !Line_3!
exit /B

:option-4
>> %VP-Uninst-Select1% echo !Line_4!
exit /B

:option-5
>> %VP-Uninst-Select1% echo !Line_5!
exit /B

:option-6
>> %VP-Uninst-Select1% echo !Line_6!
exit /B

:option-7
>> %VP-Uninst-Select1% echo !Line_7!
exit /B

:option-8
>> %VP-Uninst-Select1% echo !Line_8!
exit /B

:option-9
>> %VP-Uninst-Select1% echo !Line_9!
exit /B

:option-10
>> %VP-Uninst-Select1% echo !Line_10!
exit /B

:vp-uninstall-selection-prompt11
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
IF ERRORLEVEL 2  GOTO alrDown-11
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue11
echo/

:vp-uninstall-selection-continue11
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
GOTO vp-uninstall-selection-check-11
:vp-uninstall-selection-check-11
:: Loop to check if VPnumber variable is 0 or not.
%Print%{0;255;50} %VPnumber% Uninstalls Remaining \n
IF %VPnumber% EQU 0 GOTO vp-uninstall-selection-fin-11
IF %VPnumber% GEQ 1 GOTO vp-uninstall-selection-start11-1

:vp-uninstall-selection-start11-1
color 0C
@echo off
%Print%{244;255;0} !Line_Select_%VPnumber%! 2>nul \n
For /F Delims^=^ EOL^=^  %%G In ('%SystemRoot%\System32\reg.exe Query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "!Line_Select_%VPnumber%!" /D /E 2^>NUL') Do @For /F "EOL=H Tokens=2,*" %%H In ('%SystemRoot%\System32\reg.exe Query "%%G" /V "UninstallString" 2^>NUL') Do @Set MsiStr=%%I && set MsiStr=!MsiStr:/I=/X! && !MsiStr!
set /a VPnumber-=1
GOTO vp-uninstall-selection-check-11
@pause


:vp-uninstall-selection-fin-11
echo Finished all tasks
echo Proceeding to Download the latest version of VEGAS Pro.
cd /d "%~dp0"
timeout /T 5 /nobreak >nul
GOTO install-11


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:install-prompt-11
cls
color 0C
echo/
echo You already have VEGAS Pro downloaded
echo/
echo       1) Download it again
echo       2) Install the downloaded version (patch is not gauranteed)
echo       3) Cancel and go back
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO alrDown-11
IF ERRORLEVEL 2  GOTO install-11-skip
IF ERRORLEVEL 1  GOTO install-11
echo/

:install-11
cd /d "%~dp0"
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\VEGAS*.exe" GOTO install-prompt-11
:: gdown command
gdown --folder 1CfHOmkla8pim4jH2xBFLeBdUFCLHWVh4 -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
GOTO install-11-skip
:install-11-skip
echo Installing Vegas Pro
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Pro*.exe) do "%%~fa" /wait
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Deep*.exe) do "%%~fa" /wait
echo Installation is finished
timeout /T 3 /nobreak >nul
echo Creating a Backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK*" /I /Q /Y /F
echo Created "vegas210.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein_x64.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
timeout /T 5 /nobreak >nul
echo/
echo Patching Vegas Pro
xcopy ".\Installer-files\Vegas Pro\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll*" /I /Q /Y /F >nul
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas210.exe" 2>nul
del ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" 2>nul
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-11
cls
color 0C
echo Uninstalling any known installation of Vegas Pro
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-11
GOTO  install-11
:removeVeg-11
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-11



:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 2
:12
cls
color 0C
if %getOptionPlugSkip% EQU 1 GOTO install-12
echo/
:: Check if vegas is already installed
echo Checking for other installations...
GOTO VP-Install-Check-12

:VP-Install-Check-12
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
for /f %%i in ("%LOGFILE%") do set size=%%~zi
if %size% EQU 0 GOTO install-12
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
echo/
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo/
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-12
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
echo Proceeding to Download the latest version of VEGAS Pro.
cd /d "%~dp0"
timeout /T 5 /nobreak >nul
GOTO install-12


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:install-prompt-12
cls
color 0C
echo/
echo You already have VEGAS Pro downloaded
echo/
echo       1) Download it again
echo       2) Install the downloaded version (patch is not gauranteed)
echo       3) Cancel and go back
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO alrDown-12
IF ERRORLEVEL 2  GOTO install-12-skip
IF ERRORLEVEL 1  GOTO install-12
echo/

:install-12
cd /d "%~dp0"
cls
color 0C
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\VEGAS_Pro*.exe" GOTO install-prompt-11
:: gdown command
gdown --folder 12DW0zJtyAb_YR7W9Y43CGwAqAH60YblD -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
GOTO install-12-skip
:install-12-skip
echo Installing Vegas Pro
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Pro*.exe) do "%%~fa" /wait /s /v/qb
echo Installation is finished
timeout /T 3 /nobreak >nul
echo Creating a Backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK*" /I /Q /Y /F
echo Created "vegas210.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein_x64.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
timeout /T 5 /nobreak >nul
echo/
echo Patching Vegas Pro
xcopy ".\Installer-files\Vegas Pro\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll*" /I /Q /Y /F >nul
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas210.exe" 2>nul
del ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" 2>nul
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-12
cls
color 0C
echo Uninstalling any known installation of Vegas Pro
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-12
GOTO  install-12
:removeVeg-12
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-12


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 3
:13
color 0C
cls
if %getOptionPlugSkip% EQU 1 GOTO install-13
echo/
:: Check if vegas deep learning modules is already installed
echo Checking if Vegas Pro Deep Learning Modules is already installed
GOTO VP-Install-Check-13

:VP-Install-Check-13
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
for /f %%i in ("%LOGFILE%") do set size=%%~zi
if %size% EQU 0 GOTO install-13
GOTO alrDown-13

:alrDown-13
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
GOTO vp-dlm-parse-continue13

:: Subroutine to write later during the script.
:vp-dlm-parse13
setLocal
for /f "eol=- tokens=* delims= " %%T in ('find "Deep Learning Models" VP-Installations-found-output.txt') do (
	set tempvar13=%%T
   ::echo.%%T
   echo !tempvar13:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
exit /B


:vp-dlm-parse-continue13
:: Trims down output and removes duplicate entries
setLocal
for /f "eol=- tokens=* delims= " %%T in ('find "Deep Learning Models" VP-Installations-found-output.txt') do (
	set tempvar13=%%T
   ::echo.%%T
   echo  !tempvar13:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
cd /d "%~dp0"
echo/
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo/
echo/
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-13
IF ERRORLEVEL 1  GOTO select-vp-uninstall-13
echo/

:select-vp-uninstall-13
color 0C
cls
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
call :vp-dlm-parse13 > "VP-Uninstall-DLM-Selection.txt"
echo/
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo/
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call %jrepl% "[ \t]+(?=\||$)" "" /f "VP-Uninstall-DLM-Selection.txt" /o -
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set VP-Uninst-Select2="%~dp0Installer-files\Installer-Scripts\Settings\VP-Uninstall-DLM-Selection-output.txt"
if exist %VP-Uninst-Select2% del %VP-Uninst-Select2%
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (VP-Uninstall-DLM-Selection.txt) do (
  set "Line_!Counter!=%%x"
  set /a Counter+=1
)
set /a NumLines=Counter - 1
rem or, for arbitrary file lengths:
for /l %%x in (1,1,%NumLines%) do echo  %%x - !Line_%%x!
%Print%{0;185;255} %Counter% - ALL OPTIONS \n
echo/
echo ---------------------------------
GOTO getOptions13
:: Prompt user choices of all detected VP installations, and asks for multi-choice input
:getOptions13
%Print%{231;72;86}Type your choices with a space after each choice 
%Print%{244;255;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "

if not defined choices ( 
    echo Please enter a valid option
    goto getOptions13
    )

for %%a in (%choices%) do if %%a EQU %Counter% set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option13-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError13
GOTO vp-uninstall-selection-prompt13
exit

:optionError13
color 0C
echo/
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptions13

:option13-1
>> %VP-Uninst-Select2% echo !Line_1!
exit /B

:option13-2
>> %VP-Uninst-Select2% echo !Line_2!
exit /B

:option13-3
>> %VP-Uninst-Select2% echo !Line_3!
exit /B

:option13-4
>> %VP-Uninst-Select2% echo !Line_4!
exit /B

:option13-5
>> %VP-Uninst-Select2% echo !Line_5!
exit /B

:option13-6
>> %VP-Uninst-Select2% echo !Line_6!
exit /B

:option13-7
>> %VP-Uninst-Select2% echo !Line_7!
exit /B

:option13-8
>> %VP-Uninst-Select2% echo !Line_8!
exit /B

:option13-9
>> %VP-Uninst-Select2% echo !Line_9!
exit /B

:option13-10
>> %VP-Uninst-Select2% echo !Line_10!
exit /B

:vp-uninstall-selection-prompt13
cls
echo/
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo/
type %VP-Uninst-Select2%
echo/
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO VP-Install-Check-13
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue13
echo/

:vp-uninstall-selection-continue13
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
:: Parses each line in VP-Uninstall-Selection.txt to a variable
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (VP-Uninstall-DLM-Selection-output.txt) do (
  set "Line_Select_!Counter!=%%x"
  set /a Counter+=1
)

:: Parses each line in VP-Uninstall-Selection.txt to a variable number counter
:: Each loop will subtract -1 from the variable, until 0. Once 0 it continues the script
:: Changing directory is needed
cls
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" VP-Uninstall-DLM-Selection-output.txt | find /C ":""
for /f %%U in ('!cmd!') do set VPnumber=%%U
GOTO vp-uninstall-selection-check-13
:vp-uninstall-selection-check-13
:: Loop to check if VPnumber variable is 0 or not.
%Print%{0;255;50} %VPnumber% Uninstalls Remaining \n
IF %VPnumber% EQU 0 GOTO vp-uninstall-selection-fin-13
IF %VPnumber% GEQ 1 GOTO vp-uninstall-selection-start13-1

:vp-uninstall-selection-start13-1
color 0C
@echo off
%Print%{244;255;0} !Line_Select_%VPnumber%! 2>nul \n
For /F Delims^=^ EOL^=^  %%G In ('%SystemRoot%\System32\reg.exe Query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "!Line_Select_%VPnumber%!" /D /E 2^>NUL') Do @For /F "EOL=H Tokens=2,*" %%H In ('%SystemRoot%\System32\reg.exe Query "%%G" /V "UninstallString" 2^>NUL') Do @Set MsiStr=%%I && set MsiStr=!MsiStr:/I=/X! && !MsiStr!
set /a VPnumber-=1
GOTO vp-uninstall-selection-check-13
@pause


:vp-uninstall-selection-fin-13
echo Finished all tasks
echo Proceeding to Download the latest version of VEGAS Pro Deep Learning Models.
cd /d "%~dp0"
timeout /T 5 /nobreak >nul
GOTO install-13


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:install-prompt-13
cls
color 0C
echo/
echo You already have VEGAS Pro Deep Learning Models downloaded
echo/
echo       1) Download it again
echo       2) Install the downloaded version
echo       3) Cancel and go back
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 3  GOTO alrDown-13
IF ERRORLEVEL 2  GOTO install-13-skip
IF ERRORLEVEL 1  GOTO install-13
echo/

:install-13
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 1g3jkCxUS87uylAvzxl0EL8dwUAlN7PCO -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
GOTO install-13-skip
:install-13-skip
echo Installing Deep Learning Modules
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Deep*.exe) do "%%~fa" /wait /s /v/qb
echo Installation is finished
timeout /T 3 /nobreak >nul
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-13
cls
color 0C
echo Uninstalling any known installation of Vegas Pro Deep Learning Modules
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (VEGAS_Deep*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-13
GOTO  install-13
:removeVeg-13
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-13


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 4
:14
cls
echo/
:: Check if vegas is already installed
echo Checking if Vegas Pro is already installed
if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\" GOTO install-14
echo Vegas Pro isn't installed, please select the menu option to download Vegas Pro
timeout /T 7 /nobreak >nul
GOTO Main

:install-14
cd /d "%~dp0"
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 1Tfb3iMF3lUZx-t96eEuflkZliBvPTT3k -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
echo Creating a Backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK*" /I /Q /Y /F
echo Created "vegas210.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK*" /I /Q /Y /F
echo Created "Protein_x64.4.2.dll.BAK" in "C:\Program Files\VEGAS\Protein\VEGAS Pro 21.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 21.0"
timeout /T 5 /nobreak >nul
echo/
echo Patching Vegas Pro
xcopy ".\Installer-files\Vegas Pro\vegas210.exe" "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll*" /I /Q /Y /F >nul
xcopy ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll*" /I /Q /Y /F >nul
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas210.exe" 2>nul
del ".\Installer-files\Vegas Pro\ScriptPortal.Vegas.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\Protein_x64.4.2.dll" 2>nul
del ".\Installer-files\Vegas Pro\TransitionWPFLibrary.dll" 2>nul
GOTO Main




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:2
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
echo/
GOTO SelectPlugins

:SelectPlugins
cd /d "%~dp0"
color 0C
::Variable for WinRAR
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
:: Variables for each plugin, to call later on
set "BFX-Sapphire=Boris FX Sapphire OFX by Nifer.rar"
set "BFX-Continuum=Boris FX Continuum Complete OFX by Nifer.rar"
set "BFX-Mocha=Boris FX Mocha Pro OFX by Nifer.rar"
set "BFX-Mocha-Vegas=Boris FX Mocha Vegas by Nifer.rar"
set "BFX-Silhouette=Boris FX Silhouette by Nifer.rar"
set "FXH-Ignite=FXHOME Ignite Pro OFX by Nifer.rar"
set "MXN-MBL=MAXON Red Giant Magic Bullet Suite by Team V.R.rar"
set "MXN-Universe=MAXON Red Giant Universe by Team V.R.rar"
set "NFX-Titler=NewBlueFX Titler Pro 7 Ultimate by Nifer.rar"
set "NFX-TotalFX=NewBlueFX TotalFX 7 OFX by Nifer.rar"
set "RFX-Effections=REVisionFX Effections OFX by Team V.R.rar"
set "All-Plugins=All Plugins.rar"



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

:Plugin-Select-Start
setlocal ENABLEDELAYEDEXPANSION
color 0C
if %getOptionPlugSkip% EQU 1 GOTO Plug-Select-Continue-1
echo/
echo/
echo                 Loading...
cd /d "%~dp0"
SET LOGFILE3=".\Installer-files\Installer-Scripts\Settings\Plug-Installations-found.txt"
call :LogPlugList > %LOGFILE3%
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
setlocal enabledelayedexpansion
set Counter=1
for /f "tokens=* delims=" %%x in (Plug-Installations-found.txt) do (
  set "Line_Plug_Select_!Counter!=%%x"
  set /a Counter+=1
)
:: Parses each line in Plug-Installations-found.txt to a number counter
:: sets variables for each plugin to 0, counts later when checked.
set "cmd3=findstr /R /N "^^" Plug-Installations-found.txt | find /C ":""
for /f %%U in ('!cmd3!') do set PlugNumber=%%U
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
GOTO Plug-Select-Counter
:Plug-Select-Counter
IF %PlugNumber% EQU 0 GOTO Plug-Select-Continue-1
IF %PlugNumber% GEQ 1 GOTO Plug-Select-Loop-1
:Plug-Select-Loop-1
if /I "!Line_Plug_Select_%PlugNumber%:~0,26!" == "Boris FX Sapphire Plug-ins" set /a plugcountbfxsaph+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,23!" == "Boris FX Mocha Plug-ins" set /a plugcountbfxmocha+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,28!" == "VEGAS Pro 21.0 (Mocha VEGAS)" set plugcountvpbfxmocha=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,18!" == "Boris FX Continuum" set /a plugcountbfxcontin+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,19!" == "Boris FX Silhouette" set /a plugcountbfxsilho+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,10!" == "Ignite Pro" set /a plugcountignite+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,19!" == "Ignite Pro by Nifer" set /a plugcountignitenifer+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,18!" == "Magic Bullet Suite" set /a plugcountmbl+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,8!" == "Universe" set /a plugcountuni+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,29!" == "NewBlue Titler Pro 7 Ultimate" set /a plugcountnfxtitler+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,17!" == "NewBlue TotalFX 7" set /a plugcountnfxtotal+=1
if /I "!Line_Plug_Select_%PlugNumber%:~0,20!" == "RE:Vision Effections" set /a plugcountrfxeff+=1
set /a PlugNumber-=1
GOTO Plug-Select-Counter

:Plug-Select-Continue-1
if not defined getOptionPlugSkip set getOptionPlugSkip=0
if not defined getOptionsPlugCountCheck set getOptionsPlugCountCheck=0
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
cls
echo/
color 0C
Echo ***************************************************************
Echo ***    (Option #2) Selecting 3rd Party Plugins for OFX      ***
Echo ***************************************************************
echo/
%Print%{255;255;255}	 Available plugins to Download: \n
echo         --------------------------------
echo/
if %plugcountbfxsaph% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Sapphire 
if %plugcountbfxsaph% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Sapphire 
if %plugcountbfxsaph% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Sapphire 
if %plugcountbfxsaph% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            1) BORIS FX - Sapphire 
if %plugcountbfxsaph% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            1) BORIS FX - Sapphire 
if %plugcountbfxsaph% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            1) BORIS FX - Sapphire 
if %plugcountbfxsaph% GEQ 0 %Print%{0;185;255}(670 MB) \n
if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% LEQ 1 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{231;72;86}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{0;255;50}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% LEQ 1 %Print%{244;255;0}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 0 if %mochadisplay% LEQ 1 %Print%{0;185;255}(270 MB) \n
if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{231;72;86}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{0;255;50}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{244;255;0}            2) BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 0 if %mochadisplay% EQU 3 %Print%{0;185;255}(270 MB) \n
if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{231;72;86}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{0;255;50}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 2 %Print%{244;255;0}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{231;72;86}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{0;255;50}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 2 %Print%{244;255;0}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 0 if %mochadisplay% EQU 2 %Print%{0;185;255}(70 MB) \n
if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{231;72;86}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{0;255;50}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 if %mochadisplay% EQU 3 %Print%{244;255;0}            BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{231;72;86}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{0;255;50}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 if %mochadisplay% EQU 3 %Print%{244;255;0}            2) BORIS FX - Mocha VEGAS 
if %plugcountvpbfxmocha% GEQ 0 if %mochadisplay% EQU 3 %Print%{0;185;255}(70 MB) \n
if %plugcountbfxcontin% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            3) BORIS FX - Continuum Complete 
if %plugcountbfxcontin% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            3) BORIS FX - Continuum Complete 
if %plugcountbfxcontin% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            3) BORIS FX - Continuum Complete 
if %plugcountbfxcontin% GEQ 0 %Print%{0;185;255}(510 MB) \n
if %plugcountbfxsilho% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            BORIS FX - Silhouette 
if %plugcountbfxsilho% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            BORIS FX - Silhouette 
if %plugcountbfxsilho% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            BORIS FX - Silhouette 
if %plugcountbfxsilho% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            4) BORIS FX - Silhouette 
if %plugcountbfxsilho% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            4) BORIS FX - Silhouette 
if %plugcountbfxsilho% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            4) BORIS FX - Silhouette 
if %plugcountbfxsilho% GEQ 0 %Print%{0;185;255}(1.4 GB) \n
if %plugcountignite% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %plugcountignite% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %plugcountignite% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %plugcountignite% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            5) FXHOME - Ignite Pro 
if %plugcountignite% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            5) FXHOME - Ignite Pro 
if %plugcountignite% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            5) FXHOME - Ignite Pro
if %plugcountignite% GEQ 0 %Print%{0;185;255}(430 MB) \n
if %plugcountmbl% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            6) MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            6) MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            6) MAXON - Red Giant Magic Bullet Suite
if %plugcountmbl% GEQ 0 %Print%{0;185;255}(260 MB) \n
if %plugcountuni% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %plugcountuni% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %plugcountuni% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %plugcountuni% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            7) MAXON - Red Giant Universe 
if %plugcountuni% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            7) MAXON - Red Giant Universe 
if %plugcountuni% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            7) MAXON - Red Giant Universe
if %plugcountuni% GEQ 0 %Print%{0;185;255}(1.8 GB) \n
if %plugcountnfxtitler% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            8) NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            8) NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            8) NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% GEQ 0 %Print%{0;185;255}(630 MB) \n
if %plugcountnfxtotal% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            9) NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            9) NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            9) NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% GEQ 0 %Print%{0;185;255}(790 MB) \n
if %plugcountrfxeff% EQU 0 If %getOptionsPlugCountCheck% EQU 0 %Print%{231;72;86}            REVISIONFX - Effections 
if %plugcountrfxeff% EQU 1 If %getOptionsPlugCountCheck% EQU 0 %Print%{0;255;50}            REVISIONFX - Effections 
if %plugcountrfxeff% GEQ 2 If %getOptionsPlugCountCheck% EQU 0 %Print%{244;255;0}            REVISIONFX - Effections 
if %plugcountrfxeff% EQU 0 If %getOptionsPlugCountCheck% GEQ 1 %Print%{231;72;86}            10) REVISIONFX - Effections 
if %plugcountrfxeff% EQU 1 If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;255;50}            10) REVISIONFX - Effections 
if %plugcountrfxeff% GEQ 2 If %getOptionsPlugCountCheck% GEQ 1 %Print%{244;255;0}            10) REVISIONFX - Effections 
if %plugcountrfxeff% GEQ 0 %Print%{0;185;255}(50 MB) \n
echo/
If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;185;255}            11) ALL PLUGINS 
If %getOptionsPlugCountCheck% GEQ 1 %Print%{0;185;255}(7 GB) \n
echo/
If %getOptionPlugSkip% EQU 0 echo         --------------------------------
set "PLUGKEY0="
IF %plugcountbfxsaph% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxcontin% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxmocha% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxsilho% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountignite% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountmbl% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountuni% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountnfxtitler% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountnfxtotal% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountrfxeff% EQU 0 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF defined PLUGKEY0 (
%Print%{231;72;86}        Red =        not installed \n
)
set "PLUGKEY1="
IF %plugcountbfxsaph% EQU 1 set PLUGKEY1=1
IF %plugcountbfxcontin% EQU 1 set PLUGKEY1=1
IF %plugcountbfxmocha% EQU 1 set PLUGKEY1=1
IF %plugcountbfxsilho% EQU 1 set PLUGKEY1=1
IF %plugcountignite% EQU 1 set PLUGKEY1=1
IF %plugcountmbl% EQU 1 set PLUGKEY1=1
IF %plugcountuni% EQU 1 set PLUGKEY1=1
IF %plugcountnfxtitler% EQU 1 set PLUGKEY1=1
IF %plugcountnfxtotal% EQU 1 set PLUGKEY1=1
IF %plugcountrfxeff% EQU 1 set PLUGKEY1=1
IF defined PLUGKEY1 (
%Print%{0;255;50}        Green =      installed \n
)
set "PLUGKEY2="
IF %plugcountbfxsaph% GEQ 2 set PLUGKEY2=1
IF %plugcountbfxcontin% GEQ 2 set PLUGKEY2=1
IF %plugcountbfxmocha% GEQ 2 set PLUGKEY2=1
IF %plugcountbfxsilho% GEQ 2 set PLUGKEY2=1
IF %plugcountignite% GEQ 2 set PLUGKEY2=1
IF %plugcountmbl% GEQ 2 set PLUGKEY2=1
IF %plugcountuni% GEQ 2 set PLUGKEY2=1
IF %plugcountnfxtitler% GEQ 2 set PLUGKEY2=1
IF %plugcountnfxtotal% GEQ 2 set PLUGKEY2=1
IF %plugcountrfxeff% GEQ 2 set PLUGKEY2=1
IF defined PLUGKEY2 (
%Print%{244;255;0}        Yellow =     multiple installed [May detect AE plugins] \n
)
IF %getOptionsPlugCountCheck% EQU 1 GOTO getOptionsPlug
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

:getOptionsPlugUninstall-Error
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
if %getOptionPlugSkip% EQU 1 GOTO getOptionsPlugUninstall-Error
color 0c
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0Installer-files\Installer-Scripts\Settings"
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
for /f %%i in ("Plug-Uninstall-found.txt") do set size=%%~zi
if %size% EQU 0 GOTO getOptionsPlugUninstall-error
echo/
::::::::::::::::::::::::::::::::::::::::::::::::
:: loops through and trims duplicate entires.
type nul>Plug-Uninstall-found.txt
for /f "tokens=* delims=" %%a in (Plug-Installations-found.txt) do (
  findstr /ixc:"%%a" Plug-Uninstall-found.txt >nul || >>Plug-Uninstall-found.txt echo.%%a
)
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
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,19!" == "Boris FX Silhouette" >> %Plug-Uninstall-found% echo BORIS FX - Silhouette & set "PlugUninstall4=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,28!" == "VEGAS Pro 21.0 (Mocha VEGAS)" >> %Plug-Uninstall-found% echo BORIS FX - Mocha VEGAS & set "PlugUninstall5=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%!" == "Ignite Pro " >> %Plug-Uninstall-found% echo FXHOME - Ignite Pro & set "PlugUninstall6=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%!" == "Ignite Pro by Nifer " >> %Plug-Uninstall-found% echo FXHOME - Ignite Pro by Nifer & set "PlugUninstall7=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,18!" == "Magic Bullet Suite" >> %Plug-Uninstall-found% echo MAXON - Red Giant Magic Bullet Looks & set "PlugUninstall8=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,8!" == "Universe" >> %Plug-Uninstall-found% echo MAXON - Red Giant Universe & set "PlugUninstall9=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,29!" == "NewBlue Titler Pro 7 Ultimate" >> %Plug-Uninstall-found% echo NEWBLUEFX - Titler Pro 7 Ultimate & set "PlugUninstall10=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,17!" == "NewBlue TotalFX 7" >> %Plug-Uninstall-found% echo NEWBLUEFX - TotalFX 7 & set "PlugUninstall11=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
if /I "!Line_PlugUninst_%PlugUninstnumber%:~0,20!" == "RE:Vision Effections" >> %Plug-Uninstall-found% echo REVISIONFX - Effections & set "PlugUninstall12=!Line_PlugUninst_%PlugUninstnumber%!" & set /a PlugUninstnumber+=1 & GOTO Plug-Uninst-loopcheck
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
set plugcountbfxsaphfinal=1 
exit /B

:optionPlug-2
set plugcountbfxmochafinal=1
exit /B

:optionPlug-3
set plugcountbfxcontinfinal=1
exit /B

:optionPlug-4
set plugcountbfxsilhofinal=1
exit /B

:optionPlug-5
set plugcountignitefinal=1
exit /B

:optionPlug-6
set plugcountmblfinal=1
exit /B

:optionPlug-7
set plugcountunifinal=1
exit /B

:optionPlug-8
set plugcountnfxtitlerfinal=1
exit /B

:optionPlug-9
set plugcountnfxtotalfinal=1
exit /B

:optionPlug-10
set plugcountrfxefffinal=1
exit /B

:Plug-Select-All
set plugcountall=1
set plugcountbfxsaphfinal=1
set plugcountbfxmochafinal=1
set plugcountbfxcontinfinal=1
set plugcountbfxsilhofinal=1
set plugcountignitefinal=1
set plugcountmblfinal=1
set plugcountunifinal=1
set plugcountnfxtitlerfinal=1
set plugcountnfxtotalfinal=1
set plugcountrfxefffinal=1
GOTO getOptionPlug-Confirm-Prompt

:getOptionPlug-Confirm-Prompt
if not defined plugcountall set plugcountall=0
color 0C
cls
echo/
%Print%{231;72;86} Are you sure you want to install these selected plugins? \n
echo         --------------------------------
echo/
if %plugcountbfxsaph% EQU 0 If %plugcountbfxsaphfinal% EQU 1 %Print%{231;72;86}            BORIS FX - Sapphire 
if %plugcountbfxsaph% EQU 1 If %plugcountbfxsaphfinal% EQU 1 %Print%{0;255;50}            BORIS FX - Sapphire 
if %plugcountbfxsaph% GEQ 2 If %plugcountbfxsaphfinal% EQU 1 %Print%{244;255;0}            BORIS FX - Sapphire 
if %plugcountbfxsaph% GEQ 0 If %plugcountbfxsaphfinal% EQU 1 %Print%{0;185;255}(670 MB) \n
if %plugcountbfxmocha% EQU 0 If %plugcountbfxmochafinal% EQU 1 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% EQU 1 If %plugcountbfxmochafinal% EQU 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 2 If %plugcountbfxmochafinal% EQU 1 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %plugcountbfxmocha% GEQ 0 If %plugcountbfxmochafinal% EQU 1 %Print%{0;185;255}(270 MB) \n
if %plugcountbfxcontin% EQU 0 If %plugcountbfxcontinfinal% EQU 1 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% EQU 1 If %plugcountbfxcontinfinal% EQU 1 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% GEQ 2 If %plugcountbfxcontinfinal% EQU 1 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %plugcountbfxcontin% GEQ 0 If %plugcountbfxcontinfinal% EQU 1 %Print%{0;185;255}(510 MB) \n
if %plugcountbfxsilho% EQU 0 If %plugcountbfxsilhofinal% EQU 1 %Print%{231;72;86}            BORIS FX - Silhouette 
if %plugcountbfxsilho% EQU 1 If %plugcountbfxsilhofinal% EQU 1 %Print%{0;255;50}            BORIS FX - Silhouette 
if %plugcountbfxsilho% GEQ 2 If %plugcountbfxsilhofinal% EQU 1 %Print%{244;255;0}            BORIS FX - Silhouette 
if %plugcountbfxsilho% GEQ 0 If %plugcountbfxsilhofinal% EQU 1 %Print%{0;185;255}(1.4 GB) \n
if %plugcountignite% EQU 0 If %plugcountignitefinal% EQU 1 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %plugcountignite% EQU 1 If %plugcountignitefinal% EQU 1 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %plugcountignite% GEQ 2 If %plugcountignitefinal% EQU 1 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %plugcountignite% GEQ 0 If %plugcountignitefinal% EQU 1 %Print%{0;185;255}(430 MB) \n
if %plugcountmbl% EQU 0 If %plugcountmblfinal% EQU 1 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% EQU 1 If %plugcountmblfinal% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% GEQ 2 If %plugcountmblfinal% EQU 1 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %plugcountmbl% GEQ 0 If %plugcountmblfinal% EQU 1 %Print%{0;185;255}(260 MB) \n
if %plugcountuni% EQU 0 If %plugcountunifinal% EQU 1 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %plugcountuni% EQU 1 If %plugcountunifinal% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %plugcountuni% GEQ 2 If %plugcountunifinal% EQU 1 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %plugcountuni% GEQ 0 If %plugcountunifinal% EQU 1 %Print%{0;185;255}(1.8 GB) \n
if %plugcountnfxtitler% EQU 0 If %plugcountnfxtitlerfinal% EQU 1 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% EQU 1 If %plugcountnfxtitlerfinal% EQU 1 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% GEQ 2 If %plugcountnfxtitlerfinal% EQU 1 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %plugcountnfxtitler% GEQ 0 If %plugcountnfxtitlerfinal% EQU 1 %Print%{0;185;255}(630 MB) \n
if %plugcountnfxtotal% EQU 0 If %plugcountnfxtotalfinal% EQU 1 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% EQU 1 If %plugcountnfxtotalfinal% EQU 1 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% GEQ 2 If %plugcountnfxtotalfinal% EQU 1 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %plugcountnfxtotal% GEQ 0 If %plugcountnfxtotalfinal% EQU 1 %Print%{0;185;255}(790 MB) \n
if %plugcountrfxeff% EQU 0 If %plugcountrfxefffinal% EQU 1 %Print%{231;72;86}            REVISIONFX - Effections 
if %plugcountrfxeff% EQU 1 If %plugcountrfxefffinal% EQU 1 %Print%{0;255;50}            REVISIONFX - Effections 
if %plugcountrfxeff% GEQ 2 If %plugcountrfxefffinal% EQU 1 %Print%{244;255;0}            REVISIONFX - Effections 
if %plugcountrfxeff% GEQ 0 If %plugcountrfxefffinal% EQU 1 %Print%{0;185;255}(50 MB) \n
echo/
If %getOptionPlugSkip% EQU 0 echo         --------------------------------
set "PLUGKEY0="
IF %plugcountbfxsaph% EQU 0 if %plugcountbfxsaphfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxcontin% EQU 0 if %plugcountbfxcontinfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxmocha% EQU 0 if %plugcountbfxmochafinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountbfxsilho% EQU 0 if %plugcountbfxsilhofinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountignite% EQU 0 if %plugcountignitefinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountmbl% EQU 0 if %plugcountmblfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountuni% EQU 0 if %plugcountunifinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountnfxtitler% EQU 0 if %plugcountnfxtitlerfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountnfxtotal% EQU 0 if %plugcountnfxtotalfinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF %plugcountrfxeff% EQU 0 if %plugcountrfxefffinal% EQU 1 If %getOptionPlugSkip% EQU 0 set PLUGKEY0=1
IF defined PLUGKEY0 (
%Print%{231;72;86}        Red =        not installed \n
)
set "PLUGKEY1="
IF %plugcountbfxsaph% EQU 1 if %plugcountbfxsaphfinal% EQU 1 set PLUGKEY1=1
IF %plugcountbfxcontin% EQU 1 if %plugcountbfxcontinfinal% EQU 1 set PLUGKEY1=1
IF %plugcountbfxmocha% EQU 1 if %plugcountbfxmochafinal% EQU 1 set PLUGKEY1=1
IF %plugcountbfxsilho% EQU 1 if %plugcountbfxsilhofinal% EQU 1 set PLUGKEY1=1
IF %plugcountignite% EQU 1 if %plugcountignitefinal% EQU 1 set PLUGKEY1=1
IF %plugcountmbl% EQU 1 if %plugcountmblfinal% EQU 1 set PLUGKEY1=1
IF %plugcountuni% EQU 1 if %plugcountunifinal% EQU 1 set PLUGKEY1=1
IF %plugcountnfxtitler% EQU 1 if %plugcountnfxtitlerfinal% EQU 1 set PLUGKEY1=1
IF %plugcountnfxtotal% EQU 1 if %plugcountnfxtotalfinal% EQU 1 set PLUGKEY1=1
IF %plugcountrfxeff% EQU 1 if %plugcountrfxefffinal% EQU 1 set PLUGKEY1=1
IF defined PLUGKEY1 (
%Print%{0;255;50}        Green =      installed \n
)
set "PLUGKEY2="
IF %plugcountbfxsaph% GEQ 2 if %plugcountbfxsaphfinal% EQU 1 set PLUGKEY2=1
IF %plugcountbfxcontin% GEQ 2 if %plugcountbfxcontinfinal% EQU 1 set PLUGKEY2=1
IF %plugcountbfxmocha% GEQ 2 if %plugcountbfxmochafinal% EQU 1 set PLUGKEY2=1
IF %plugcountbfxsilho% GEQ 2 if %plugcountbfxsilhofinal% EQU 1 set PLUGKEY2=1
IF %plugcountignite% GEQ 2 if %plugcountignitefinal% EQU 1 set PLUGKEY2=1
IF %plugcountmbl% GEQ 2 if %plugcountmblfinal% EQU 1 set PLUGKEY2=1
IF %plugcountuni% GEQ 2 if %plugcountunifinal% EQU 1 set PLUGKEY2=1
IF %plugcountnfxtitler% GEQ 2 if %plugcountnfxtitlerfinal% EQU 1 set PLUGKEY2=1
IF %plugcountnfxtotal% GEQ 2 if %plugcountnfxtotalfinal% EQU 1 set PLUGKEY2=1
IF %plugcountrfxeff% GEQ 2 if %plugcountrfxefffinal% EQU 1 set PLUGKEY2=1
IF defined PLUGKEY2 (
%Print%{244;255;0}        Yellow =     multiple installed [May detect AE plugins] \n
)

echo         --------------------------------
echo/
if %plugcountall% EQU 1 %Print%{231;72;86}         ALL plugins are around
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

:Plug-Already-Installed-Prompt
cls
color 0C
echo/
%Print%{231;72;86} You already have these items downloaded \n
echo/
if %plugcountbfxsaphAlr% EQU 1 %Print%{244;255;0}BORIS FX - Sapphire \n
if %plugcountbfxmochaAlr% EQU 1 %Print%{244;255;0}BORIS FX - Mocha Pro \n
if %plugcountbfxcontinAlr% EQU 1 %Print%{244;255;0}BORIS FX - Continuum Complete \n
if %plugcountbfxsilhoAlr% EQU 1 %Print%{244;255;0}BORIS FX - Silhouette \n
if %plugcountigniteAlr% EQU 1 %Print%{244;255;0}FXHOME - Ignite Pro \n
if %plugcountmblAlr% EQU 1 %Print%{244;255;0}MAXON - Red Giant Magic Bullet Suite \n
if %plugcountuniAlr% EQU 1 %Print%{244;255;0}MAXON - Red Giant Universe \n
if %plugcountnfxtitlerAlr% EQU 1 %Print%{244;255;0}NEWBLUEFX - Titler Pro 7 \n
if %plugcountnfxtotalAlr% EQU 1 %Print%{244;255;0}NEWBLUEFX - TotalFX 7 \n
if %plugcountrfxeffAlr% EQU 1 %Print%{244;255;0}REVISIONFX - Effections \n
echo/
%Print%{231;72;86} Do you want to re-download? \n
echo/
%Print%{231;72;86} 1) Re-download all items \n
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

:Plug-Already-Installed-skip
IF %plugcountbfxsaphAlr% EQU 1 set plugcountbfxsaphfinal=0
IF %plugcountbfxmochaAlr% EQU 1 set plugcountbfxmochafinal=0
IF %plugcountbfxcontinAlr% EQU 1 set plugcountbfxcontinfinal=0
IF %plugcountbfxsilhoAlr% EQU 1 set plugcountbfxsilhofinal=0
IF %plugcountigniteAlr% EQU 1 set plugcountignitefinal=0
IF %plugcountmblAlr% EQU 1 set plugcountmblfinal=0
IF %plugcountuniAlr% EQU 1 set plugcountunifinal=0
IF %plugcountnfxtitlerAlr% EQU 1 set plugcountnfxtitlerfinal=0
IF %plugcountnfxtotalAlr% EQU 1 set plugcountnfxtotalfinal=0
IF %plugcountrfxeffAlr% EQU 1 set plugcountrfxefffinal=0

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
IF defined PLUGKEY11 (
GOTO Plug-Select-Queue-Setup-1
)
GOTO Plug-Select-error
:Plug-Select-error
cls
color 0C
echo Plugin Queue is empty
echo Returning to main menu...
timeout /T 5 /nobreak >nul
set getOptionsPlugCountCheck=0 & GOTO Pre-SelectPlugins

:Plug-Select-Queue-Setup
cd /d "%~dp0"
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
:: Check selected plugins if it's already downloaded previously
if %plugcountbfxsaphfinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX Sapph*" set plugcountbfxsaphAlr=1
if %plugcountbfxmochafinal% EQU 1  if exist ".\Installer-files\Plugins\Boris FX Mocha*" set plugcountbfxmochaAlr=1
if %plugcountbfxcontinfinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX Cont*" set plugcountbfxcontinAlr=1
if %plugcountbfxsilhofinal% EQU 1 if exist ".\Installer-files\Plugins\Boris FX Silho*" set plugcountbfxsilhoAlr=1
if %plugcountignitefinal% EQU 1 if exist ".\Installer-files\Plugins\FXHOME Ign*" set plugcountigniteAlr=1
if %plugcountmblfinal% EQU 1 if exist ".\Installer-files\Plugins\MAXON Red Giant Magic Bull*" set plugcountmblAlr=1
if %plugcountunifinal% EQU 1 if exist ".\Installer-files\Plugins\MAXON Red Giant Uni*" set plugcountuniAlr=1
if %plugcountnfxtitlerfinal% EQU 1 if exist ".\Installer-files\Plugins\NewBlueFX Titler*" set plugcountnfxtitlerAlr=1
if %plugcountnfxtotalfinal% EQU 1 if exist ".\Installer-files\Plugins\NewBlueFX Total*" set plugcountnfxtotalAlr=1
if %plugcountrfxefffinal% EQU 1 if exist ".\Installer-files\Plugins\REVisionFX Eff*" set plugcountrfxeffAlr=1
set "PLUGKEY8="
IF %plugcountbfxsaphAlr% EQU 1 set PLUGKEY8=1
IF %plugcountbfxmochaAlr% EQU 1 set PLUGKEY8=1
IF %plugcountbfxcontinAlr% EQU 1 set PLUGKEY8=1
IF %plugcountbfxsilhoAlr% EQU 1 set PLUGKEY8=1
IF %plugcountigniteAlr% EQU 1 set PLUGKEY8=1
IF %plugcountmblAlr% EQU 1 set PLUGKEY8=1
IF %plugcountuniAlr% EQU 1 set PLUGKEY8=1
IF %plugcountnfxtitlerAlr% EQU 1 set PLUGKEY8=1
IF %plugcountnfxtotalAlr% EQU 1 set PLUGKEY8=1
IF %plugcountrfxeffAlr% EQU 1 set PLUGKEY8=1
IF defined PLUGKEY8 (
GOTO Plug-Already-Installed-Prompt
)
GOTO Plug-Select-Queue-Setup-1
:Plug-Select-Queue-Setup-1
:: Set variables for each selected plugin, add counter for task countdown
set PlugQueueCounter=0
set PlugQueueCounterPre=1
if not defined Mocha-veg-ofx set Mocha-veg-ofx=0
if %plugcountbfxmochafinal% EQU 1 if %Mocha-veg-ofx% EQU 0 GOTO Mocha-veg-ofx-prompt
if %plugcountbfxsaphfinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountbfxmochafinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountbfxcontinfinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountbfxsilhofinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountignitefinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountmblfinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountunifinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountnfxtitlerfinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountnfxtotalfinal% EQU 1 set /a PlugQueueCounter+=1
if %plugcountrfxefffinal% EQU 1 set /a PlugQueueCounter+=1
cls
GOTO Plug-Select-Queue-Setup-2
:Plug-Select-Queue-Setup-2
:: set first found selected plugin in queue, after queue, minus 1 from queue counter.
if %plugcountbfxsaphfinal% EQU 1 set plugin1queue=1 & set plugin1queueInst=1
if %plugcountbfxmochafinal% EQU 1 set plugin2queue=1 & set plugin2queueInst=1
if %plugcountbfxcontinfinal% EQU 1 set plugin3queue=1 & set plugin3queueInst=1
if %plugcountbfxsilhofinal% EQU 1 set plugin4queue=1 & set plugin4queueInst=1
if %plugcountignitefinal% EQU 1 set plugin5queue=1 & set plugin5queueInst=1
if %plugcountmblfinal% EQU 1 set plugin6queue=1 & set plugin6queueInst=1
if %plugcountunifinal% EQU 1 set plugin7queue=1 & set plugin7queueInst=1
if %plugcountnfxtitlerfinal% EQU 1 set plugin8queue=1 & set plugin8queueInst=1
if %plugcountnfxtotalfinal% EQU 1 set plugin9queue=1 & set plugin9queueInst=1
if %plugcountrfxefffinal% EQU 1 set plugin10queue=1 & set plugin10queueInst=1
GOTO Plug-Select-Queue-Setup-3
:Plug-Select-Queue-Setup-3
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
IF defined PLUGKEY4 GOTO Plug-Queue-Install
IF not defined PLUGKEY4 GOTO Plugin-Select-Extract


:Mocha-veg-ofx-prompt
cls
color 0C
echo  Before continuing...
echo  There are two available verisons of Boris FX Mocha
echo/
%Print%{204;204;204} 1 is a specially made version of Mocha by Boris FX for Vegas Pro 21 ONLY. \n
%Print%{244;255;0} has better tracking integration with Vegas Pro, and may be more updated. \n
%Print%{0;185;255} Downlad size = (70 MB) \n
echo/
%Print%{204;204;204} 2 is the OFX version of Mocha by Boris FX. \n
%Print%{244;255;0} It works for ALL versions of Vegas Pro, \n
%Print%{244;255;0} has more features like 3d camera tracker, and may be more outdated. \n
%Print%{0;185;255} Downlad size = (270 MB) \n
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
cd /d "%~dp0"
color 0C
%Print%{0;255;50}%PlugQueueCounterPre% out of %PlugQueueCounter% \n
echo Initializing Download...
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

:Plug-Queue-1
:: Boris FX Sapphire
gdown --folder 1FowQpPfNNwHeykCfHCEfeeS1WkZdVh_U -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-1-error
set /a PlugQueueCounterPre+=1
set plugcountbfxsaphfinal=0
set plugin1queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-1-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin1results% LEQ 2 set plugin1results=3
if %plugin1results% GEQ 3 set /a plugin1results+=1
if %plugin1results% GTR 4 set plugin1results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-2-1
:: Boris FX Mocha Pro OFX
gdown --folder 1MD9cFQVUPIAhOuO5BC99MTlCJRuPyBLQ -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-2-1-error
set /a PlugQueueCounterPre+=1
set plugcountbfxmochafinal=0
set plugin2queue=0
GOTO Plug-Select-Queu0-Setup-3
:Plug-Queue-2-1-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin2results% LEQ 2 set plugin2results=3
if %plugin2results% GEQ 3 set /a plugin2results+=1
if %plugin2results% GTR 4 set plugin2results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-2-2
:: Boris FX Mocha Vegas
gdown --folder 1fcUcrYAqA18Ym-y4vgSAGOlnJUvMboaT -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-2-2-error
set /a PlugQueueCounterPre+=1
set plugcountbfxmochafinal=0
set plugin2queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-2-2-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin2results% LEQ 2 set plugin2results=3
if %plugin2results% GEQ 3 set /a plugin2results+=1
if %plugin2results% GTR 4 set plugin2results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-3
:: Boris FX Continuum
gdown --folder 1CN3oJ4D2FPO3S9joBEjFtdlOuQD9H6QJ -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-3-error
set /a PlugQueueCounterPre+=1
set plugcountbfxcontinfinal=0
set plugin3queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-3-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin3results% LEQ 2 set plugin3results=3
if %plugin3results% GEQ 3 set /a plugin3results+=1
if %plugin3results% GTR 4 set plugin3results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-4
:: Boris FX Silhouette
gdown --folder 18GUz5M02QdInmQlQj8o-ky-HB7A0Dba4 -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-4-error
set /a PlugQueueCounterPre+=1
set plugcountbfxsilhofinal=0
set plugin4queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-4-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin4results% LEQ 2 set plugin4results=3
if %plugin4results% GEQ 3 set /a plugin4results+=1
if %plugin4results% GTR 4 set plugin4results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-5
:: FXHome Ignite Pro
gdown --folder 1RTzgwdYPiaTCjGosGJzY1w7LUPsvI_Gt -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-5-error
set /a PlugQueueCounterPre+=1
set plugcountignitefinal=0
set plugin5queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-5-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin5results% LEQ 2 set plugin5results=3
if %plugin5results% GEQ 3 set /a plugin5results+=1
if %plugin5results% GTR 4 set plugin5results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-6
:: Maxon Red Giant Magic Bullet Suite
gdown --folder 1Khgki2-aJkTfMZx-9Sqn-ejbxhHDQZ4x -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-6-error
set /a PlugQueueCounterPre+=1
set plugcountmblfinal=0
set plugin6queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-6-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin6results% LEQ 2 set plugin6results=3
if %plugin6results% GEQ 3 set /a plugin6results+=1
if %plugin6results% GTR 4 set plugin6results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-7
:: Maxon Red Giant Universe
gdown --folder 1yhBAYDwoQ4XB9mbjno4hWLsC49hqmx9c -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-7-error
set /a PlugQueueCounterPre+=1
set plugcountunifinal=0
set plugin7queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-7-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin7results% LEQ 2 set plugin7results=3
if %plugin7results% GEQ 3 set /a plugin7results+=1
if %plugin7results% GTR 4 set plugin7results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-8
:: NewBlue FX Titler Pro
gdown --folder 1rFWk-RHqOLEel5rb_MUL4Xe9QUiy9HEb -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-8-error
set /a PlugQueueCounterPre+=1
set plugcountnfxtitlerfinal=0
set plugin8queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-8-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin8results% LEQ 2 set plugin8results=3
if %plugin8results% GEQ 3 set /a plugin8results+=1
if %plugin8results% GTR 4 set plugin8results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-9
:: NewBlue FX TotalFX
gdown --folder 1W-T_Yqra8kwOO_ZDmKJxCTKukmGwrQ1i -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-9-error
set /a PlugQueueCounterPre+=1
set plugcountnfxtotalfinal=0
set plugin9queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-9-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin9results% LEQ 2 set plugin9results=3
if %plugin9results% GEQ 3 set /a plugin9results+=1
if %plugin9results% GTR 4 set plugin9results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3

:Plug-Queue-10
:: REVision FX Effections
gdown --folder 1dLsCdncK5u9SpvT-zOCd6S4Pr1oIUC-f -O ".\Installer-files"
if errorlevel 1 GOTO Plug-Queue-10-error
set /a PlugQueueCounterPre+=1
set plugcountrfxefffinal=0
set plugin10queue=0
GOTO Plug-Select-Queue-Setup-3
:Plug-Queue-10-error
echo/
%Print%{255;0;0}GDown download Failed!
%Print%{231;72;86}Resetting GDown cache...
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{231;72;86}Re-trying download...
if %plugin10results% LEQ 2 set plugin10results=3
if %plugin10results% GEQ 3 set /a plugin10results+=1
if %plugin10results% GTR 4 set plugin10results=3 & GOTO Plugin-Select-Extract
GOTO Plug-Select-Queue-Setup-3


:Plugin-Select-Extract
cd /d "%~dp0"
cls
color 0C
echo Downloads Finished!
echo Renaming rar files
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha Pro*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Mocha Vegas*" "%BFX-Mocha-Vegas%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
color 0C
echo Extracting rar files
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO Plug-Select-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO Plug-Select-szip
:Plug-Select-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
color 0C
taskkill /f /im WinRAR.exe 2>nul
if %plugin1queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%BFX-Sapphire%" ".\Installer-files\Plugins" 2>nul
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 2 %winrar% x -o- ".\Installer-files\%BFX-Mocha%" ".\Installer-files\Plugins" 2>nul
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 1 %winrar% x -o- ".\Installer-files\%BFX-Mocha-Vegas%" ".\Installer-files\Plugins" 2>nul
if %plugin3queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%BFX-Continuum%" ".\Installer-files\Plugins" 2>nul
if %plugin4queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%BFX-Silhouette%" ".\Installer-files\Plugins" 2>nul
if %plugin5queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%FXH-Ignite%" ".\Installer-files\Plugins" 2>nul
if %plugin6queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%MXN-MBL%" ".\Installer-files\Plugins" 2>nul
if %plugin7queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%MXN-Universe%" ".\Installer-files\Plugins" 2>nul
if %plugin8queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%NFX-Titler%" ".\Installer-files\Plugins" 2>nul
if %plugin9queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%NFX-TotalFX%" ".\Installer-files\Plugins" 2>nul
if %plugin10queueInst% EQU 1 %winrar% x -o- ".\Installer-files\%RFX-Effections%" ".\Installer-files\Plugins" 2>nul
timeout /T 6 /nobreak >nul
GOTO Plug-Select-LOOP21
:Plug-Select-szip
cd /d "%~dp0\Installer-files"
if %plugin1queueInst% EQU 1 %szip% x -aos "%BFX-Sapphire%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 2 %szip% x -aos "%BFX-Mocha%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin2queueInst% EQU 1 if %Mocha-veg-ofx% EQU 1 %szip% x -aos "%BFX-Mocha-Vegas%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin3queueInst% EQU 1 %szip% x -aos "%BFX-Continuum%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin4queueInst% EQU 1 %szip% x -aos "%BFX-Silhouette%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin5queueInst% EQU 1 %szip% x -aos "%FXH-Ignite%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin6queueInst% EQU 1 %szip% x -aos "%MXN-MBL%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin7queueInst% EQU 1 %szip% x -aos "%MXN-Universe%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin8queueInst% EQU 1 %szip% x -aos "%NFX-Titler%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin9queueInst% EQU 1 %szip% x -aos "%NFX-TotalFX%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
if %plugin10queueInst% EQU 1 %szip% x -aos "%RFX-Effections%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO Plug-Select-CONTINUE21
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:Plug-Select-LOOP21
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO Plug-Select-CONTINUE21
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO Plug-Select-LOOP21
)
:Plug-Select-CONTINUE21
echo Cleaning up files...
del "%~dp0\Installer-files\%BFX-Sapphire%" 2>nul
del "%~dp0\Installer-files\%BFX-Continuum%" 2>nul
del "%~dp0\Installer-files\%BFX-Mocha%" 2>nul
del "%~dp0\Installer-files\%BFX-Mocha-Vegas%" 2>nul
del "%~dp0\Installer-files\%BFX-Silhouette%" 2>nul
del "%~dp0\Installer-files\%FXH-Ignite%" 2>nul
del "%~dp0\Installer-files\%MXN-MBL%" 2>nul
del "%~dp0\Installer-files\%MXN-Universe%" 2>nul
del "%~dp0\Installer-files\%NFX-Titler%" 2>nul
del "%~dp0\Installer-files\%NFX-TotalFX%" 2>nul
del "%~dp0\Installer-files\%RFX-Effections%" 2>nul
del "%~dp0\Installer-files\*.rar" 2>nul
echo/
echo Finished, Extracted to "\Installer-files\Plugins"
set pluginresultsEcounter=0
if %plugin1results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin2results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin3results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin4results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin5results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin6results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin7results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin8results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin9results% EQU 3 set /a pluginresultsEcounter+=1
if %plugin10results% EQU 3 set /a pluginresultsEcounter+=1
Timeout /T 5 /Nobreak >nul
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
Timeout /T 10 /Nobreak >nul
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
GOTO Plug-Select-autoinst0

:: 1st auto install
:Plug-Queue-Install-1
echo Launching auto install script for Boris FX Sapphire
for /D %%I in (".\Installer-files\Plugins\Boris FX Sapph*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-1
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Sapph*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin1queueInst=0
set plugin1results=1
GOTO Plug-Select-autoinst0
:no-auto-1
if %plugin1results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin1queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Sapphire.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin1queueInst=0
set plugin1results=2
GOTO Plug-Select-autoinst0

:: 2nd-1 auto install
:Plug-Queue-Install-2-1
echo Launching auto install script for Boris FX Mocha Pro OFX
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Pro*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Pro*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=1
GOTO Plug-Select-autoinst0
:no-auto-2
if %plugin2results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin2queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Mocha Pro OFX.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=2
GOTO Plug-Select-autoinst0

:: 2nd-2 auto install
:Plug-Queue-Install-2-2
echo Launching auto install script for Boris FX Mocha Vegas
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Vegas*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2-2
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Vegas*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=1
GOTO Plug-Select-autoinst0
:no-auto-2-2
if %plugin2results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin2queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Mocha Vegas.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin2queueInst=0
set plugin2results=2
GOTO Plug-Select-autoinst0

:: 3rd auto install
:Plug-Queue-Install-3
echo Launching auto install script for Boris FX Continuum Complete
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-3
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Cont*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin3queueInst=0
set plugin3results=1
GOTO Plug-Select-autoinst0
:no-auto-3
if %plugin3results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin3queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Continuum Complete.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin3queueInst=0
set plugin3results=2
GOTO Plug-Select-autoinst0

:: 4th auto install
:Plug-Queue-Install-4
echo Launching auto install script for Boris FX Silhouette
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-4
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Silho*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin4queueInst=0
set plugin4results=1
GOTO Plug-Select-autoinst0
:no-auto-4
if %plugin4results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin4queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for Boris FX Silhouette.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin4queueInst=0
set plugin4results=2
GOTO Plug-Select-autoinst0

:: 5th auto install
:Plug-Queue-Install-5
echo Launching auto install script for FXHOME Ignite Pro
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-5
for /D %%I in ("%~dp0\Installer-files\Plugins\FXHOME Ign*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin5queueInst=0
set plugin5results=1
GOTO Plug-Select-autoinst0
:no-auto-5
if %plugin5results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin5queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for FXHOME Ignite Pro.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin5queueInst=0
set plugin5results=2
GOTO Plug-Select-autoinst0

:: 6th auto install
:Plug-Queue-Install-6
echo Launching auto install script for MAXON Red Giant Magic Bullet Suite
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-6
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin6queueInst=0
set plugin6results=1
GOTO Plug-Select-autoinst0
:no-auto-6
if %plugin6results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin6queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for MAXON Red Giant Magic Bullet Suite.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin6queueInst=0
set plugin6results=2
GOTO Plug-Select-autoinst0

:: 7th auto install
:Plug-Queue-Install-7
echo Launching auto install script for MAXON Red Giant Universe
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-7
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Uni*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin7queueInst=0
set plugin7results=1
GOTO Plug-Select-autoinst0
:no-auto-7
if %plugin7results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin7queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for MAXON Red Giant Universe.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin7queueInst=0
set plugin7results=2
GOTO Plug-Select-autoinst0

:: 8th auto install
:Plug-Queue-Install-8
echo Launching auto install script for NewBlueFX Titler Pro 7 Ultimate
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-8
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Titler*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin8queueInst=0
set plugin8results=1
GOTO Plug-Select-autoinst0
:no-auto-8
if %plugin8results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin8queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for NewBlueFX Titler Pro 7 Ultimate.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin8queueInst=0
set plugin8results=2
GOTO Plug-Select-autoinst0

:: 9th auto install
:Plug-Queue-Install-9
echo Launching auto install script for NewBlueFX TotalFX 7
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-9
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Total*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin9queueInst=0
set plugin9results=1
GOTO Plug-Select-autoinst0
:no-auto-9
if %plugin9results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin9queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for NewBlueFX TotalFX 7.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin9queueInst=0
set plugin9results=2
GOTO Plug-Select-autoinst0

:: 10th auto install
:Plug-Queue-Install-10
echo Launching auto install script for REVisionFX Effections
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-10
for /D %%I in ("%~dp0\Installer-files\Plugins\REVisionFX Eff*") do start "" /wait "%%~I\INSTALL.cmd"
set /a PlugQueueCounterPre+=1
set plugin10queueInst=0
set plugin10results=1
GOTO Plug-Select-autoinst0
:no-auto-10
if %plugin10results% EQU 3 %PlugQueueCounter% set /a PlugQueueCounterPre+=1 & set plugin10queueInst=0 & GOTO Plug-Select-autoinst0
echo There is no auto install script for REVisionFX Effections.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
set /a PlugQueueCounterPre+=1
set plugin10queueInst=0
set plugin10results=2
GOTO Plug-Select-autoinst0



:: Display results of plugin process
:Plug-Queue-Results
cls
echo/
%Print%{204;204;204}           Plugin Process Results: \n
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
IF defined PLUGKEY3 (
%Print%{0;255;50}             Downloaded ^& Installed \n
%Print%{0;255;50}        -------------------------------- \n
)
echo/
if %plugin1results% EQU 1 %Print%{0;255;50}            BORIS FX - Sapphire 
if %plugin1results% EQU 1 %Print%{0;185;255}(670 MB) \n
if %plugin2results% EQU 1 %Print%{0;255;50}            BORIS FX - Continuum Complete 
if %plugin2results% EQU 1 %Print%{0;185;255}(510 MB) \n
if %plugin3results% EQU 1 %Print%{0;255;50}            BORIS FX - Mocha Pro 
if %plugin3results% EQU 1 %Print%{0;185;255}(270 MB) \n
if %plugin4results% EQU 1 %Print%{0;255;50}            BORIS FX - Silhouette 
if %plugin4results% EQU 1 %Print%{0;185;255}(1.4 GB) \n
if %plugin5results% EQU 1 %Print%{0;255;50}            FXHOME - Ignite Pro 
if %plugin5results% EQU 1 %Print%{0;185;255}(430 MB) \n
if %plugin6results% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% EQU 1 %Print%{0;185;255}(260 MB) \n
if %plugin7results% EQU 1 %Print%{0;255;50}            MAXON - Red Giant Universe 
if %plugin7results% EQU 1 %Print%{0;185;255}(1.8 GB) \n
if %plugin8results% EQU 1 %Print%{0;255;50}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% EQU 1 %Print%{0;185;255}(630 MB) \n
if %plugin9results% EQU 1 %Print%{0;255;50}            NEWBLUEFX - TotalFX 7 
if %plugin9results% EQU 1 %Print%{0;185;255}(790 MB) \n
if %plugin10results% EQU 1 %Print%{0;255;50}            REVISIONFX - Effections 
if %plugin10results% EQU 1 %Print%{0;185;255}(50 MB) \n
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
IF defined PLUGKEY6 (
%Print%{244;255;0}           Downloaded ^& Not Installed \n
%Print%{244;255;0}        -------------------------------- \n
)
if %plugin1results% GEQ 3 %Print%{244;255;0}            BORIS FX - Sapphire 
if %plugin1results% GEQ 3 %Print%{0;185;255}(670 MB) \n
if %plugin2results% GEQ 3 %Print%{244;255;0}            BORIS FX - Continuum Complete 
if %plugin2results% GEQ 3 %Print%{0;185;255}(510 MB) \n
if %plugin3results% GEQ 3 %Print%{244;255;0}            BORIS FX - Mocha Pro 
if %plugin3results% GEQ 3 %Print%{0;185;255}(270 MB) \n
if %plugin4results% GEQ 3 %Print%{244;255;0}            BORIS FX - Silhouette 
if %plugin4results% GEQ 3 %Print%{0;185;255}(1.4 GB) \n
if %plugin5results% GEQ 3 %Print%{244;255;0}            FXHOME - Ignite Pro 
if %plugin5results% GEQ 3 %Print%{0;185;255}(430 MB) \n
if %plugin6results% GEQ 3 %Print%{244;255;0}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% GEQ 3 %Print%{0;185;255}(260 MB) \n
if %plugin7results% GEQ 3 %Print%{244;255;0}            MAXON - Red Giant Universe 
if %plugin7results% GEQ 3 %Print%{0;185;255}(1.8 GB) \n
if %plugin8results% GEQ 3 %Print%{244;255;0}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% GEQ 3 %Print%{0;185;255}(630 MB) \n
if %plugin9results% GEQ 3 %Print%{244;255;0}            NEWBLUEFX - TotalFX 7 
if %plugin9results% GEQ 3 %Print%{0;185;255}(790 MB) \n
if %plugin10results% GEQ 3 %Print%{244;255;0}            REVISIONFX - Effections 
if %plugin10results% GEQ 3 %Print%{0;185;255}(50 MB) \n
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
IF defined PLUGKEY7 (
%Print%{231;72;86}         Not Downloaded ^& Not Installed \n
%Print%{231;72;86}        -------------------------------- \n
)
if %plugin1results% EQU 2 %Print%{231;72;86}            BORIS FX - Sapphire 
if %plugin1results% EQU 2 %Print%{0;185;255}(670 MB) \n
if %plugin2results% EQU 2 %Print%{231;72;86}            BORIS FX - Continuum Complete 
if %plugin2results% EQU 2 %Print%{0;185;255}(510 MB) \n
if %plugin3results% EQU 2 %Print%{231;72;86}            BORIS FX - Mocha Pro 
if %plugin3results% EQU 2 %Print%{0;185;255}(270 MB) \n
if %plugin4results% EQU 2 %Print%{231;72;86}            BORIS FX - Silhouette 
if %plugin4results% EQU 2 %Print%{0;185;255}(1.4 GB) \n
if %plugin5results% EQU 2 %Print%{231;72;86}            FXHOME - Ignite Pro 
if %plugin5results% EQU 2 %Print%{0;185;255}(430 MB) \n
if %plugin6results% EQU 2 %Print%{231;72;86}            MAXON - Red Giant Magic Bullet Suite 
if %plugin6results% EQU 2 %Print%{0;185;255}(260 MB) \n
if %plugin7results% EQU 2 %Print%{231;72;86}            MAXON - Red Giant Universe 
if %plugin7results% EQU 2 %Print%{0;185;255}(1.8 GB) \n
if %plugin8results% EQU 2 %Print%{231;72;86}            NEWBLUEFX - Titler Pro 7 
if %plugin8results% EQU 2 %Print%{0;185;255}(630 MB) \n
if %plugin9results% EQU 2 %Print%{231;72;86}            NEWBLUEFX - TotalFX 7 
if %plugin9results% EQU 2 %Print%{0;185;255}(790 MB) \n
if %plugin10results% EQU 2 %Print%{231;72;86}            REVISIONFX - Effections 
if %plugin10results% EQU 2 %Print%{0;185;255}(50 MB) \n
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
set PlugQueueCounterFinal=
set PlugQueueCounter=
set PlugQueueInstallCounter=
set PlugQueueInstallCounterFinal=
set Mocha-veg-ofx=
set getOptionsPlugCountCheck=
GOTO SelectPlugins


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
%Print%{231;72;86}            5) Clear GDown Cache \n
echo/
%Print%{231;72;86}            6) Clean Installer Files \n
echo/
echo/
%Print%{231;72;86}            7) Preferences \n
echo/
%Print%{255;112;0}            8) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12345678 /M "Type the number (1-8) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 8  GOTO Main
IF ERRORLEVEL 7  GOTO 34
IF ERRORLEVEL 6  GOTO 33
IF ERRORLEVEL 5  GOTO 33-Gdowncache
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

:33-Gdowncache
cls
color 0C
echo/
%Print%{231;72;86}Are you sure you want to delete your
%Print%{244;255;0} GDown Cache? \n
echo/
%Print%{231;72;86}Re-building your GDown cache may resolve issues with \n
%Print%{0;255;50} - Downloads not starting \n
%Print%{0;255;50} - GDown not initializing \n
%Print%{0;255;50} - Clearing up cache's of old GDown versions \n
echo/
echo/
%Print%{231;72;86} 1) Yes \n
%Print%{231;72;86} 2) No \n
echo/
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo/
IF ERRORLEVEL 2  GOTO 3-Main
IF ERRORLEVEL 1  GOTO 33-Gdowncache-continue
echo/

:33-Gdowncache-continue
if exist "%userprofile%\.cache\gdown\cookies.json" del "%userprofile%\.cache\gdown\cookies.json" 2>nul
%Print%{0;255;50} Finished clearing your GDown Cache \n
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
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
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
%Print%{231;72;86}            2) Toggle Archiving Method:
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" %Print%{0;255;50} [WinRAR] \n
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" %Print%{0;255;50} [7Zip] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" %Print%{255;0;50} [N/A] \n
echo/
%Print%{231;72;86}            3) Reset All Preferences \n
echo/
%Print%{255;112;0}            4) Main Menu \n
echo/
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-4) of what you want to Select." /N
cls
echo/
IF ERRORLEVEL 4  GOTO Python-check
IF ERRORLEVEL 3  GOTO 333
IF ERRORLEVEL 2  GOTO 332
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

:332
cd /d "%~dp0"
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO 332-win-toggle
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO 332-szip-toggle
:332-win-toggle
REN ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" "archive-szip.txt" 2>nul
GOTO 34
:332-szip-toggle
REN ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" "archive-win.txt" 2>nul
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