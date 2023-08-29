
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
GOTO MEGAcmd-check

:MEGAcmd-check
:: Check for MEGAcmd installation
echo Checking MEGAcmd
if not exist "%localappdata%\MEGAcmd" GOTO errorNoMEGAcmd
if exist "%localappdata%\MEGAcmd" echo MEGAcmd is installed & GOTO check-extract

:errorNoMEGAcmd
echo.
echo MEGAcmd is not installed.
GOTO req-Install
:req-Install
cls
echo Required software for this installer is not detected.
echo Do you want to install the Required software?
echo.
echo - MEGAcmd
echo - WinRAR or 7Zip
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO errorNoMEGAcmd2
echo.

:errorNoMEGAcmd2
cls
echo Installing MEGAcmd
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\MEGAcmdSetup64.exe" /S
echo MEGAcmd has installed successfully
echo.
timeout /T 5 /nobreak >nul
:: Deletes MEGAcmd shortcut on desktop, clean up some clutter lol
if exist "%UserProfile%\Desktop\MEGAcmd.lnk" del "%UserProfile%\Desktop\MEGAcmd.lnk"
GOTO check-extract
@pause >nul



:check-extract
::sets environment variables for megacmd, after it installs or scans for installation
SET PATH=%localappdata%\MEGAcmd;%PATH%
::Variable for Extration method
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
set szip="C:\Program Files\7-Zip\7z.exe"
color 0C
echo.
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
echo 1 - WinRAR
echo 2 - 7Zip
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SZip-Install1
IF ERRORLEVEL 1  GOTO WRAR-Install1
echo.
:Choose-Archive
cls
echo Multiple File Archivers were detected
echo Select which archiver that you'd prefer to use for the Installer Script:
echo 1 - WinRAR
echo 2 - 7Zip
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SZip-Installed1
IF ERRORLEVEL 1  GOTO WRAR-Installed1
echo.
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
echo.
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
echo Auto Updates are not enabled.
GOTO prompt-auto-up1

:prompt-auto-up1
echo.
echo.
echo Do you want to enable Auto Updates for this Installer Script?
echo This will only check for updates when you launch the Installer Script.
echo This will install Git, if you do not have it already.
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO auto-update-no
IF ERRORLEVEL 1  GOTO git-install
echo.

:git-install
cls
color 0C
echo.
echo Checking for Git
git --version 2>NUL
if errorlevel 1 GOTO errorNoGit
GOTO git-installed1

:errorNoGit
color 0C
echo Git is not installed
cls
color 0C
timeout /T 3 /nobreak >nul
echo Launching the installer for Git 2.42
start "" /wait ".\Installer-files\Installer-Scripts\Install-Git.cmd"
echo.
%Print%{244;255;0} Please restart the installer script to initialize Git. \n
%Print%{244;255;0} Close out of this CMD window, and re-run the installer script. \n
timeout /T 3 /nobreak >nul
pause >nul

:git-installed1
color 0C
echo Git is installed
echo.
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
for /D %%I in (".\Installer-files\Installer-Scripts") do if exist "%%~I\autoup.cmd" del "%%~I\autoup.cmd" 2>1 >nul
GOTO mega-down-git
:: megacmd command
:mega-down-git
color 0c
call mega-get -m --ignore-quota-warn "https://mega.nz/file/G9clyDgZ#ly_bKOEimBpxkxf3TgNDK5mXryLqHudgRhixbkBwpn4" "%~dp0Installer-files\Installer-Scripts"
IF ERRORLEVEL 1 GOTO mega-down-git-error
IF ERRORLEVEL 0 GOTO mega-down-git-continue
@pause
:mega-down-git-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-git
:mega-down-git-continue
echo.
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
echo Downloading Auto Update Script
for /D %%I in (".\Installer-files\Installer-Scripts") do if exist "%%~I\autoup.cmd" del "%%~I\autoup.cmd" 2>1 >nul
GOTO mega-down-git
:: megacmd command
:mega-down-git2
color 0c
call mega-get -m --ignore-quota-warn "https://mega.nz/file/G9clyDgZ#ly_bKOEimBpxkxf3TgNDK5mXryLqHudgRhixbkBwpn4" "%~dp0Installer-files\Installer-Scripts"
IF ERRORLEVEL 1 GOTO mega-down-git2-error
IF ERRORLEVEL 0 GOTO mega-down-git2-continue
@pause
:mega-down-git2-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-git2
:mega-down-git2-continue
echo.
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
	echo.
	echo.
	git checkout HEAD^ "Installer Script by Nifer.cmd"
	echo Finished checking for updates.
	timeout /T 3 /nobreak >nul
    GOTO Main
:git-stash2-error
    echo no local changes
	echo.
	echo.
	git checkout HEAD^ "Installer Script by Nifer.cmd"
	echo Finished checking for updates.
	timeout /T 3 /nobreak >nul
	GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::
:auto-update-no
echo.
echo Disabling auto Updates
REN ".\Installer-files\Installer-Scripts\Settings\auto-update-0.txt" "auto-update-2.txt" 2>nul
echo The Installer will no longer ask you for auto updates.
timeout /T 3 /nobreak >nul
GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::




::------------------------------------------
:Main
@Title Installer Script by Nifer
:: Deletes MEGAcmd shortcut on desktop, clean up some clutter lol
if exist "%UserProfile%\Desktop\MEGAcmd.lnk" del "%UserProfile%\Desktop\MEGAcmd.lnk"
cls
color 0C
Echo.                                                        
%Print%{231;72;86}		   Installer Script by Nifer \n
%Print%{231;72;86}		   Patch and Script by Nifer \n
%Print%{244;255;0}                        Version - 5.0.3 \n
%Print%{231;72;86}		     Twitter - @NiferEdits \n
%Print%{231;72;86}\n
%Print%{231;72;86}            1) Magix Vegas Software \n
%Print%{231;72;86}\n
%Print%{231;72;86}            2) 3rd Party Plugins \n
%Print%{231;72;86}\n
%Print%{231;72;86}            3) Settings \n
%Print%{231;72;86}\n
%Print%{0;185;255}            4) Donate to support (Paypal) \n
%Print%{231;72;86}\n
%Print%{255;112;0}            5) Quit \n
echo.
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what option you want." /N
cls
echo.
IF ERRORLEVEL 5  GOTO Quit
IF ERRORLEVEL 4  GOTO Donate
IF ERRORLEVEL 3  GOTO 3
IF ERRORLEVEL 2  GOTO 2
IF ERRORLEVEL 1  GOTO 1
echo.

:1
color 0C
cls
@ECHO OFF
color 0C
Echo *******************************************************
Echo ***    (Option #1) Choose Magix Vegas Software      ***
Echo *******************************************************
Echo.
%Print%{255;255;255}		 Select what to Download and Install \n
echo.
%Print%{231;72;86}            1) Vegas Pro \n
echo.
%Print%{231;72;86}            2) Vegas Effects \n
echo.
%Print%{231;72;86}            3) Vegas Image \n
echo.
%Print%{255;112;0}            4) Main Menu \n
echo.
C:\Windows\System32\CHOICE /C 1234 /M "Type the number (1-4) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 4  GOTO Main
IF ERRORLEVEL 3  GOTO SelectImage
IF ERRORLEVEL 2  GOTO SelectEffects
IF ERRORLEVEL 1  GOTO SelectVegas
echo.

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
Echo.
%Print%{231;72;86}  Are you sure you want to download and install Vegas Effects? \n
echo.
%Print%{231;72;86}            1) Yes \n
echo.
%Print%{231;72;86}            2) No \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  GOTO VegasEffects1
echo.

:install-prompt-ve-1
cls
color 0C
echo.
echo You already have VEGAS Effects downloaded
echo.
echo       1 = Download it again
echo       2 = Cancel and go back
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  del ".\Installer-files\Vegas Effects\VEGAS_Effects*.msi" 2>1 >nul & GOTO mega-down-ve1
echo.
:VegasEffects1
if not exist ".\Installer-files\Vegas Effects" mkdir ".\Installer-files\Vegas Effects" 
for /D %%I in (".\Installer-files\Vegas Effects") do if exist "%%~I\VEGAS_Effects*.msi" GOTO install-prompt-ve-1
GOTO mega-down-ve1
:: megacmd command
:mega-down-ve1
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/b4clQa4R#GsZxxxPC1a7l3Dq6YKYI-g" "%~dp0Installer-files\Vegas Effects"
IF ERRORLEVEL 1 GOTO mega-down-error-ve1
IF ERRORLEVEL 0 GOTO mega-down-ve1-continue
@pause
:mega-down-error-ve1
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-ve1
:mega-down-ve1-continue
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
echo.
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
Echo.
%Print%{231;72;86}  Are you sure you want to download and install Vegas Image? \n
echo.
%Print%{231;72;86}            1) Yes \n
echo.
%Print%{231;72;86}            2) No \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  GOTO VegasImage1
echo.


:install-prompt-vi-1
cls
color 0C
echo.
echo You already have VEGAS Image downloaded
echo.
echo       1 = Download it again
echo       2 = Cancel and go back
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 1
IF ERRORLEVEL 1  del ".\Installer-files\Vegas Effects\VEGAS_Effects*.msi" 2>1 >nul & GOTO mega-down-vi1
echo.
:VegasImage1
if not exist ".\Installer-files\Vegas Image" mkdir ".\Installer-files\Vegas Image" 
for /D %%I in (".\Installer-files\Vegas Image") do if exist "%%~I\VEGAS_Image*.exe" GOTO install-prompt-vi-1
GOTO mega-down-vi1
:: megacmd command
:mega-down-vi1
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/2pc3jYYR#DiAbCVMKJjKNIERzj7sSwQ" "%~dp0Installer-files\Vegas Image"
IF ERRORLEVEL 1 GOTO mega-down-error-vi1
IF ERRORLEVEL 0 GOTO mega-down-vi1-continue
@pause
:mega-down-error-vi1
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-vi1
:mega-down-vi1-continue
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
echo.
%Print%{244;255;0}Please reboot your PC for the patch to take effect. \n
timeout /T 7 /nobreak >nul
GOTO 1


:SelectVegas
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
Echo.
%Print%{255;255;255}		 Select what to Download and Install \n
echo.
%Print%{231;72;86}            1) Vegas Pro + Deep Learning Modules + Patch 
%Print%{244;255;0}(1.6 GB) \n
echo.
%Print%{231;72;86}            2) Vegas Pro + Patch Only 
%Print%{244;255;0}(630 MB) \n
echo.
%Print%{231;72;86}            3) Deep Learning Modules Only 
%Print%{244;255;0}(1 GB) \n
echo.
%Print%{231;72;86}            4) Patch Only 
%Print%{244;255;0}(18 MB) \n
echo.
%Print%{255;112;0}            5) Back \n
echo.
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 5  GOTO 1
IF ERRORLEVEL 4  GOTO 14
IF ERRORLEVEL 3  GOTO 13
IF ERRORLEVEL 2  GOTO 12
IF ERRORLEVEL 1  GOTO 11
echo.


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 1
:11
cls
color 0C
Echo.
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
SET LOGFILE="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
(for /f usebackq^ eol^= %%a in ("%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt") do break) && echo GOTO alrDown-11 || GOTO install-11

:alrDown-11
cls
echo.
color 0C
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
type nul>VP-Installations-found-output.txt
for /f "tokens=* delims=" %%g in (VP-Installations-found.txt) do (
  findstr /ixc:"%%g" VP-Installations-found-output.txt || >>VP-Installations-found-output.txt echo.%%g
)
cls
echo.
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo.
setLocal
:: Trims down output and removes duplicate entries
for /f "eol=- tokens=* delims= " %%T in ('find "VEGAS Pro" VP-Installations-found-output.txt') do (
	set tempvar11=%%T
   ::echo.%%T
   echo  !tempvar11:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
cd /d "%~dp0"
echo.
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo.
echo.
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo.
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-11
IF ERRORLEVEL 1  GOTO select-vp-uninstall-11
echo.
:select-vp-uninstall-11
color 0C
cls
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
echo.
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo.
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call "%~dp0Installer-files\Installer-Scripts\jrepl.bat" "[ \t]+(?=\||$)" "" /f "VP-Installations-found-output.txt" /o -
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set VP-Uninst-Select1="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Uninstall-Selection.txt"
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
echo.
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

for %%a in (%choices%) do if %%a EQU 20 set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError11
GOTO vp-uninstall-selection-prompt11
exit

:optionError11
color 0C
echo.
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
echo.
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo.
type %VP-Uninst-Select1%
echo.
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO alrDown-11
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue11
echo.

:vp-uninstall-selection-continue11
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
echo.
echo You already have VEGAS Pro downloaded
echo.
echo       1 = Download it again
echo       2 = Cancel and go back
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO VP-Install-Check-11
IF ERRORLEVEL 1  del ".\Installer-files\Vegas Pro\*.*" 2>1 >nul & GOTO mega-down-vp1
echo.

:install-11
cd /d "%~dp0"
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\*.*" GOTO install-prompt-11
GOTO mega-down-vp1
:: megacmd command
:mega-down-vp1
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/G0d2WARA#XyhL6Jx79nSntPbfZ1IS4w" "%~dp0Installer-files\Vegas Pro"
IF ERRORLEVEL 1 GOTO mega-down-error-vp1
IF ERRORLEVEL 0 GOTO mega-down-vp1-continue
@pause
:mega-down-error-vp1
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-vp1
:mega-down-vp1-continue
cls
color 0c
echo Download is finished
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
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (nifer-patch-vp*.exe) do "%%~fa" /wait /s /v/qb
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\nifer-patch-vp.exe" 2>nul
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
Echo.
:: Check if vegas is already installed
echo Checking for other installations...
GOTO VP-Install-Check-12

:VP-Install-Check-12
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
(for /f usebackq^ eol^= %%a in ("%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt") do break) && echo GOTO alrDown-12 || GOTO install-12


:alrDown-12
cls
echo.
color 0C
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
type nul>VP-Installations-found-output.txt
for /f "tokens=* delims=" %%g in (VP-Installations-found.txt) do (
  findstr /ixc:"%%g" VP-Installations-found-output.txt || >>VP-Installations-found-output.txt echo.%%g
)
cls
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo.
setLocal
:: Trims down output and removes duplicate entries
for /f "eol=- tokens=* delims= " %%T in ('find "VEGAS Pro" VP-Installations-found-output.txt') do (
	set tempvar12=%%T
   ::echo.%%T
   echo  !tempvar12:---------- =! 2>nul | findstr /v Voukoder 2>nul
)
endlocal
cd /d "%~dp0"
echo.
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo.
echo.
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo.
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-12
IF ERRORLEVEL 1  GOTO select-vp-uninstall-12
echo.
:select-vp-uninstall-12
color 0C
cls
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
echo.
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo.
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call "%~dp0Installer-files\Installer-Scripts\jrepl.bat" "[ \t]+(?=\||$)" "" /f "VP-Installations-found-output.txt" /o -
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set VP-Uninst-Select1="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Uninstall-Selection.txt"
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
echo.
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

for %%a in (%choices%) do if %%a EQU 20 set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError12
GOTO vp-uninstall-selection-prompt12
exit

:optionError12
color 0C
echo.
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptions12

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

:vp-uninstall-selection-prompt12
color 0C
cls
echo.
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo.
type %VP-Uninst-Select1%
echo.
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO alrDown-12
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue12
echo.

:vp-uninstall-selection-continue12
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
echo.
echo You already have VEGAS Pro downloaded
echo.
echo       1 = Download it again
echo       2 = Cancel and go back
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO VP-Install-Check-12
IF ERRORLEVEL 1  del ".\Installer-files\Vegas Pro\*.*" 2>1 >nul & GOTO mega-down-vp2
echo.

:install-12
cd /d "%~dp0"
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\VEGAS_Pro*.exe" if exist "%%~I\nifer-*.exe" GOTO install-prompt-12
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\VEGAS_Pro*.exe" del "%%~I\VEGAS_Pro*.exe" 2>1 >nul
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\nifer-*.exe" del "%%~I\nifer-*.exe" 2>1 >nul
GOTO mega-down-vp2
:: megacmd command
:mega-down-vp2
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/P40HFDSZ#xtduGZcERdMoQC7hrr7o8w" "%~dp0Installer-files\Vegas Pro"
IF ERRORLEVEL 1 GOTO mega-down-error-vp2
IF ERRORLEVEL 0 GOTO mega-down-vp2-continue
@pause
:mega-down-error-vp2
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-vp2
:mega-down-vp2-continue
cls
color 0c
echo Download is finished
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
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (nifer-patch-vp*.exe) do "%%~fa" /wait /s /v/qb
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\nifer-patch-vp.exe"
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
Echo.
:: Check if vegas deep learning modules is already installed
echo Checking if Vegas Pro Deep Learning Modules is already installed
GOTO VP-Install-Check-13

:VP-Install-Check-13
@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
SET LOGFILE="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt"
call :LogVPVers > %LOGFILE%
:: If logfile is blank - continues to install. If data found, prompt user to uninstall
(for /f usebackq^ eol^= %%a in ("%~dp0\Installer-files\Installer-Scripts\Settings\VP-Installations-found.txt") do break) && echo GOTO alrDown-13 || GOTO install-13
GOTO alrDown-13

:alrDown-13
cls
echo.
color 0C
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
type nul>VP-Installations-found-output.txt
for /f "tokens=* delims=" %%g in (VP-Installations-found.txt) do (
  findstr /ixc:"%%g" VP-Installations-found-output.txt || >>VP-Installations-found-output.txt echo.%%g
)
cls
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo.
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
echo.
echo ---------------------------------
%Print%{255;255;255} What do you want to do? \n
%Print%{231;72;86} 1 = Select what programs to Uninstall \n
%Print%{231;72;86} 2 = Don't uninstall anything and Install the latest version \n
%Print%{255;112;0} 3 = Cancel and return to Main Menu \n
echo.
echo.
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo.
IF ERRORLEVEL 3  GOTO SelectVegas
IF ERRORLEVEL 2  GOTO install-13
IF ERRORLEVEL 1  GOTO select-vp-uninstall-13
echo.

:select-vp-uninstall-13
color 0C
cls
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Changing directory is needed
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
call :vp-dlm-parse13 > "VP-Uninstall-DLM-Selection.txt"
echo.
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo.
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is to delete any leading spaces for each line in a text file.
:: Calls JREPL to remove leading spaces and append to input file.
:: Otherwise, leading white space will conflict when we reg query for display name.
call "%~dp0Installer-files\Installer-Scripts\jrepl.bat" "[ \t]+(?=\||$)" "" /f "VP-Uninstall-DLM-Selection.txt" /o -
::::::::::::::::::::::::::::::::::::::::::::::::
:: This entire process is for multi-selection when user chooses to uninstall VP
:: Deletes text preference for selection, if made previously
set VP-Uninst-Select2="%~dp0\Installer-files\Installer-Scripts\Settings\VP-Uninstall-DLM-Selection-output.txt"
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
echo.
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

for %%a in (%choices%) do if %%a EQU 20 set choices=1 2 3 4 5 6 7 8 9 10
for %%i in (%choices%) do call :option-%%i 2>nul
IF ERRORLEVEL 1 GOTO optionError13
GOTO vp-uninstall-selection-prompt13
exit

:optionError13
color 0C
echo.
echo Exceeded max number of selections.
echo Selections (1-10)
@pause
GOTO getOptions13

:option-1
>> %VP-Uninst-Select2% echo !Line_1!
exit /B

:option-2
>> %VP-Uninst-Select2% echo !Line_2!
exit /B

:option-3
>> %VP-Uninst-Select2% echo !Line_3!
exit /B

:option-4
>> %VP-Uninst-Select2% echo !Line_4!
exit /B

:option-5
>> %VP-Uninst-Select2% echo !Line_5!
exit /B

:option-6
>> %VP-Uninst-Select2% echo !Line_6!
exit /B

:option-7
>> %VP-Uninst-Select2% echo !Line_7!
exit /B

:option-8
>> %VP-Uninst-Select2% echo !Line_8!
exit /B

:option-9
>> %VP-Uninst-Select2% echo !Line_9!
exit /B

:option-10
>> %VP-Uninst-Select2% echo !Line_10!
exit /B

:vp-uninstall-selection-prompt13
cls
echo.
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo.
type %VP-Uninst-Select2%
echo.
echo ---------------------------------
%Print%{231;72;86} 1 = Yes, Uninstall these programs \n
%Print%{255;112;0} 2 = No, Cancel and Go back \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO VP-Install-Check-13
IF ERRORLEVEL 1  GOTO vp-uninstall-selection-continue13
echo.

:vp-uninstall-selection-continue13
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
cd /d "%~dp0\Installer-files\Installer-Scripts\Settings"
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
echo.
echo You already have VEGAS Pro Deep Learning Models downloaded
echo.
echo       1 = Download it again
echo       2 = Cancel and go back
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO alrDown-13
IF ERRORLEVEL 1  del ".\Installer-files\Vegas Pro\VEGAS_Deep*.exe" 2>1 >nul & GOTO mega-down-vp3
echo.

:install-13
cd /d "%~dp0"
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\VEGAS_Deep*.exe" GOTO install-prompt-13
GOTO mega-down-vp3
:: megacmd command
:mega-down-vp3
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/ThNx3bZI#BqRroruk0DSIVe5XzxnRsQ" "%~dp0Installer-files\Vegas Pro"
IF ERRORLEVEL 1 GOTO mega-down-error-vp3
IF ERRORLEVEL 0 GOTO mega-down-vp3-continue
@pause
:mega-down-error-vp3
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-vp3
:mega-down-vp3-continue
cls
color 0c
echo Download is finished
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
Echo.
:: Check if vegas is already installed
echo Checking if Vegas Pro is already installed
if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\" GOTO install-14
echo Vegas Pro isn't installed, please select the menu option to download Vegas Pro
timeout /T 7 /nobreak >nul
GOTO Main


:install-14
cd /d "%~dp0"
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
for /D %%I in (".\Installer-files\Vegas Pro") do if exist "%%~I\nifer-*.exe" del "%%~I\nifer-*.exe" 2>1 >nul
GOTO mega-down-vp4
:: megacmd command
:mega-down-vp4
cls
color 0c
echo Initializing Download...
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/Xp0EGYiQ#ZwxxbFMN3OFnVcicIpSx9Q" "%~dp0Installer-files\Vegas Pro"
IF ERRORLEVEL 1 GOTO mega-down-error-vp4
IF ERRORLEVEL 0 GOTO mega-down-vp4-continue
@pause
:mega-down-error-vp4
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-vp4
:mega-down-vp4-continue
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
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (nifer-patch-vp*.exe) do "%%~fa" /wait /s /v/qb
:: Creates preference for VP Patch
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
echo Vegas Pro is now patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\nifer-patch-vp.exe"
GOTO Main




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:2
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
echo.
GOTO SelectPlugins

:SelectPlugins
color 0C
::Variable for WinRAR
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
:: Variables for each plugin, to call later on
set BFX-Sapphire=Boris FX Sapphire OFX by Nifer.rar
set BFX-Continuum=Boris FX Continuum Complete OFX by Nifer.rar
set BFX-Mocha=Boris FX Mocha Pro OFX by Nifer.rar
set BFX-Mocha-Vegas=Boris FX Mocha Vegas by Nifer.rar
set BFX-Silhouette=Boris FX Silhouette by Nifer.rar
set FXH-Ignite=FXHOME Ignite Pro OFX by Nifer.rar
set MXN-MBL=MAXON Red Giant Magic Bullet Suite by Team V.R.rar
set MXN-Universe=MAXON Red Giant Universe by Team V.R.rar
set NFX-Titler=NewBlueFX Titler Pro 7 Ultimate by Nifer.rar
set NFX-TotalFX=NewBlueFX TotalFX 7 OFX by Nifer.rar
set RFX-Effections=REVisionFX Effections OFX by Team V.R.rar
set All-Plugins=All Plugins.rar

cls
@ECHO OFF
color 0C
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
Echo.
%Print%{255;255;255}		 Select which plugins to Download \n
echo.
%Print%{231;72;86}            1) All Plugins 
%Print%{244;255;0}(6.8 GB) \n
echo.
%Print%{231;72;86}            2) BORIS FX - Sapphire 
%Print%{244;255;0}(670 MB) \n
echo.
%Print%{231;72;86}            3) BORIS FX - Continuum 
%Print%{244;255;0}(510 MB) \n
echo.
%Print%{231;72;86}            4) BORIS FX - Mocha Pro
%Print%{244;255;0}(270 MB) \n
echo.
%Print%{231;72;86}            5) BORIS FX - Silhouette 
%Print%{244;255;0}(1.4 GB) \n
echo.
%Print%{231;72;86}            6) FXHOME - Ignite Pro 
%Print%{244;255;0}(430 MB) \n
echo.
%Print%{231;72;86}            7) MAXON - Red Giant Magic Bullet Suite 
%Print%{244;255;0}(260 MB) \n
echo.
%Print%{255;112;0}            8) Next Page \n
echo.
%Print%{255;112;0}            9) Main Menu \n
echo.
C:\Windows\System32\CHOICE /C 123456789 /M "Type the number (1-9) of what you want to Download." /N
cls
echo.
IF ERRORLEVEL 9  GOTO Main
IF ERRORLEVEL 8  GOTO SelectPlugins2
IF ERRORLEVEL 7  GOTO 27
IF ERRORLEVEL 6  GOTO 26
IF ERRORLEVEL 5  GOTO 25
IF ERRORLEVEL 4  GOTO 24-prompt
IF ERRORLEVEL 3  GOTO 23
IF ERRORLEVEL 2  GOTO 22
IF ERRORLEVEL 1  GOTO 21
echo.

:SelectPlugins2
cls
@ECHO OFF
color 0C
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
Echo.
%Print%{255;255;255}		 Select which plugins to Download \n
echo.
%Print%{231;72;86}            1) MAXON - Red Giant Universe 
%Print%{244;255;0}(1.8 GB) \n
echo.
%Print%{231;72;86}            2) NEWBLUEFX - Titler Pro 7 
%Print%{244;255;0}(630 MB) \n
echo.
%Print%{231;72;86}            3) NEWBLUEFX - TotalFX 7 
%Print%{244;255;0}(790 MB) \n
echo.
%Print%{231;72;86}            4) REVISIONFX - Effections 
%Print%{244;255;0}(50 MB) \n
echo.
%Print%{255;112;0}            5) Previous Page \n
echo.
%Print%{255;112;0}            6) Main Menu \n
echo.
C:\Windows\System32\CHOICE /C 123456 /M "Type the number (1-6) of what you want to Download." /N
cls
echo.
IF ERRORLEVEL 6  GOTO Main
IF ERRORLEVEL 5  GOTO SelectPlugins
IF ERRORLEVEL 4  GOTO 224
IF ERRORLEVEL 3  GOTO 223
IF ERRORLEVEL 2  GOTO 222
IF ERRORLEVEL 1  GOTO 221
echo.


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 1
:21
cls
color 0C
Echo.
:: Ask if user is sure they want to download all plugins
echo Are you sure you want to install all plugins?
%Print%{231;72;86}This entire process may or may not take
%Print%{244;255;0} 30-90 minutes, 
%Print%{231;72;86}depending on internet connection and disk speed. \n
%Print%{244;255;0}Approx. 7 GB
echo.
%Print%{231;72;86}1 = Yes \n
%Print%{231;72;86}2 = No \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO checkdown-21
echo.
:: Check if all plugins are already downloaded
:checkdown-21
:: Deletes any existing Mocha Pro Preference and prompts user to choose again
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" del ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" 2>1 1>nul
color 0C
echo Checking if all plugins are already downloaded
if exist ".\Installer-files\Plugins\Boris FX Sapph*" GOTO alrDown21-22
GOTO down-21-prompt
:alrDown21-22
if exist ".\Installer-files\Plugins\Boris FX Cont*" GOTO alrDown21-23
GOTO down-21-prompt
:alrDown21-23
if exist ".\Installer-files\Plugins\Boris FX Mocha*" GOTO alrDown21-24
GOTO down-21-prompt
:alrDown21-24
if exist ".\Installer-files\Plugins\Boris FX Silho*" GOTO alrDown21-25
GOTO down-21-prompt
:alrDown21-25
if exist ".\Installer-files\Plugins\FXHOME Ign*" GOTO alrDown21-26
GOTO down-21-prompt
:alrDown21-26
if exist ".\Installer-files\Plugins\MAXON Red Giant Magic Bull*" GOTO alrDown21-27
GOTO down-21-prompt
:alrDown21-27
if exist ".\Installer-files\Plugins\MAXON Red Giant Uni*" GOTO alrDown21-221
GOTO down-21-prompt
:alrDown21-221
if exist ".\Installer-files\Plugins\NewBlueFX Titler*" GOTO alrDown21-222
GOTO down-21-prompt
:alrDown21-222
if exist ".\Installer-files\Plugins\NewBlueFX Total*" GOTO alrDown21-223
GOTO down-21-prompt
:alrDown21-223
if exist ".\Installer-files\Plugins\REVisionFX Eff*" GOTO prompt-allplug-down
GOTO down-21-prompt
:prompt-allplug-down
echo.
color 0C
echo You already have all plugins downloaded
echo What do you want to do?
echo.
echo 1 = Re-download them all
echo 2 = Continue to installing
echo 3 = back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo.
IF ERRORLEVEL 3  GOTO SelectPlugins
IF ERRORLEVEL 2  GOTO auto-21
IF ERRORLEVEL 1  GOTO down-21-prompt
echo.

:::::::::::::::::::::::::::::::::::::::
:: Prompts to ask which version of Mocha to Download
:down-21-prompt
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" GOTO down-21
cls
echo Before continuing and downloading all plugins...
echo There are two available verisons of Boris FX Mocha
echo.
%Print%{231;72;86} 1 is a specially made version of Mocha by Boris FX for Vegas Pro 21 and above. \n
%Print%{244;255;0} It has better integration, but may be outdated. \n
echo.
%Print%{231;72;86} 2 is the OFX version of Mocha by Boris FX. \n
%Print%{244;255;0} It works for ALL versions of Vegas Pro, and may be more updated. \n
echo.
%Print%{231;72;86} 1 = Mocha Vegas \n
%Print%{231;72;86} 2 = Mocha Pro OFX \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO down-21-ofx
IF ERRORLEVEL 1  GOTO down-21-veg
echo.
:down-21-veg
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" break>".\Installer-files\Installer-Scripts\Settings\mocha-auto-veg.txt"
GOTO down-21
:down-21-ofx
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" break>".\Installer-files\Installer-Scripts\Settings\mocha-auto-ofx.txt"
GOTO down-21


:down-21
cd /d "%~dp0"
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" GOTO down-21-prompt 
cls
color 0C
echo Initializing Downloads...
GOTO mega-down-allp-1

:: Different colored lines - Calls upon colorText
:: megacmd commands

:: Boris FX Continuum
:mega-down-allp-1
color 0C
%Print%{0;255;50}1 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Cont*.rar" del "%%~I\Boris FX Cont*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/m1tjzBxJ#XlYA7uAXLN70Bv9Ndrfm7w" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-1
IF ERRORLEVEL 0 GOTO mega-down-allp-1-continue
@pause
:mega-down-error-allp-1
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-1

:mega-down-allp-1-continue
:: Checking for Mocha Pro Preference
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-ofx.txt" GOTO mega-down-allp-2-ofx
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-veg.txt" GOTO mega-down-allp-2-veg

:: Boris FX Mocha Pro OFX
:mega-down-allp-2-ofx
color 0C
%Print%{0;255;50}2 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Mocha Pro*.rar" del "%%~I\Boris FX Mocha Pro*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/i40USJiA#5rXZ_VvFWbKUq3T6jSXY3A" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-2-ofx
IF ERRORLEVEL 0 GOTO mega-down-allp-2-continue
@pause
:mega-down-error-allp-2-ofx
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-2-ofx

:: Boris FX Mocha Vegas
:mega-down-allp-2-veg
color 0C
%Print%{0;255;50}2 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Mocha Vegas*.rar" del "%%~I\Boris FX Mocha Vegas*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/Px1zCTQS#FHwFZ5U_bUY06lejrplBAA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-2-veg
IF ERRORLEVEL 0 GOTO mega-down-allp-2-continue
@pause
:mega-down-error-allp-2-veg
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-2-veg

:: Boris FX Sapphire
:mega-down-allp-2-continue
color 0C
%Print%{0;255;50}3 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Sapph*.rar" del "%%~I\Boris FX Sapph*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/z4MEVZrI#JErtuIxeluN60I5WVKyw5Q" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-3
IF ERRORLEVEL 0 GOTO mega-down-allp-3-continue
@pause
:mega-down-error-allp-3
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-2-continue

:: Boris FX Silhouette
:mega-down-allp-3-continue
color 0C
%Print%{0;255;50}4 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Silho*.rar" del "%%~I\Boris FX Silho*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/CwcmwCzQ#lNldUriLTu1HOOnGn2iKFw" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-4
IF ERRORLEVEL 0 GOTO mega-down-allp-4-continue
@pause
:mega-down-error-allp-4
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-3-continue

:: FXHome Ignite Pro
:mega-down-allp-4-continue
color 0C
%Print%{0;255;50}5 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\FXHOME Ign*.rar" del "%%~I\FXHOME Ign*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/X4MglbpQ#6Y_jba-d2k8pT6RZ_E9Cow" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-5
IF ERRORLEVEL 0 GOTO mega-down-allp-5-continue
@pause
:mega-down-error-allp-5
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-4-continue

:: Maxon Red Giant Magic Bullet Suite
:mega-down-allp-5-continue
color 0C
%Print%{0;255;50}6 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\MAXON Red Giant Magic Bull*.rar" del "%%~I\MAXON Red Giant Magic Bull*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/WpdhxKRJ#Q95iwbuJ9jHpJbPBWGKJuA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-6
IF ERRORLEVEL 0 GOTO mega-down-allp-6-continue
@pause
:mega-down-error-allp-6
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-5-continue

:: Maxon Red Giant Universe
:mega-down-allp-6-continue
color 0C
%Print%{0;255;50}7 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\MAXON Red Giant Uni*.rar" del "%%~I\MAXON Red Giant Uni*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/mt1EVBxC#fk6rSqjgjHVr4_p6C-oPKA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-7
IF ERRORLEVEL 0 GOTO mega-down-allp-7-continue
@pause
:mega-down-error-allp-7
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-6-continue

:: NewBlue FX Titler Pro
:mega-down-allp-7-continue
color 0C
%Print%{0;255;50}8 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\NewBlueFX Titler*.rar" del "%%~I\NewBlueFX Titler*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/S1Fh0LSC#7ghSUmyFOS1SnuNCtUIrfg" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-8
IF ERRORLEVEL 0 GOTO mega-down-allp-8-continue
@pause
:mega-down-error-allp-8
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-7-continue

:: NewBlue FX TotalFX
:mega-down-allp-8-continue
color 0C
%Print%{0;255;50}9 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\NewBlueFX Total*.rar" del "%%~I\NewBlueFX Total*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/zoUEkaAL#aX10JJWbdmCY8IQpDAbnGA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-error-allp-9
IF ERRORLEVEL 0 GOTO mega-down-allp-9-continue
@pause
:mega-down-error-allp-9
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-8-continue

:: REVision FX Effections
:mega-down-allp-9-continue
color 0C
%Print%{0;255;50}10 of 10 \n
for /D %%I in (".\Installer-files") do if exist "%%~I\REVisionFX Eff*.rar" del "%%~I\REVisionFX Eff*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/rxlmBT4a#2GFmfaD306SjX9jQR-DxGQ" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down-errorallp-10
IF ERRORLEVEL 0 GOTO mega-down-allp-10-continue
@pause
:mega-down-error-allp-10
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO mega-down-allp-9-continue

:mega-down-allp-10-continue
cls
color 0C
echo Downloads Finished!
echo Renaming rar files
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%"
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%"
REN ".\Installer-files\Boris FX Mocha Pro*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Mocha Vegas*" "%BFX-Mocha-Vegas%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%"
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%"
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%"
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%"
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%"
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%"
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%"
color 0C
echo Extracting files
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-21-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-21-szip
:down-21-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
color 0C
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o- ".\Installer-files\%BFX-Sapphire%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Continuum%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Mocha%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Mocha-Vegas%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Silhouette%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%FXH-Ignite%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%MXN-MBL%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%MXN-Universe%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%NFX-Titler%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%NFX-TotalFX%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%RFX-Effections%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP21
:down-21-szip
cd /d "%~dp0\Installer-files"
%szip% x -aos "%BFX-Sapphire%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%BFX-Continuum%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%BFX-Mocha%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%BFX-Mocha-Vegas%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%BFX-Silhouette%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%FXH-Ignite%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%MXN-MBL%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%MXN-Universe%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%NFX-Titler%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%NFX-TotalFX%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
%szip% x -aos "%RFX-Effections%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE21
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP21
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE21
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP21
)
:CONTINUE21
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
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
GOTO auto-21

:auto-21
cls
echo How do you want to install the plugins?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-21
IF ERRORLEVEL 1  GOTO autoinst-21
echo.
:manual-21
cls
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-21
cls
:: 1st auto install
echo Launching auto install script for Boris FX Continuum Complete
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-1
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Cont*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-1
echo.
:no-auto-1
echo There is no auto install script for Boris FX Continuum Complete.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-1
:autoscript-1
cls
color 0C
:: Checking for Mocha Pro Preference
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" GOTO autoscript-1-prompt
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-ofx.txt" GOTO autoscript-1-1
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-veg.txt" GOTO autoscript-1-2
:autoscript-1-prompt
cls
color 0C
echo Before continuing and installing the rest of the plugins...
echo There are two available verisons of Boris FX Mocha
echo.
%Print%{231;72;86} 1 is a specially made version of Mocha by Boris FX for Vegas Pro 21 and above. \n
%Print%{244;255;0} It has better integration, but may be outdated. \n
echo.
%Print%{231;72;86} 2 is the OFX version of Mocha by Boris FX. \n
%Print%{244;255;0} It works for ALL versions of Vegas Pro, and may be more updated. \n
echo.
%Print%{231;72;86} 1 = Mocha Vegas \n
%Print%{231;72;86} 2 = Mocha Pro OFX \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO autoscript-1-prompt-ofx
IF ERRORLEVEL 1  GOTO autoscript-1-prompt-veg
echo.
:autoscript-1-prompt-veg
cls
color 0C
echo.
echo Saving Mocha Pro preference
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" break>".\Installer-files\Installer-Scripts\Settings\mocha-auto-veg.txt"
GOTO autoscript-1
:autoscript-1-prompt-ofx
cls
color 0C
echo.
echo Saving Mocha Pro preference
if not exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto*.txt" break>".\Installer-files\Installer-Scripts\Settings\mocha-auto-ofx.txt"
GOTO autoscript-1
:: 2nd auto install
:autoscript-1-1
echo Launching auto install script for Boris FX Mocha Pro OFX
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Pro*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Pro*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-2
echo.
:no-auto-2
echo There is no auto install script for Boris FX Mocha Pro OFX.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-2
:autoscript-1-2
echo Launching auto install script for Boris FX Mocha Vegas
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Vegas*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2-2
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Vegas*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-2
echo.
:no-auto-2-2
echo There is no auto install script for Boris FX Mocha Vegas.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-2
:autoscript-2
cls
color 0C
:: 3rd auto install
echo Launching auto install script for Boris FX Sapphire
for /D %%I in (".\Installer-files\Plugins\Boris FX Sapph*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-3
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Sapph*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-3
echo.
:no-auto-3
echo There is no auto install script for Boris FX Sapphire.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-3
:autoscript-3
cls
color 0C
:: 4th auto install
echo Launching auto install script for Boris FX Silhouette
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-4
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Silho*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-4
echo.
:no-auto-4
echo There is no auto install script for Boris FX Silhouette.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-4
:autoscript-4
cls
color 0C
:: 5th auto install
echo Launching auto install script for FXHOME Ignite Pro
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-5
for /D %%I in ("%~dp0\Installer-files\Plugins\FXHOME Ign*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-5
echo.
:no-auto-5
echo There is no auto install script for FXHOME Ignite Pro.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-5
:autoscript-5
cls
color 0C
:: 6th auto install
echo Launching auto install script for MAXON Red Giant Magic Bullet Suite
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-6
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-6
echo.
:no-auto-6
echo There is no auto install script for MAXON Red Giant Magic Bullet Suite.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-6
:autoscript-6
cls
color 0C
:: 7th auto install
echo Launching auto install script for MAXON Red Giant Universe
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-7
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Uni*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-7
echo.
:no-auto-7
echo There is no auto install script for MAXON Red Giant Universe.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-7
:autoscript-7
cls
color 0C
:: 8th auto install
echo Launching auto install script for NewBlueFX Titler Pro 7 Ultimate
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-8
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Titler*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-8
echo.
:no-auto-8
echo There is no auto install script for NewBlueFX Titler Pro 7 Ultimate.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-8
:autoscript-8
cls
color 0C
:: 9th auto install
echo Launching auto install script for NewBlueFX TotalFX 7
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-9
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Total*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
echo.
echo Select what to do next
echo.
echo 1 = Continue Auto Install
echo 2 = Cancel and Go back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-9
echo.
:no-auto-9
echo There is no auto install script for NewBlueFX TotalFX 7.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO autoscript-9
:autoscript-9
cls
color 0C
:: 10th auto install
echo Launching auto install script for REVisionFX Effections
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-10
for /D %%I in ("%~dp0\Installer-files\Plugins\REVisionFX Eff*") do start "" /wait "%%~I\INSTALL.cmd"
Timeout /T 2 /Nobreak >nul
GOTO SelectPlugins
:no-auto-10
echo There is no auto install script for REVisionFX Effections.
echo For manual installation, please open this directory
echo "Installer-files > Plugins > (Plugin Name)"
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 2
:22
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Sapph*" GOTO alrDown-22
echo Plugin isn't downloaded, continuing to download
GOTO down-22
:alrDown-22
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-22
echo.
:down-22
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Sapph*.rar" del "%%~I\Boris FX Sapph*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/z4MEVZrI#JErtuIxeluN60I5WVKyw5Q" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down22-error
IF ERRORLEVEL 0 GOTO mega-down22-continue
:mega-down22-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-22

:mega-down22-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-22-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-22-szip
:down-22-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%BFX-Sapphire%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP22
:down-22-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%BFX-Sapphire%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE22
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP22
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE22
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP22
)
:CONTINUE22
del "%~dp0\Installer-files\%BFX-Sapphire%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if exist "%%~I\INSTALL.cmd" GOTO auto-22
GOTO SelectPlugins

:auto-22
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-22
IF ERRORLEVEL 1  GOTO autoinst-22
echo.
:manual-22
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-22
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 3
:23
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Cont*" GOTO alrDown-23
echo Plugin isn't downloaded, continuing to download
GOTO down-23
:alrDown-23
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-23
echo.
:down-23
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Cont*.rar" del "%%~I\Boris FX Cont*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/m1tjzBxJ#XlYA7uAXLN70Bv9Ndrfm7w" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down23-error
IF ERRORLEVEL 0 GOTO mega-down23-continue
:mega-down23-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-23
:mega-down23-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-23-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-23-szip
:down-23-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%BFX-Continuum%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP23
:down-23-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%BFX-Continuum%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE23
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP23
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE23
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP23
)
:CONTINUE23
del "%~dp0\Installer-files\%BFX-Continuum%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if exist "%%~I\INSTALL.cmd" GOTO auto-23
GOTO SelectPlugins

:auto-23
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-23
IF ERRORLEVEL 1  GOTO autoinst-23
echo.
:manual-23
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-23
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Cont*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Prompts to ask which version of Mocha to Download
:24-prompt
cls
:: Checking for Mocha Pro Preference
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-ofx.txt" GOTO 24
if exist ".\Installer-files\Installer-Scripts\Settings\mocha-auto-veg.txt" GOTO 24-2
color 0C
echo There are two available verisons of Boris FX Mocha
echo.
echo.
%Print%{231;72;86} 1 is a specially made version of Mocha by Boris FX for Vegas Pro 21 and above. \n
%Print%{244;255;0} It has better integration, but may be outdated. \n
echo.
%Print%{231;72;86} 2 is the OFX version of Mocha by Boris FX. \n
%Print%{244;255;0} It works for ALL versions of Vegas Pro, and may be more updated. \n
echo.
%Print%{231;72;86} 1 = Mocha Vegas \n
%Print%{231;72;86} 2 = Mocha Pro OFX \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 24
IF ERRORLEVEL 1  GOTO 24-2
echo.

:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 4-1
:24
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Mocha Pro*" GOTO alrDown-24
echo Plugin isn't downloaded, continuing to download
GOTO down-24
:alrDown-24
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-24
echo.
:down-24
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Mocha Pro*.rar" del "%%~I\Boris FX Mocha Pro*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/i40USJiA#5rXZ_VvFWbKUq3T6jSXY3A" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down24-error
IF ERRORLEVEL 0 GOTO mega-down24-continue
:mega-down24-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-24
:mega-down24-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-24-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-24-szip
:down-24-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%BFX-Mocha%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP24
:down-24-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%BFX-Mocha%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE24
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP24
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE24
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP24
)
:CONTINUE24
del "%~dp0\Installer-files\%BFX-Mocha%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Pro*") do if exist "%%~I\INSTALL.cmd" GOTO auto-24
GOTO SelectPlugins

:auto-24
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-24
IF ERRORLEVEL 1  GOTO autoinst-24
echo.
:manual-24
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-24
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Pro*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 4-2
:24-2
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Mocha Vegas*" GOTO alrDown-24-2
echo Plugin isn't downloaded, continuing to download
GOTO down-24-2
:alrDown-24-2
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-24-2
echo.
:down-24-2
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Mocha Vegas*.rar" del "%%~I\Boris FX Mocha Vegas*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/Px1zCTQS#FHwFZ5U_bUY06lejrplBAA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down24-2-error
IF ERRORLEVEL 0 GOTO mega-down24-2-continue
:mega-down24-2-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-24-2
:mega-down24-2-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-24-2-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-24-2-szip
:down-24-2-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%BFX-Mocha-Vegas%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP24-2
:down-24-2-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%BFX-Mocha-Vegas%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE24-2
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP24-2
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE24-2
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP24-2
)
:CONTINUE24-2
del "%~dp0\Installer-files\%BFX-Mocha-Vegas%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha Vegas*") do if exist "%%~I\INSTALL.cmd" GOTO auto-24-2
GOTO SelectPlugins

:auto-24-2
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-24-2
IF ERRORLEVEL 1  GOTO autoinst-24-2
echo.
:manual-24-2
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-24-2
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Mocha Vegas*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins





:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 5
:25
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Silho*" GOTO alrDown-25
echo Plugin isn't downloaded, continuing to download
GOTO down-25
:alrDown-25
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-25
echo.
:down-25
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\Boris FX Silho*.rar" del "%%~I\Boris FX Silho*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/CwcmwCzQ#lNldUriLTu1HOOnGn2iKFw" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down25-error
IF ERRORLEVEL 0 GOTO mega-down25-continue
:mega-down25-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-25
:mega-down25-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-25-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-25-szip
:down-25-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%BFX-Silhouette%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP25
:down-25-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%BFX-Silhouette%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE25
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP25
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE25
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP25
)
:CONTINUE25
del "%~dp0\Installer-files\%BFX-Silhouette%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do if exist "%%~I\INSTALL.cmd" GOTO auto-25
GOTO SelectPlugins

:auto-25
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-25
IF ERRORLEVEL 1  GOTO autoinst-25
echo.
:manual-25
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-25
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\Boris FX Silho*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 6
:26
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\FXHOME Ign*" GOTO alrDown-26
echo Plugin isn't downloaded, continuing to download
GOTO down-26
:alrDown-26
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-26
echo.
:down-26
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\FXHOME Ign*.rar" del "%%~I\FXHOME Ign*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/X4MglbpQ#6Y_jba-d2k8pT6RZ_E9Cow" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down26-error
IF ERRORLEVEL 0 GOTO mega-down26-continue
:mega-down26-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-26
:mega-down26-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-26-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-26-szip
:down-26-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%FXH-Ignite%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP26
:down-26-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%FXH-Ignite%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE26
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP26
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE26
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP26
)
:CONTINUE26
del "%~dp0\Installer-files\%FXH-Ignite%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do if exist "%%~I\INSTALL.cmd" GOTO auto-26
GOTO SelectPlugins

:auto-26
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-26
IF ERRORLEVEL 1  GOTO autoinst-26
echo.
:manual-26
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-26
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\FXHOME Ign*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 7
:27
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\MAXON Red Giant Magic Bull*" GOTO alrDown-27
echo Plugin isn't downloaded, continuing to download
GOTO down-27
:alrDown-27
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-27
echo.
:down-27
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\MAXON Red Giant Magic Bull*.rar" del "%%~I\MAXON Red Giant Magic Bull*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/WpdhxKRJ#Q95iwbuJ9jHpJbPBWGKJuA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down27-error
IF ERRORLEVEL 0 GOTO mega-down27-continue
:mega-down27-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-27
:mega-down27-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-27-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-27-szip
:down-27-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%MXN-MBL%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP27
:down-27-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%MXN-MBL%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE27
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP27
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE27
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP27
)
:CONTINUE27
del "%~dp0\Installer-files\%MXN-MBL%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do if exist "%%~I\INSTALL.cmd" GOTO auto-27
GOTO SelectPlugins

:auto-27
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-27
IF ERRORLEVEL 1  GOTO autoinst-27
echo.
:manual-27
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-27
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 1
:221
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\MAXON Red Giant Uni*" GOTO alrDown-221
echo Plugin isn't downloaded, continuing to download
GOTO down-221
:alrDown-221
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-221
echo.
:down-221
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\MAXON Red Giant Uni*.rar" del "%%~I\MAXON Red Giant Uni*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/mt1EVBxC#fk6rSqjgjHVr4_p6C-oPKA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down221-error
IF ERRORLEVEL 0 GOTO mega-down221-continue
:mega-down221-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-221
:mega-down221-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-221-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-221-szip
:down-221-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%MXN-Universe%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP221
:down-221-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%MXN-Universe%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE221
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP221
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE221
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP221
)
:CONTINUE221
del "%~dp0\Installer-files\%MXN-Universe%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do if exist "%%~I\INSTALL.cmd" GOTO auto-221
GOTO SelectPlugins2

:auto-221
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-221
IF ERRORLEVEL 1  GOTO autoinst-221
echo.
:manual-221
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-221
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\MAXON Red Giant Uni*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 2
:222
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\NewBlueFX Titler*" GOTO alrDown-222
echo Plugin isn't downloaded, continuing to download
GOTO down-222
:alrDown-222
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-222
echo.
:down-222
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\NewBlueFX Titler*.rar" del "%%~I\NewBlueFX Titler*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/S1Fh0LSC#7ghSUmyFOS1SnuNCtUIrfg" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down222-error
IF ERRORLEVEL 0 GOTO mega-down222-continue
:mega-down222-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-222
:mega-down222-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-222-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-222-szip
:down-222-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%NFX-Titler%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP222
:down-222-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%NFX-Titler%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE222
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP222
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE222
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP222
)
:CONTINUE222
del "%~dp0\Installer-files\%NFX-Titler%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do if exist "%%~I\INSTALL.cmd" GOTO auto-222
GOTO SelectPlugins2

:auto-222
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-222
IF ERRORLEVEL 1  GOTO autoinst-222
echo.
:manual-222
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-222
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Titler*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 3
:223
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\NewBlueFX Total*" GOTO alrDown-223
echo Plugin isn't downloaded, continuing to download
GOTO down-223
:alrDown-223
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-223
echo.
:down-223
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\NewBlueFX Total*.rar" del "%%~I\NewBlueFX Total*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/zoUEkaAL#aX10JJWbdmCY8IQpDAbnGA" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down223-error
IF ERRORLEVEL 0 GOTO mega-down223-continue
:mega-down223-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-223
:mega-down223-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-223-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-223-szip
:down-223-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%NFX-TotalFX%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP223
:down-223-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%NFX-TotalFX%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE223
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP223
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE223
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP223
)
:CONTINUE223
del "%~dp0\Installer-files\%NFX-TotalFX%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do if exist "%%~I\INSTALL.cmd" GOTO auto-223
GOTO SelectPlugins2

:auto-223
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-223
IF ERRORLEVEL 1  GOTO autoinst-223
echo.
:manual-223
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-223
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\NewBlueFX Total*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2

:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 4
:224
color 0C
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\REVisionFX Eff*" GOTO alrDown-224
echo Plugin isn't downloaded, continuing to download
GOTO down-224
:alrDown-224
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-224
echo.
:down-224
cls
echo Initializing Download...
:: megacmd command
for /D %%I in (".\Installer-files") do if exist "%%~I\REVisionFX Eff*.rar" del "%%~I\REVisionFX Eff*.rar" 2>1 >nul
call mega-get -m --ignore-quota-warn "https://mega.nz/folder/rxlmBT4a#2GFmfaD306SjX9jQR-DxGQ" "%~dp0Installer-files"
IF ERRORLEVEL 1 GOTO mega-down224-error
IF ERRORLEVEL 0 GOTO mega-down224-continue
:mega-down224-error
echo Failed to connect to MegaCMDServer, retrying...
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
timeout /T 10 /nobreak >nul
GOTO down-224
:mega-down224-continue
color 0C
echo Download Finished!
echo Renaming rar file
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
echo Extracting zipped File
:: Creates directory for Plugins, if not already made. Checks for what file archiver method to use.
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" GOTO down-224-win
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" GOTO down-224-szip
:down-224-win
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
%winrar% x -o+ ".\Installer-files\%RFX-Effections%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP224
:down-224-szip
cd /d "%~dp0\Installer-files"
%szip% x -aoa "%RFX-Effections%" -o"%~dp0\Installer-files\Plugins" 2>nul | FINDSTR /V /R /C:"^Compressing  " /C:"Igor Pavlov" /C:"^Scanning$" /C:"^$" /C:"^Everything is Ok$"
timeout /T 6 /nobreak >nul
cd /d "%~dp0"
cls
GOTO CONTINUE224
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP224
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE224
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP224
)
:CONTINUE224
del "%~dp0\Installer-files\%RFX-Effections%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do if exist "%%~I\INSTALL.cmd" GOTO auto-224
GOTO SelectPlugins2

:auto-224
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-224
IF ERRORLEVEL 1  GOTO autoinst-224
echo.
:manual-224
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-224
cls
echo Launching auto install script...
for /D %%I in ("%~dp0\Installer-files\Plugins\REVisionFX Eff*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:3-Main-check
:: Checks various preferences that are needed later in script, same as Main-check
:: VP-patch-1
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 3-Main
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" break>".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" & GOTO 3-Main
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul del ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" >nul & GOTO 3-Main
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 3-Main
cls
GOTO 3-Main


:3
GOTO 3-Main-check
:3-Main
color 0C
cls
@ECHO OFF
color 0C
Echo            ************************************
Echo            ***    (Option #3) Settings      ***
Echo            ************************************
Echo.
%Print%{255;255;255}		 Select what option you want. \n
echo.
%Print%{231;72;86}            1) Check Software Versions \n
echo.
%Print%{231;72;86}            2) Toggle Vegas Pro Patch:
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" %Print%{0;255;50} [Enabled] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" %Print%{255;0;50} [Disabled] \n
echo.
%Print%{231;72;86}            3) Clean Installer Files \n
echo.
%Print%{231;72;86}            4) Preferences \n
echo.
%Print%{255;112;0}            5) Main Menu \n
echo.
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 5  GOTO Main
IF ERRORLEVEL 4  GOTO 34
IF ERRORLEVEL 3  GOTO 33
IF ERRORLEVEL 2  GOTO 32
IF ERRORLEVEL 1  GOTO 31
echo.

:::::::::::::::::::::::::::::::::::::::
:31
start "" https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/edit?usp=sharing
GOTO 3-Main

:::::::::::::::::::::::::::::::::::::::
:32
if exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 32-enabled
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.UNBAK" if exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.UNBAK" >nul GOTO 32-disabled
if not exist ".\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\vegas210.exe.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\ScriptPortal.Vegas.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\Protein\Protein_x64.4.2.dll.BAK" if not exist "C:\Program Files\VEGAS\VEGAS Pro 21.0\TransitionWPFLibrary.dll.BAK" >nul GOTO 32-disabled-prompt
GOTO 3

:32-enabled
color 0C
::Patch is enabled, proceeds to unpatch and save patched files for later
::Regular=patched > .UNBAK=patched copy, .bak=unpatched > Regular=unpatched, .UNBAK=patched copy
del "%~dp0\Installer-files\Installer-Scripts\Settings\VP-patch-1.txt"
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
echo.
echo No Backup patched files found.
echo Please run the patch through the Main Menu under Vegas Pro
timeout /T 6 /nobreak >nul
GOTO 3-Main



:::::::::::::::::::::::::::::::::::::::
:33
color 0C
cls
echo Are you sure you want to clean all files from the installer?
echo This will remove all downloaded files, but will not uninstall any Vegas software or any Plugin.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO clean-33
echo.
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
olor 0C
cls
@ECHO OFF
color 0C
Echo            ***************************
Echo            ***    Preferences      ***
Echo            ***************************
Echo.
%Print%{255;255;255}		 Select what option you want. \n
echo.
%Print%{231;72;86}            1) Toggle Auto Updating:
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-1.txt" %Print%{0;255;50} [Enabled] \n
if exist ".\Installer-files\Installer-Scripts\Settings\auto-update-2.txt" %Print%{255;0;50} [Disabled] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\auto-update*.txt" %Print%{255;0;50} [N/A] \n
echo.
%Print%{231;72;86}            2) Toggle Archiving Method:
if exist ".\Installer-files\Installer-Scripts\Settings\archive-win.txt" %Print%{0;255;50} [WinRAR] \n
if exist ".\Installer-files\Installer-Scripts\Settings\archive-szip.txt" %Print%{0;255;50} [7Zip] \n
if not exist ".\Installer-files\Installer-Scripts\Settings\archive*.txt" %Print%{255;0;50} [N/A] \n
echo.
%Print%{231;72;86}            3) Reset All Preferences \n
echo.
%Print%{255;112;0}            4) Main Menu \n
echo.
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-4) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 4  GOTO Python-check
IF ERRORLEVEL 3  GOTO 333
IF ERRORLEVEL 2  GOTO 332
IF ERRORLEVEL 1  GOTO 331
echo.
:::::::::::::::::::::::::::::::::::::::

:331
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
color 0C
Echo.
%Print%{231;72;86}Are you sure you want to delete
%Print%{244;255;0} ALL
%Print%{231;72;86} preferences? \n
%Print%{231;72;86}The script will ask you for these preferences when opened again. \n
echo.
%Print%{231;72;86}1 = Yes \n
%Print%{231;72;86}2 = No \n
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO 34
IF ERRORLEVEL 1  GOTO 333-cont
echo.
:333-cont
color 0C
echo.
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
taskkill /f /im MEGAcmdServer.exe 2>1 >nul
Timeout /T 3 /Nobreak >nul
@exit