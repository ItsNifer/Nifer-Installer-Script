@echo off
:: ============================================================================
::  Installer Script by Nifer
::  Patch and Script by Nifer
::  Twitter - @NiferEdits
:: ============================================================================

color 0C
%SystemRoot%\System32\chcp.com 28591 >nul
%SystemRoot%\System32\mode.com con cols=105 lines=35
title Start as Admin

:: Colored-print macro (RGB via ANSI escape)
setlocal DisableDelayedExpansion
for /f %%a in ('echo prompt $E ^| cmd') do set "/AE=%%a"
(set \n=^^^
%=Newline DNR=%
)
set Print=For %%n in (1 2)Do If %%n==2 (%\n%
    For /F "Delims=" %%G in ("!Args!")Do (%\n%
      For /F "Tokens=1 Delims={}" %%i in ("%%G")Do Set "Output=%/AE%[0m%/AE%[38;2;%%im!Args:{%%~i}=!"%\n%
      ^< Nul set /P "=!Output:\n=!%/AE%[0m"%\n%
      If "!Output:~-2!"=="\n" (Echo/^&Endlocal)Else (Endlocal)%\n%
    )%\n%
  )Else Setlocal EnableDelayedExpansion ^& Set Args=
setlocal EnableDelayedExpansion

:: Admin elevation check
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1            >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
pushd "%CD%"
cd /d "%~dp0"

:: Basic path + tool variables
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "IF_DIR=%ROOT%\Installer-files"
set "SCR_DIR=%IF_DIR%\Installer-Scripts"
set "SET_DIR=%SCR_DIR%\Settings"
set "LOG_DIR=%IF_DIR%\Logs"
set "PLG_DIR=%IF_DIR%\Plugins"
set "MGX_DIR=%IF_DIR%\Magix Vegas Software"

set wget="%SCR_DIR%\wget.exe"
set UnRAR="%SCR_DIR%\UnRAR.exe"

:: Script version
set "ScriptVersion=v7.2.1"
set "ScriptVersion2=%ScriptVersion:v=%"
set "ScriptVersionDisplay=Version - %ScriptVersion2%"

:: Verify extract + create required dirs
if not exist "%IF_DIR%" goto :FatalNotExtracted
if not exist "%SET_DIR%" mkdir "%SET_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

:: Copy curl into System32 if missing
if not exist "%SystemRoot%\System32\curl.exe" (
    if exist "%SCR_DIR%\curl.exe" xcopy "%SCR_DIR%\curl.exe" "%SystemRoot%\System32\curl.exe*" /I /Q /Y /F >nul 2>&1
)

:: Log File info
set "_my_datetime=%date%_%time%"
set "_my_datetime=%_my_datetime: =_%"
set "_my_datetime=%_my_datetime::=%"
set "_my_datetime=%_my_datetime:/=_%"
set "_my_datetime=%_my_datetime:.=_%"

:: ============================================================================
::  ITEM TABLE
::  Every supported product (software or plugin) is defined once here.
::  Properties:
::    .name      - label shown in menus and reports
::    .group     - "magix" (VEGAS software) or "plugin" (3rd-party)
::    .folder    - subfolder name under Plugins\ or Magix Vegas Software\
::    .root      - parent folder (PLG_DIR or MGX_DIR)
::    .fs_id     - PixelDrain filesystem (folder) ID
::                 to confirm; the JSON's "children" array lists the files.
::    .fs_file   - exact filename to pull from that folder
::    .size      - fallback / static size shown until the JSON fetch completes
::                 (the live size from PixelDrain replaces it at runtime)
::    .regs      - list of reg-query display-name patterns
::    .regexclude- patterns to subtract from the reg-query
::    .optrow    - row number in the selection menu (1..N within group)
:: ============================================================================

set "ITEMS=vp vpdlm ve vi bfxsaph bfxmocha bfxcontin bfxsilho ignite rg nfxtitler nfxtotal rfxeff vpuadd"

:: Magix VEGAS software
set "vp.name=VEGAS Pro"
set "vp.group=magix"
set "vp.root=MGX_DIR"
set "vp.folder=VEGAS Pro"
set "vp.fs_id=bYnZa9LR"
set "vp.fs_file=VEGAS Pro.rar"
set "vp.size=665 MB"
set "vp.regs=VEGAS Pro 2026|VEGAS Pro 23.0|VEGAS Pro 22.0|VEGAS Pro 21.0|VEGAS Pro 20.0|VEGAS Pro 19.0|VEGAS Pro 18.0|VEGAS Pro 17.0|VEGAS Pro 16.0|VEGAS Pro 15.0|VEGAS Pro 14.0"
set "vp.regexclude=Voukoder|Mocha|Deep Learning|Capture"
set "vp.optrow=1"

set "vpdlm.name=VEGAS Pro Deep Learning Models"
set "vpdlm.group=magix"
set "vpdlm.root=MGX_DIR"
set "vpdlm.folder=Deep Learning Models"
set "vpdlm.fs_id=bYnZa9LR"
set "vpdlm.fs_file=AI Models.rar"
set "vpdlm.size=1.38 GB"
set "vpdlm.regs=Deep Learning Models"
set "vpdlm.regexclude="
set "vpdlm.optrow=2"

set "ve.name=VEGAS Effects"
set "ve.group=magix"
set "ve.root=MGX_DIR"
set "ve.folder=VEGAS Effects"
set "ve.fs_id=bYnZa9LR"
set "ve.fs_file=VEGAS Effects.rar"
set "ve.size=205 MB"
set "ve.regs=VEGAS Effects"
set "ve.regexclude="
set "ve.optrow=3"

set "vi.name=VEGAS Image"
set "vi.group=magix"
set "vi.root=MGX_DIR"
set "vi.folder=VEGAS Image"
set "vi.fs_id=bYnZa9LR"
set "vi.fs_file=VEGAS Image.rar"
set "vi.size=105 MB"
set "vi.regs=VEGAS Image"
set "vi.regexclude="
set "vi.optrow=4"

:: 3rd-party plugins OFX
set "bfxsaph.name=BORIS FX - Sapphire"
set "bfxsaph.group=plugin"
set "bfxsaph.root=PLG_DIR"
set "bfxsaph.folder=Boris FX - Sapphire"
set "bfxsaph.fs_id=8yM3boe7"
set "bfxsaph.fs_file=BFX-Sapphire.rar"
set "bfxsaph.size=322 MB"
set "bfxsaph.regs=Boris FX Sapphire Plug-ins"
set "bfxsaph.regexclude=for After Effects|for Adobe|for Photoshop"
set "bfxsaph.optrow=1"

set "bfxmocha.name=BORIS FX - Mocha Pro"
set "bfxmocha.group=plugin"
set "bfxmocha.root=PLG_DIR"
set "bfxmocha.folder=Boris FX - Mocha Pro"
set "bfxmocha.fs_id=8yM3boe7"
set "bfxmocha.fs_file=BFX-Mocha.rar"
set "bfxmocha.size=165 MB"
set "bfxmocha.regs=Boris FX Mocha Plug-ins"
set "bfxmocha.regexclude=for After Effects|for Adobe|for Photoshop"
set "bfxmocha.optrow=2"

set "bfxcontin.name=BORIS FX - Continuum Complete"
set "bfxcontin.group=plugin"
set "bfxcontin.root=PLG_DIR"
set "bfxcontin.folder=Boris FX - Continuum Complete"
set "bfxcontin.fs_id=8yM3boe7"
set "bfxcontin.fs_file=BFX-BCC.rar"
set "bfxcontin.size=790 MB"
set "bfxcontin.regs=Boris FX Continuum|BorisFX Continuum"
set "bfxcontin.regexclude=for After Effects|for Adobe|for Photoshop"
set "bfxcontin.optrow=3"

set "bfxsilho.name=BORIS FX - Silhouette"
set "bfxsilho.group=plugin"
set "bfxsilho.root=PLG_DIR"
set "bfxsilho.folder=Boris FX - Silhouette"
set "bfxsilho.fs_id=8yM3boe7"
set "bfxsilho.fs_file=BFX-Silhouette.rar"
set "bfxsilho.size=1.45 GB"
set "bfxsilho.regs=Boris FX Silhouette|Silhouette"
set "bfxsilho.regexclude="
set "bfxsilho.optrow=4"

set "ignite.name=FXHOME - Ignite Pro"
set "ignite.group=plugin"
set "ignite.root=PLG_DIR"
set "ignite.folder=FXHOME - Ignite Pro"
set "ignite.fs_id=8yM3boe7"
set "ignite.fs_file=FXH-Ignite.rar"
set "ignite.size=430 MB"
set "ignite.regs=Ignite Pro|Ignite Pro by Nifer"
set "ignite.regexclude="
set "ignite.optrow=5"

set "rg.name=MAXON - Red Giant Suite"
set "rg.group=plugin"
set "rg.root=PLG_DIR"
set "rg.folder=MAXON - Red Giant Suite"
set "rg.fs_id=8yM3boe7"
set "rg.fs_file=MXN-RG.rar"
set "rg.size=2.30 GB"
set "rg.regs=Magic Bullet Suite|Universe"
set "rg.regexclude="
set "rg.optrow=6"

set "nfxtitler.name=NEWBLUEFX - Titler Pro 7"
set "nfxtitler.group=plugin"
set "nfxtitler.root=PLG_DIR"
set "nfxtitler.folder=NewBlueFX - Titler Pro 7 Ultimate"
set "nfxtitler.fs_id=8yM3boe7"
set "nfxtitler.fs_file=NFX-Titler.rar"
set "nfxtitler.size=630 MB"
set "nfxtitler.regs=NewBlue Titler Pro 7 Ultimate"
set "nfxtitler.regexclude="
set "nfxtitler.optrow=7"

set "nfxtotal.name=NEWBLUEFX - TotalFX 360"
set "nfxtotal.group=plugin"
set "nfxtotal.root=PLG_DIR"
set "nfxtotal.folder=NewBlueFX - TotalFX 360"
set "nfxtotal.fs_id=8yM3boe7"
set "nfxtotal.fs_file=NFX-TotalFX.rar"
set "nfxtotal.size=790 MB"
set "nfxtotal.regs=NewBlue TotalFX 7|NewBlue TotalFX 360"
set "nfxtotal.regexclude="
set "nfxtotal.optrow=8"

set "rfxeff.name=REVISIONFX - Effections"
set "rfxeff.group=plugin"
set "rfxeff.root=PLG_DIR"
set "rfxeff.folder=REVisionFX - Effections Suite"
set "rfxeff.fs_id=8yM3boe7"
set "rfxeff.fs_file=RFX-Effections.rar"
set "rfxeff.size=50 MB"
set "rfxeff.regs=RE:Vision Effections"
set "rfxeff.regexclude="
set "rfxeff.optrow=9"

set "vpuadd.name=VEGAS Pro 2026 Ultimate Addons"
set "vpuadd.group=plugin"
set "vpuadd.root=PLG_DIR"
set "vpuadd.folder=VEGAS Pro 2026 - Ultimate Addons"
set "vpuadd.fs_id=8yM3boe7"
set "vpuadd.fs_file=VPU-Addons.rar"
set "vpuadd.size=8.19 GB"
set "vpuadd.regs=Boris FX Continuum 2026.1 OFX|Boris FX Continuum 2026 OFX|Boris FX CrumplePop for VST3|Boris FX Sound Forge 2026|Sound Forge Pro 2026|Boris FX Optics 2026|Boris FX SoundApp"
set "vpuadd.regexclude="
set "vpuadd.optrow=10"

:: VEGAS Pro 2026 Ultimate Addons — bundle definition
set "VPU_SUBS=vpu_bcc vpu_crumpl vpu_forge vpu_optics vpu_soundapp"

set "vpu_bcc.name=Boris FX Continuum 2026.1 OFX (for VEGAS Pro 2026)"
set "vpu_bcc.regs=Boris FX Continuum 2026.1 OFX|Boris FX Continuum 2026 OFX"
set "vpu_bcc.regexclude="

set "vpu_crumpl.name=Boris FX CrumplePop for VST3"
set "vpu_crumpl.regs=Boris FX CrumplePop for VST3"
set "vpu_crumpl.regexclude="

set "vpu_forge.name=Boris FX Sound Forge 2026"
set "vpu_forge.regs=Boris FX Sound Forge 2026|Sound Forge Pro 2026"
set "vpu_forge.regexclude="

set "vpu_optics.name=Boris FX Optics 2026"
set "vpu_optics.regs=Boris FX Optics 2026"
set "vpu_optics.regexclude="

set "vpu_soundapp.name=Boris FX SoundApp"
set "vpu_soundapp.regs=Boris FX SoundApp"
set "vpu_soundapp.regexclude="

goto :CheckAutoUpdate

:: ======================================================================================================================
::  AUTO-UPDATE CHECK
:CheckAutoUpdate
:: States: auto-update-0 (undecided), -1 (enabled), -2 (disabled)
if not exist "%SET_DIR%\auto-update*.txt" type nul > "%SET_DIR%\auto-update-0.txt"
if exist "%SET_DIR%\auto-update-1.txt" goto :AutoUpdateEnabled
if exist "%SET_DIR%\auto-update-2.txt" goto :Main
if exist "%SET_DIR%\auto-update-0.txt" goto :AutoUpdatePrompt
goto :Main

:AutoUpdatePrompt
cls
echo/
%Print%{231;72;86}             Auto Updating is Not Enabled. \n
%Print%{0;185;255}    Note: Auto Updating will only check for updates \n
%Print%{0;185;255}              when the script is running. \n
echo/
%Print%{204;204;204}            1) Enable Auto Updating \n
%Print%{204;204;204}            2) Disable Auto Updating \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what option you want." /N
if errorlevel 2 (ren "%SET_DIR%\auto-update-0.txt" "auto-update-2.txt" >nul 2>&1 & goto :Main)
if errorlevel 1 (ren "%SET_DIR%\auto-update-0.txt" "auto-update-1.txt" >nul 2>&1 & goto :AutoUpdateEnabled)
goto :Main

:AutoUpdateEnabled
:: Fetch latest release tag from GitHub
set "ScriptVersionGit="
for /f "tokens=1,* delims=:" %%A in ('curl -kLs https://api.github.com/repos/itsnifer/Nifer-Installer-Script/releases/latest ^| findstr /C:"tag_name"') do set "ScriptVersionGit=%%B"
if not defined ScriptVersionGit goto :Main
set "ScriptVersionGit=%ScriptVersionGit:",=%"
set "ScriptVersionGit=%ScriptVersionGit:"=%"
set "ScriptVersionGit=%ScriptVersionGit:v=%"
set "ScriptVersionGit=%ScriptVersionGit: =%"
if "%ScriptVersion2%"=="%ScriptVersionGit%" (
    echo Script is up to date.
    timeout /T 3 /nobreak >nul
    goto :Main
)
if %ScriptVersion2% GTR %ScriptVersionGit% goto :Main
cls
echo/
%Print%{231;72;86}           Current Script Version is:
%Print%{244;255;0}%ScriptVersion2% \n
%Print%{231;72;86}           Latest Script Version is:
%Print%{244;255;0}%ScriptVersionGit% \n
echo/
:: Show release notes (changelog) from the GitHub release body before the prompt
call :RenderChangelog
echo/
%Print%{204;204;204}            1) Update to the Latest Version \n
%Print%{255;112;0}            2) Skip this update \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what option you want." /N
if errorlevel 2 goto :Main
if errorlevel 1 goto :DoUpdate
goto :Main

:DoUpdate
if not exist "%IF_DIR%\Nifer Installer Script" mkdir "%IF_DIR%\Nifer Installer Script"
cd /d "%IF_DIR%\Nifer Installer Script"
cls
%Print%{231;72;86} Getting Latest Version \n
echo/
for /f "tokens=1,* delims=:" %%A in ('curl -kLs https://api.github.com/repos/itsnifer/Nifer-Installer-Script/releases/latest ^| findstr /C:"browser_download_url"') do curl -kOL %%B
echo/
%Print%{231;72;86} Applying Update \n
set "updateextract="
for %%A in ("*.rar") do set "updateextract=%%A"
if defined updateextract (
    %UnRAR% x -u -y -inul "%updateextract%"
    del "%updateextract%" 2>nul
)
if exist "%IF_DIR%\Nifer Installer Script\Installer-files\Installer-Scripts\Update.cmd" (
    start "" "%IF_DIR%\Nifer Installer Script\Installer-files\Installer-Scripts\Update.cmd"
)
exit

:: ======================================================================================================================
:Main
cd /d "%ROOT%"
call :ResetRunState
title Installer Script by Nifer
:: One-time prefetch of live PixelDrain sizes (only first time we hit Main)
if not defined PREFETCH_DONE call :ShowPrefetchAndRun
cls
echo/
%Print%{231;72;86}           Installer Script by Nifer \n
%Print%{231;72;86}           Patch and Script by Nifer \n
%Print%{244;255;0}               %ScriptVersionDisplay% \n
%Print%{231;72;86}            Twitter - @NiferEdits \n
echo/
%Print%{204;204;204}            1) VEGAS Software \n
echo/
%Print%{204;204;204}            2) 3rd Party Plugins \n
echo/
%Print%{204;204;204}            3) Settings \n
echo/
echo/
%Print%{0;185;255}            4) Donate to support (Paypal) \n
echo/
%Print%{255;112;0}            5) Quit \n
echo/
%SystemRoot%\System32\choice.exe /C 12345 /M "Type the number (1-5) of what option you want." /N
set "MENU_CHOICE=%errorlevel%"
cls
if %MENU_CHOICE% EQU 5 goto :Quit
if %MENU_CHOICE% EQU 4 goto :Donate
if %MENU_CHOICE% EQU 3 goto :SettingsMenu
if %MENU_CHOICE% EQU 2 (set "ACTIVE_GROUP=plugin" & goto :GroupHub)
if %MENU_CHOICE% EQU 1 (set "ACTIVE_GROUP=magix"  & goto :GroupHub)
goto :Main

:Donate
start "" "https://paypal.me/ItsNifer?country.x=US^&locale.x=en_US"
goto :Main

:Quit
cls
echo Quitting Nifer's Installer Script
echo Twitter - @NiferEdits
timeout /T 3 /nobreak >nul
exit


:: ======================================================================================================================
::  GROUP HUB
:GroupHub
cd /d "%ROOT%"
call :ResetRunState
:: Scan the registry for installed items
echo/
echo                 Loading...
call :ScanAllForGroup "%ACTIVE_GROUP%"
goto :GroupMenu

:GroupMenu
cls
color 0C
echo/
if /I "%ACTIVE_GROUP%"=="magix"  call :PrintMagixHeader
if /I "%ACTIVE_GROUP%"=="plugin" call :PrintPluginHeader
echo/
%Print%{255;255;255}          Currently installed / available items: \n
echo         --------------------------------
echo/
:: Show items without row numbers
call :DisplayGroup 0
echo/
echo         --------------------------------
call :DisplayLegend
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Download \n
%Print%{204;204;204}            2) Uninstall \n
%Print%{255;112;0}            3) Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123 /M "Type the number (1-3) of what you want." /N
set "GH_CHOICE=%errorlevel%"
cls
if %GH_CHOICE% EQU 3 goto :Main
if %GH_CHOICE% EQU 2 goto :UninstallPicker
if %GH_CHOICE% EQU 1 goto :DownloadPicker
goto :GroupMenu

:PrintMagixHeader
echo ******************************************************************
echo ***             ^(Option #1^) VEGAS Software               ***
echo ******************************************************************
exit /b

:PrintPluginHeader
echo *****************************************************************
echo ***          ^(Option #2^) 3rd Party Plugins for OFX            ***
echo *****************************************************************
exit /b

:: ======================================================================================================================
::  DOWNLOAD PICKER — user selects which items to download/install
:DownloadPicker
cls
color 0C
echo/
if /I "%ACTIVE_GROUP%"=="magix"  call :PrintMagixHeader
if /I "%ACTIVE_GROUP%"=="plugin" call :PrintPluginHeader
if /I "%ACTIVE_GROUP%"=="magix"  %Print%{255;255;255}         Available software to Download: \n
if /I "%ACTIVE_GROUP%"=="plugin" %Print%{255;255;255}         Available plugins to Download: \n
echo         --------------------------------
echo/
:: Show items WITH row numbers
call :DisplayGroup 1
:: Show an "ALL" option
call :CountGroupItems
echo/
if /I "%ACTIVE_GROUP%"=="plugin" %Print%{0;185;255}            %GROUP_COUNT_PLUS1%) ALL PLUGINS (15 GB) \n
if /I not "%ACTIVE_GROUP%"=="plugin" %Print%{0;185;255}            %GROUP_COUNT_PLUS1%) ALL SOFTWARE (2.15 GB) \n
echo/
echo         --------------------------------
call :DisplayLegend
echo         --------------------------------
echo/
%Print%{204;204;204}Type your choices with a space after each choice
%Print%{255;112;0}(ie: 1 2 3 4) \n
set "choices="
set /p "choices=Type and press Enter when finished: "
if not defined choices (
    echo Please enter a valid option
    goto :DownloadPicker
)
:: Expand "ALL" (the GROUP_COUNT_PLUS1 number) into every row
call :ExpandAll "%choices%" choices
:: Clear old picks
call :ClearPicks
:: numeric choices into PICK.<id>=1
call :ApplyPicksByRow "%choices%"
if %PICKS_ANY% EQU 0 (
    echo/
    echo No valid selections were made.
    pause
    goto :DownloadPicker
)
goto :ConfirmDownload

:ConfirmDownload
cls
color 0C
echo/
if /I "%ACTIVE_GROUP%"=="plugin"     %Print%{231;72;86} Are you sure you want to install these selected plugins? \n
if /I not "%ACTIVE_GROUP%"=="plugin" %Print%{231;72;86} Are you sure you want to install these selected programs? \n
echo         --------------------------------
echo/
call :DisplayPicked
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Yes, continue \n
%Print%{255;112;0}            2) No, go back \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "CD_CHOICE=%errorlevel%"
cls
if %CD_CHOICE% EQU 2 goto :DownloadPicker
:: For the Ultimate Addons bundle, show a one-time info popup so the user
:: knows what's bundled inside before committing to the ~8 GB download.
if defined PICK.vpuadd if not defined VPUADD_CONFIRMED goto :VPUAddPicker
goto :CheckExistingVPBeforeInstall

:: ======================================================================================================================
::  VPU ADD-ONS BUNDLE
:VPUAddPicker
:: Scan registry for each sub-product so we can show installed/not-installed.
for %%I in (%VPU_SUBS%) do call :ScanItem %%I
cls
color 0C
echo/
%Print%{231;72;86}      VEGAS Pro 2026 Ultimate Addons - Bundle Contents \n
echo         --------------------------------
echo/
%Print%{0;185;255} This bundle includes the following software and plugins: \n
echo/
for %%I in (%VPU_SUBS%) do call :VPUAddDisplaySub %%I
echo/
echo         --------------------------------
echo/
%Print%{244;255;0} Note: Continuum Complete 2026.1 included in this bundle is \n
%Print%{244;255;0}       built specifically for VEGAS Pro 2026. \n
echo/
%Print%{0;185;255} Total download size:
call :ResolveSizeFor "vpuadd" VPU_DL_SIZE
%Print%{0;185;255} (%VPU_DL_SIZE%) \n
echo/
%Print%{255;255;255} Do you want to continue with the Ultimate Addons download? \n
echo/
%Print%{204;204;204}  1) Yes, continue \n
%Print%{0;185;255}  2) Skip - download the rest of the queue without Ultimate Addons \n
%Print%{255;112;0}  3) No, go back \n
echo/
%SystemRoot%\System32\choice.exe /C 123 /M "Type the number (1-3) of what you want." /N
set "VPU_CHOICE=%errorlevel%"
cls
if %VPU_CHOICE% EQU 3 goto :DownloadPicker
if %VPU_CHOICE% EQU 2 (set "VPUADD_CONFIRMED=1" & set "PICK.vpuadd=" & goto :VPUAddSkip)
if %VPU_CHOICE% EQU 1 (set "VPUADD_CONFIRMED=1" & goto :CheckExistingVPBeforeInstall)
goto :VPUAddPicker

:VPUAddSkip
:: User chose to skip Ultimate Addons but keep the rest of the queue
:: If nothing else is queued, send them back to the picker
set "VPU_OTHER=0"
for %%I in (%ITEMS%) do if defined PICK.%%I set "VPU_OTHER=1"
if "%VPU_OTHER%"=="0" (
    cls
    %Print%{244;255;0} Ultimate Addons was your only selection. Returning to the menu. \n
    timeout /T 3 /nobreak >nul
    goto :DownloadPicker
)
goto :CheckExistingVPBeforeInstall

:VPUAddDisplaySub
:: Renders one sub-product line with [INSTALLED] / [NOT INSTALLED] tag
set "VDS_ID=%~1"
call set "VDS_NAME=%%%VDS_ID%.name%%"
call set "VDS_CNT=%%count.%VDS_ID%%%"
if not defined VDS_CNT set "VDS_CNT=0"
if %VDS_CNT% GEQ 1 %Print%{0;255;50}      [INSTALLED]      %VDS_NAME% \n
if %VDS_CNT% LSS 1 %Print%{231;72;86}      [NOT INSTALLED]  %VDS_NAME% \n
exit /b

:: ======================================================================================================================
::  Prompt to uninstall existing VEGAS Pro(s) before installing VP2026
:CheckExistingVPBeforeInstall
:: Only relevant if VP is in the pick list
if not defined PICK.vp goto :CheckAlreadyDownloaded
:: Build list of installed VP entries
call :ListInstalledVP
if %VP_INSTALLED_COUNT% EQU 0 goto :CheckAlreadyDownloaded
cls
color 0C
echo/
%Print%{231;72;86} Found installations of the following: \n
echo ---------------------------------
echo/
for /f "usebackq delims=" %%L in ("%SET_DIR%\VP-Installations-found.txt") do echo  %%L
echo/
echo ---------------------------------
echo/
%Print%{0;185;255}NOTE: You will need to Un-Install previous versions of VEGAS Pro if they match VEGAS Pro 2026. \n
%Print%{0;185;255}      Otherwise, installing VP2026 will not work. Older versions of VP are okay to keep. \n
echo/
%Print%{255;255;255} What do you want to do? \n
%Print%{204;204;204} 1) Select which programs to Uninstall, then continue \n
%Print%{204;204;204} 2) Don't uninstall anything, just continue \n
%Print%{255;112;0} 3) Cancel and return to Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123 /M "Type the number (1-3) of what you want." /N
set "VP_PRE_CHOICE=%errorlevel%"
cls
if %VP_PRE_CHOICE% EQU 3 goto :Main
if %VP_PRE_CHOICE% EQU 2 goto :CheckAlreadyDownloaded
if %VP_PRE_CHOICE% EQU 1 goto :SelectVPToUninstall
goto :CheckAlreadyDownloaded

:SelectVPToUninstall
cls
color 0C
echo/
%Print%{231;72;86} Select which VP installation(s) you want to uninstall \n
echo ---------------------------------
echo/
set /a _n=0
for /f "usebackq delims=" %%L in ("%SET_DIR%\VP-Installations-found.txt") do (
    set /a _n+=1
    call set "VPU_!_n!=%%L"
    call echo   !_n! - %%L
)
set "VPU_MAX=%_n%"
set /a _allnum=_n+1
echo   %_allnum% - ALL OPTIONS
echo/
echo ---------------------------------
echo/
%Print%{231;72;86}Type your choices with a space after each choice
%Print%{244;255;0}(ie: 1 2 3 4) \n
set "vpchoices="
set /p "vpchoices=Type and press Enter when finished: "
if not defined vpchoices goto :SelectVPToUninstall
call :ExpandNumericAll "%vpchoices%" %VPU_MAX% %_allnum% vpchoices
cls
echo/
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo/
for %%N in (%vpchoices%) do (
    call echo   %%VPU_%%N%%
)
echo/
echo ---------------------------------
%Print%{204;204;204} 1 = Yes, Uninstall \n
%Print%{255;112;0} 2 = No, Cancel \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
if errorlevel 2 goto :CheckExistingVPBeforeInstall
if errorlevel 1 goto :DoVPUninstalls
goto :SelectVPToUninstall

:DoVPUninstalls
cls
color 0C
for %%N in (%vpchoices%) do (
    call :UninstallByDisplayName "%%VPU_%%N%%"
)
echo Finished uninstalling selected items
timeout /T 3 /nobreak >nul
goto :CheckAlreadyDownloaded


:: ======================================================================================================================
::  Check if items are already downloaded
:CheckAlreadyDownloaded
set "ALR_ANY=0"
for %%I in (%ITEMS%) do (
    if defined PICK.%%I call :CheckItemAlreadyDownloaded %%I
)
if %ALR_ANY% EQU 0 goto :FetchNamesAndSizes
:: Prompt the user
cls
color 0C
echo/
%Print%{231;72;86} You already have these items downloaded: \n
echo/
for %%I in (%ITEMS%) do (
    if defined ALR.%%I call :DisplayItemName %%I
)
echo/
%Print%{231;72;86} Do you want to re-download? \n
echo/
%Print%{204;204;204} 1) Re-download these items \n
%Print%{204;204;204} 2) Skip these items (still install) \n
%Print%{255;112;0} 3) No, back to Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123 /M "Type the number (1-3) of what you want." /N
set "AD_CHOICE=%errorlevel%"
cls
if %AD_CHOICE% EQU 3 goto :Main
if %AD_CHOICE% EQU 2 (
    rem Remove the download step for these items, keep them for install
    for %%I in (%ITEMS%) do (
        if defined ALR.%%I set "SKIP_DL.%%I=1"
    )
    goto :FetchNamesAndSizes
)
if %AD_CHOICE% EQU 1 goto :FetchNamesAndSizes
goto :FetchNamesAndSizes

:CheckItemAlreadyDownloaded
set "CID=%~1"
call set "CID_ROOT=%%%CID%.root%%"
call set "CID_FOLDER=%%%CID%.folder%%"
if /I "%CID_ROOT%"=="PLG_DIR" (set "CID_FULL=%PLG_DIR%\%CID_FOLDER%") else (set "CID_FULL=%MGX_DIR%\%CID_FOLDER%")
:: consider "already downloaded" if the plugin folder exists AND is not empty
if exist "%CID_FULL%\*" (
    set "ALR.%CID%=1"
    set "ALR_ANY=1"
)
exit /b

:: ======================================================================================================================
::  Build queue of items to download/install, take file sizes from PixelDrain fetch
:FetchNamesAndSizes
cd /d "%ROOT%"
call :BuildQueue
if %QUEUE_SIZE% EQU 0 goto :DownloadFinished
set "QUEUE_POS=1"
goto :DownloadNext

:BuildQueue
set "QUEUE="
set /a QUEUE_SIZE=0
for %%I in (%ITEMS%) do (
    if defined PICK.%%I (
        if not defined SKIP_DL.%%I (
            set "QUEUE=!QUEUE! %%I"
            set /a QUEUE_SIZE+=1
        ) else (
            rem mark for install even though we skip download
            set "INSTALL.%%I=1"
        )
    )
)
exit /b

:: ======================================================================================================================
::  DOWNLOAD LOOP
:DownloadNext
if not defined QUEUE goto :DownloadFinished
for /f "tokens=1* delims= " %%A in ("%QUEUE%") do (
    set "DL_ID=%%A"
    set "QUEUE=%%B"
)
if not defined DL_ID goto :DownloadFinished
call :DownloadOne "%DL_ID%"
set /a QUEUE_POS+=1
goto :DownloadNext

:DownloadOne
set "DL_ID=%~1"
set "DL_RETRY=0"
:DownloadTry
cls
color 0C
call set "DL_NAME=%%%DL_ID%.name%%"
%Print%{0;255;50} Item %QUEUE_POS% of %QUEUE_SIZE% \n
%Print%{0;185;255}Downloading %DL_NAME%, please be patient... \n
:: Resolve destination folder + PixelDrain folder/file IDs
call :ResolveDownloadTarget "%DL_ID%"
if not defined DL_FS_ID goto :DownloadOneNoConfig
if not exist "%DL_TARGET%" mkdir "%DL_TARGET%" >nul 2>&1
call :PixelDrainDownload "%DL_FS_ID%" "%DL_FS_FILE%" "%DL_TARGET%"
:: PixelDrainDownload sets DL_OK=1 on success; size already verified inside
if "%DL_OK%"=="1" (
    set "INSTALL.%DL_ID%=1"
    set "RESULT.%DL_ID%=downloaded"
    exit /b
)
:: Failed
echo/
%Print%{255;0;0}Download Failed! \n
if %DL_RETRY% EQU 0 %Print%{231;72;86}Re-trying download... \n
if %DL_RETRY% EQU 0 set "DL_RETRY=1" & goto :DownloadTry
%Print%{231;72;86}Skipping queue \n
set "RESULT.%DL_ID%=failed"
exit /b

:DownloadOneNoConfig
%Print%{255;0;0}Item has no PixelDrain folder ID configured. Skipping. \n
set "RESULT.%DL_ID%=failed"
timeout /T 3 /nobreak >nul
exit /b

:ResolveDownloadTarget
:: Sets DL_TARGET, DL_FS_ID, DL_FS_FILE based on item id
set "RDT_ID=%~1"
call set "RDT_ROOT=%%%RDT_ID%.root%%"
call set "RDT_FOLDER=%%%RDT_ID%.folder%%"
call set "RDT_FS_ID=%%%RDT_ID%.fs_id%%"
call set "RDT_FS_FILE=%%%RDT_ID%.fs_file%%"
if /I "%RDT_ROOT%"=="PLG_DIR" (set "DL_TARGET=%PLG_DIR%\%RDT_FOLDER%") else (set "DL_TARGET=%MGX_DIR%\%RDT_FOLDER%")
set "DL_FS_ID=%RDT_FS_ID%"
set "DL_FS_FILE=%RDT_FS_FILE%"
:: Treat unfilled placeholders as "no ID configured"
echo %DL_FS_ID% | findstr /B /C:"REPLACE_ME" >nul && set "DL_FS_ID="
exit /b

:: ======================================================================================================================
::  PIXELDRAIN DOWNLOAD - per-item folder JSON workflow
::    %1 = PixelDrain filesystem ID
::    %2 = filename inside that folder
::    %3 = local destination folder
::
::    DL_OK = 1 on success, 0 on failure
:PixelDrainDownload
set "PDD_FS_ID=%~1"
set "PDD_FILE=%~2"
set "PDD_DEST=%~3"
set "DL_OK=0"
if "%PDD_FS_ID%"=="" exit /b
if "%PDD_FILE%"=="" exit /b

:: download the folder's JSON manifest
set "PDD_JSON=%TEMP%\pd_fs_%PDD_FS_ID%.json"
if exist "%PDD_JSON%" del "%PDD_JSON%" >nul 2>&1
%wget% -q --no-check-certificate --output-document="%PDD_JSON%" "https://pixeldrain.com/api/filesystem/%PDD_FS_ID%" 2>nul
if exist "%PDD_JSON%" goto :PDD_FindFile
%Print%{231;72;86}[ERROR] Failed to download PixelDrain JSON for %PDD_FS_ID% \n
exit /b

:PDD_FindFile
:: confirm the file exists in the manifest's children, capture its size
set "PDD_STATUS=NOT_FOUND"
set "PDD_SIZE="
call :ParseJsonSize "%PDD_JSON%" "%PDD_FILE%" PDD_SIZE
del "%PDD_JSON%" >nul 2>&1
if defined PDD_SIZE if not "%PDD_SIZE%"=="" set "PDD_STATUS=FOUND"
if /I "%PDD_STATUS%"=="FOUND" goto :PDD_DoDownload
%Print%{231;72;86}[ERROR] '%PDD_FILE%' not found in PixelDrain folder %PDD_FS_ID% \n
exit /b

:PDD_DoDownload
:: Step 3: download the file directly to the destination with the correct name
set "PDD_OUT=%PDD_DEST%\%PDD_FILE%"
set "PDD_TMP=!PDD_FILE: =__SPC__!"
set "PDD_FILE_URL=!PDD_TMP:__SPC__=%%20!"
if exist "%PDD_OUT%" del "%PDD_OUT%" >nul 2>&1
%wget% --no-check-certificate --output-document="%PDD_OUT%" "https://pixeldrain.com/api/filesystem/%PDD_FS_ID%/%PDD_FILE_URL%"
if exist "%PDD_OUT%" goto :PDD_VerifySize
%Print%{231;72;86}[ERROR] wget failed to write '%PDD_FILE%' \n
exit /b

:PDD_VerifySize
:: verify the downloaded size matches what the manifest reported
for %%G in ("%PDD_OUT%") do set /a PDD_LOCAL=%%~zG
if not defined PDD_SIZE set "PDD_SIZE=0"
if "%PDD_SIZE%"=="0" (
    if %PDD_LOCAL% GTR 0 set "DL_OK=1"
) else (
    if %PDD_LOCAL% EQU %PDD_SIZE% set "DL_OK=1"
    if not "!DL_OK!"=="1" if %PDD_LOCAL% GEQ %PDD_SIZE% set "DL_OK=1"
)
exit /b

:: ======================================================================================================================
::  PREFETCH LIVE SIZES
:ShowPrefetchAndRun
cls
color 0C
echo/
echo/
%Print%{0;185;255}           Fetching latest script information \n
echo/
%Print%{204;204;204}          (this only happens once per session) \n
call :PrefetchLiveSizes
call :RestoreConsole
set "PREFETCH_DONE=1"
exit /b

:RestoreConsole
:: Re-applies the console code page + window size that the script was started with
%SystemRoot%\System32\chcp.com 28591 >nul
%SystemRoot%\System32\mode.com con cols=105 lines=35 >nul
exit /b

:PrefetchLiveSizes
:: Skip the whole prefetch if user disabled it
set "PFS_ANY=0"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
> "%LOG_DIR%\prefetch_debug.log" echo --- prefetch run at %DATE% %TIME% ---

for %%I in (%ITEMS%) do call :PrefetchOne %%I
exit /b

:PrefetchOne
set "PF_ID=%~1"
call set "PF_FS_ID=%%%PF_ID%.fs_id%%"
call set "PF_FS_FILE=%%%PF_ID%.fs_file%%"
:: Skip blanks
if not defined PF_FS_ID exit /b
if not defined PF_FS_FILE exit /b
echo %PF_FS_ID% | findstr /B /C:"REPLACE_ME" >nul && exit /b
call :FetchOneSize "%PF_FS_ID%" "%PF_FS_FILE%" "%PF_ID%"
exit /b

:FetchOneSize
:: %1 = fs_id, %2 = filename, %3 = key suffix for live_size.<key>
set "FOS_FS=%~1"
set "FOS_FILE=%~2"
set "FOS_KEY=%~3"
:: logging
>>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] fs=%FOS_FS% file=%FOS_FILE%

set "FOS_JSON=%TEMP%\pd_size_%FOS_FS%.json"
if exist "%FOS_JSON%" del "%FOS_JSON%" >nul 2>&1
%wget% -q --no-check-certificate --output-document="%FOS_JSON%" "https://pixeldrain.com/api/filesystem/%FOS_FS%" 2>nul
if not exist "%FOS_JSON%" (
    >>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] FAIL: JSON download failed
    exit /b
)
set "FOS_BYTES="
call :ParseJsonSize "%FOS_JSON%" "%FOS_FILE%" FOS_BYTES
del "%FOS_JSON%" >nul 2>&1
:: logging
>>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] bytes=%FOS_BYTES%

if not defined FOS_BYTES exit /b
if "%FOS_BYTES%"=="" exit /b
:: Convert bytes to a readable string (MB / GB)
set "FOS_PRETTY="
call :BytesToHuman %FOS_BYTES% FOS_PRETTY
:: logging
>>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] pretty=%FOS_PRETTY%

if defined FOS_PRETTY if not "%FOS_PRETTY%"=="" set "live_size.%FOS_KEY%=%FOS_PRETTY%"
set "live_bytes.%FOS_KEY%=%FOS_BYTES%"
exit /b

:ParseJsonSize
:: PixelDrain JSON parser. Uses a tiny inline JScript run under cscript
:: %1 = path to JSON file
:: %2 = filename to look up inside the "children" array
:: %3 = output variable name (will receive the byte count, or be left unset)
set "PJS_IN=%~1"
set "PJS_FILE=%~2"
set "PJS_OUT=%~3"
:: Use a versioned filename so any old/broken pd_json_size.js cached from a previous run of the script doesn't interfere
set "PJS_JS=%SCR_DIR%\pd_json_size.js"
if not defined PJS_WRITTEN call :WritePdJsonScript
if not exist "%PJS_JS%" exit /b
set "PJS_BYTES="
for /f "usebackq delims=" %%S in (`cscript //nologo //E:JScript "%PJS_JS%" "%PJS_IN%" "%PJS_FILE%" 2^>nul`) do set "PJS_BYTES=%%S"
if defined PJS_BYTES if not "%PJS_BYTES%"=="" set "%PJS_OUT%=%PJS_BYTES%"
set "PJS_BYTES="
exit /b

:WritePdJsonScript
:: Writes a small JScript file to parse PixelDrain JSON
> "%PJS_JS%" echo var fso=new ActiveXObject("Scripting.FileSystemObject"^);
>>"%PJS_JS%" echo if (WScript.Arguments.length^<2){WScript.Quit(1);}
>>"%PJS_JS%" echo var p=WScript.Arguments(0), n=WScript.Arguments(1);
>>"%PJS_JS%" echo if (^^^!fso.FileExists(p)){WScript.Quit(2);}
>>"%PJS_JS%" echo var f=fso.OpenTextFile(p,1,false), d=f.ReadAll(); f.Close(^);
>>"%PJS_JS%" echo var j; try{j=eval('('+d+')');}catch(e){WScript.Quit(3);}
>>"%PJS_JS%" echo if (^^^!j ^|^| ^^^!j.children){WScript.Quit(4);}
>>"%PJS_JS%" echo for (var i=0;i^<j.children.length;i++){
>>"%PJS_JS%" echo if (j.children[i].name===n){
>>"%PJS_JS%" echo WScript.StdOut.Write(j.children[i].file_size); WScript.Quit(0);
>>"%PJS_JS%" echo }
>>"%PJS_JS%" echo }
>>"%PJS_JS%" echo WScript.Quit(5);
set "PJS_WRITTEN=1"
exit /b

:WriteChangelogScript
:: Writes a small JScript that reads a GitHub release JSON, extracts the
:: 'body' field (the markdown release notes), strips Markdown formatting,
:: and emits one tagged line per source line for the batch renderer:
::   H<TAB>text   -> Markdown header (#, ##, ### etc.)
::   B<TAB>text   -> Bullet point (-, *, +)
::   T<TAB>text   -> Plain text
::   -<TAB>       -> Blank line
:: The leading character lets the renderer dispatch colors without parsing.
:: Implementation note: avoid regex anchors (^/$) inside the source because
:: writing ^ literally through CMD echo requires ^^^^ doubling and gets
:: error-prone. Use charAt/indexOf checks instead.
> "%CLG_JS%" echo var fso=new ActiveXObject("Scripting.FileSystemObject"^);
>>"%CLG_JS%" echo if (WScript.Arguments.length^<1){WScript.Quit(1);}
>>"%CLG_JS%" echo var p=WScript.Arguments(0);
>>"%CLG_JS%" echo if (^^^!fso.FileExists(p)){WScript.Quit(2);}
>>"%CLG_JS%" echo var f=fso.OpenTextFile(p,1,false), d=f.ReadAll(); f.Close(^);
>>"%CLG_JS%" echo var j; try{j=eval('('+d+')');}catch(e){WScript.Quit(3);}
>>"%CLG_JS%" echo if (^^^!j ^|^| typeof j.body^^^!=='string'){WScript.Quit(4);}
>>"%CLG_JS%" echo function strip(s){return s.replace(/[*_`]/g,'');}
>>"%CLG_JS%" echo function trim(s){var a=0,b=s.length;while(a^<b ^&^& s.charAt(a)^<=' ')a++;while(b^>a ^&^& s.charAt(b-1)^<=' ')b--;return s.substring(a,b);}
>>"%CLG_JS%" echo var lines=j.body.replace(/\r/g,'').split('\n');
>>"%CLG_JS%" echo for (var i=0;i^<lines.length;i++){
>>"%CLG_JS%" echo var t=trim(lines[i]);
>>"%CLG_JS%" echo if (t.length===0){WScript.Echo('-\t');continue;}
>>"%CLG_JS%" echo var c=t.charAt(0);
>>"%CLG_JS%" echo if (c==='#'){var k=0;while(k^<t.length ^&^& t.charAt(k)==='#')k++;WScript.Echo('H\t'+strip(trim(t.substring(k))));continue;}
>>"%CLG_JS%" echo if ((c==='-'^|^|c==='*'^|^|c==='+') ^&^& t.charAt(1)===' '){WScript.Echo('B\t'+strip(trim(t.substring(2))));continue;}
>>"%CLG_JS%" echo WScript.Echo('T\t'+strip(t^));
>>"%CLG_JS%" echo }
set "CLG_WRITTEN=1"
exit /b

:RenderChangelog
:: Downloads the full GitHub release JSON, runs the JScript parser to extract
:: the markdown body, and prints each line in the appropriate color.
:: Headers (#, ##, ###) -> blue. Bullets (-, *, +) -> white. Plain text -> light gray.
:: Blank lines -> blank line.
set "CLG_JS=%SCR_DIR%\release_notes.js"
set "CLG_JSON=%TEMP%\release.json"
set "CLG_OUT=%TEMP%\release_notes.txt"
:: --- DIAGNOSTIC LOG (remove after debugging) ---
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
> "%LOG_DIR%\changelog_debug.log" echo --- changelog run at %DATE% %TIME% ---
:: ----
if not defined CLG_WRITTEN call :WriteChangelogScript
if not exist "%CLG_JS%" (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] release_notes.js not written
    exit /b
)
:: Fetch the full release JSON
if exist "%CLG_JSON%" del "%CLG_JSON%" >nul 2>&1
curl -kLsA "Mozilla/5.0" "https://api.github.com/repos/ItsNifer/Nifer-Installer-Script/releases/latest" -o "%CLG_JSON%" 2>nul
if not exist "%CLG_JSON%" (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] curl produced no release.json
    exit /b
)
for %%G in ("%CLG_JSON%") do >>"%LOG_DIR%\changelog_debug.log" echo [OK] release.json size=%%~zG
:: Run JScript -> parsed output to file
if exist "%CLG_OUT%" del "%CLG_OUT%" >nul 2>&1
cscript //nologo //E:JScript "%CLG_JS%" "%CLG_JSON%" > "%CLG_OUT%" 2>>"%LOG_DIR%\changelog_debug.log"
if not exist "%CLG_OUT%" (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] cscript produced no output file
    del "%CLG_JSON%" >nul 2>&1
    exit /b
)
for %%G in ("%CLG_OUT%") do >>"%LOG_DIR%\changelog_debug.log" echo [OK] release_notes.txt size=%%~zG
:: If the parsed file is empty, bail before printing the header
for %%G in ("%CLG_OUT%") do if %%~zG EQU 0 (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] parsed output empty - body field missing or unparseable
    del "%CLG_JSON%" >nul 2>&1
    del "%CLG_OUT%" >nul 2>&1
    exit /b
)
:: Header label so the user knows what's about to print
%Print%{0;185;255}           ==== What's New in This Release ==== \n
echo/
:: Iterate parsed output. Each line is "<TAG><TAB><TEXT>".
for /f "usebackq tokens=1,* delims=	" %%A in ("%CLG_OUT%") do call :RenderChangelogLine "%%A" "%%B"
del "%CLG_JSON%" >nul 2>&1
del "%CLG_OUT%" >nul 2>&1
exit /b

:RenderChangelogLine
:: %1 = tag character (H / B / T / -)
:: %2 = the line text (may contain shell metacharacters like & | < > ^)
:: Uses delayed expansion so %Print% is fed an already-resolved string and
:: doesn't re-parse any special characters in the body text.
set "RCL_TAG=%~1"
set "RCL_TXT=%~2"
if /I "%RCL_TAG%"=="H" %Print%{0;185;255}     !RCL_TXT! \n
if /I "%RCL_TAG%"=="B" %Print%{255;255;255}       - !RCL_TXT! \n
if /I "%RCL_TAG%"=="T" %Print%{204;204;204}     !RCL_TXT! \n
if /I "%RCL_TAG%"=="-" echo/
exit /b

:BytesToHuman
:: %1 = byte count, %2 = output var name
:: CMD's set /a is 32-bit signed (max 2,147,483,647), anything larger overflows
set "BTH_RAW=%~1"
set "BTH_OUT="
if not defined BTH_RAW goto :BTH_Done

call :StrLen "%BTH_RAW%" BTH_LEN
if %BTH_LEN% GEQ 11 goto :BTH_BigGB
if %BTH_LEN% LEQ 9 goto :BTH_Numeric
if "%BTH_RAW%" GTR "2147483647" goto :BTH_BigGB

:BTH_Numeric
:: Safe to use 32-bit set /a here
set /a BTH_B=%BTH_RAW%
if %BTH_B% GEQ 1073741824 goto :BTH_GB
if %BTH_B% GEQ 1048576 goto :BTH_MB
if %BTH_B% GEQ 1024 goto :BTH_KB
set "BTH_OUT=%BTH_B% B"
goto :BTH_Done

:BTH_GB
set /a BTH_INT=BTH_B / 1073741824
set /a BTH_REM=BTH_B - BTH_INT * 1073741824
set /a BTH_FRAC=BTH_REM / 10737418
if %BTH_FRAC% LSS 10 set "BTH_OUT=%BTH_INT%.0%BTH_FRAC% GB"
if %BTH_FRAC% GEQ 10 set "BTH_OUT=%BTH_INT%.%BTH_FRAC% GB"
goto :BTH_Done

:BTH_MB
set /a BTH_MB=BTH_B / 1048576
set "BTH_OUT=%BTH_MB% MB"
goto :BTH_Done

:BTH_KB
set /a BTH_KB=BTH_B / 1024
set "BTH_OUT=%BTH_KB% KB"
goto :BTH_Done

:BTH_BigGB
:: For cases that overflow 32-bit. divide by 10^7
set "BTH_TRUNC=%BTH_RAW:~0,-7%"
set /a BTH_INT=BTH_TRUNC / 107
set /a BTH_REM=BTH_TRUNC - BTH_INT * 107
set /a BTH_FRAC=BTH_REM * 100 / 107
if %BTH_FRAC% LSS 10 set "BTH_OUT=%BTH_INT%.0%BTH_FRAC% GB"
if %BTH_FRAC% GEQ 10 set "BTH_OUT=%BTH_INT%.%BTH_FRAC% GB"
goto :BTH_Done

:BTH_Done
set "%~2=%BTH_OUT%"
exit /b

:StrLen
:: %1 = string, %2 = output var name
set "SL_S=%~1"
set /a SL_N=0
:SL_Loop
if not defined SL_S goto :SL_Done
set "SL_S=%SL_S:~1%"
set /a SL_N+=1
goto :SL_Loop
:SL_Done
set "%~2=%SL_N%"
exit /b

:: ======================================================================================================================
::  EXTRACT PHASE — unpack all downloaded .rar archives in plugin folders
:DownloadFinished
cls
color 0C
echo Downloads Finished!
echo Extracting .rar files
echo/
for %%I in (%ITEMS%) do (
    if defined INSTALL.%%I call :ExtractOne %%I
)
goto :InstallModePrompt

:ExtractOne
set "EX_ID=%~1"
call :ResolveDownloadTarget "%EX_ID%"
:: DL_TARGET holds the destination folder
if not exist "%DL_TARGET%" exit /b
pushd "%DL_TARGET%"
set "EX_RAR="
for %%A in (*.rar) do set "EX_RAR=%%A"
if not defined EX_RAR (popd & exit /b)
call set "EX_NAME=%%%EX_ID%.name%%"
%Print%{244;255;0} Extracting %EX_NAME% \n
%UnRAR% x -u -y -inul "%EX_RAR%"
del "%EX_RAR%" 2>nul
echo Finished
popd
exit /b

:: ======================================================================================================================
::  INSTALL MODE PROMPT
:InstallModePrompt
:: Count failures for display
set /a FAIL_CT=0
for %%I in (%ITEMS%) do (
    if "!RESULT.%%I!"=="failed" set /a FAIL_CT+=1
)
cls
color 0C
echo/
echo How do you want to install?
echo/
echo 1) Auto Install
echo 2) Manual Install
echo/
if %FAIL_CT% GEQ 1 %Print%{244;255;0} %FAIL_CT% item(s) failed to download. Auto Install will skip those. \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "IM_CHOICE=%errorlevel%"
cls
if %IM_CHOICE% EQU 2 goto :ManualInstallInfo
if %IM_CHOICE% EQU 1 goto :AutoInstallLoop
goto :AutoInstallLoop

:ManualInstallInfo
cls
color 0C
echo For manual installation, open this folder:
echo "Installer-files > Plugins > (Plugin Name)" or
echo "Installer-files > Magix Vegas Software > (Software Name)"
echo and follow the instructions in the text file.
echo/
pause
goto :ResultsReport

:: ======================================================================================================================
::  AUTO-INSTALL LOOP
:AutoInstallLoop
set /a INST_POS=0
set /a INST_TOTAL=0
for %%I in (%ITEMS%) do (
    if defined INSTALL.%%I set /a INST_TOTAL+=1
)
if %INST_TOTAL% EQU 0 goto :ResultsReport
for %%I in (%ITEMS%) do (
    if defined INSTALL.%%I (
        set /a INST_POS+=1
        call :AutoInstallOne %%I
    )
)
goto :ResultsReport

:AutoInstallOne
set "AI_ID=%~1"
call set "AI_NAME=%%%AI_ID%.name%%"
call :ResolveDownloadTarget "%AI_ID%"
:: DL_TARGET holds plugin folder
cls
color 0C
%Print%{0;255;50}%INST_POS% out of %INST_TOTAL% \n
echo Launching auto install script for %AI_NAME%
if not exist "%DL_TARGET%" (
    call :NoAutoInstall "%AI_ID%"
    exit /b
)
pushd "%DL_TARGET%"
set "AI_SUB="
for /f "delims=" %%i in ('dir /b /ad-h /t:c /od 2^>nul') do set "AI_SUB=%%i"
if not defined AI_SUB (
    popd
    call :NoAutoInstall "%AI_ID%"
    exit /b
)
if not exist "%AI_SUB%\INSTALL.cmd" (
    popd
    call :NoAutoInstall "%AI_ID%"
    exit /b
)
start "" /wait "%AI_SUB%\INSTALL.cmd"
popd
set "RESULT.%AI_ID%=installed"
exit /b

:NoAutoInstall
set "NAI_ID=%~1"
call set "NAI_NAME=%%%NAI_ID%.name%%"
echo There is no auto install script for %NAI_NAME%.
echo For manual installation, please open:
call set "NAI_ROOT=%%%NAI_ID%.root%%"
call set "NAI_FOLDER=%%%NAI_ID%.folder%%"
if /I "%NAI_ROOT%"=="PLG_DIR" (
    echo "Installer-files\Plugins\%NAI_FOLDER%"
) else (
    echo "Installer-files\Magix Vegas Software\%NAI_FOLDER%"
)
echo and follow the instructions in the text file.
timeout /T 5 /nobreak >nul
:: Keep RESULT as "downloaded" so report shows it correctly
if not defined RESULT.%NAI_ID% set "RESULT.%NAI_ID%=downloaded"
exit /b

:: ======================================================================================================================
::  RESULTS REPORT
:ResultsReport
cd /d "%ROOT%"
:: Save an env dump for debugging
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
set > "%LOG_DIR%\Logs_%_my_datetime%.txt" 2>nul
cls
echo/
%Print%{204;204;204}           Queue Report - Results: \n
echo/
:: Installed successfully
set "HAS_INSTALLED=0"
for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="installed" set "HAS_INSTALLED=1"
if "%HAS_INSTALLED%"=="1" %Print%{0;255;50}             Downloaded ^& Installed \n
if "%HAS_INSTALLED%"=="1" %Print%{0;255;50}        -------------------------------- \n
if "%HAS_INSTALLED%"=="1" for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="installed" call :ReportLine %%I "0;255;50"
if "%HAS_INSTALLED%"=="1" echo/
:: Downloaded only
set "HAS_DLONLY=0"
for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="downloaded" set "HAS_DLONLY=1"
if "%HAS_DLONLY%"=="1" %Print%{244;255;0}           Downloaded ^& Not Installed \n
if "%HAS_DLONLY%"=="1" %Print%{244;255;0}        -------------------------------- \n
if "%HAS_DLONLY%"=="1" for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="downloaded" call :ReportLine %%I "244;255;0"
if "%HAS_DLONLY%"=="1" echo/
:: Failed
set "HAS_FAILED=0"
for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="failed" set "HAS_FAILED=1"
if "%HAS_FAILED%"=="1" %Print%{231;72;86}         Not Downloaded ^& Not Installed \n
if "%HAS_FAILED%"=="1" %Print%{231;72;86}        -------------------------------- \n
if "%HAS_FAILED%"=="1" for %%I in (%ITEMS%) do if "!RESULT.%%I!"=="failed" call :ReportLine %%I "231;72;86"
if "%HAS_FAILED%"=="1" echo/
echo/
%Print%{204;204;204}        -------------------------------- \n
echo/
%SystemRoot%\System32\choice.exe /C 1 /M "        1) Return to the Main Menu" /N
goto :Main

:ReportLine
set "RL_ID=%~1"
set "RL_COLOR=%~2"
call set "RL_NAME=%%%RL_ID%.name%%"
call :ResolveSizeFor "%RL_ID%" RL_SIZE
%Print%{%RL_COLOR%}            %RL_NAME%
%Print%{0;185;255}(%RL_SIZE%) \n
exit /b


:: ======================================================================================================================
::  UNINSTALL FLOW — uninstall selected installed items
:UninstallPicker
if exist "%SET_DIR%\System-Check-0.txt" goto :UninstallNeedsSysCheck

:: Build a list of actually installed items in current group
set /a UNINST_ROWS=0
set "UNINST_ROW_IDS="
for %%I in (%ITEMS%) do call :UninstallPickerRow %%I
if %UNINST_ROWS% EQU 0 goto :NothingToUninstall
cls
color 0C
echo/
%Print%{231;72;86} Select which program(s) you want to uninstall \n
echo ---------------------------------
echo/
set /a _i=0
for %%I in (%UNINST_ROW_IDS%) do (
    set /a _i+=1
    call :EchoNumberedName "!_i!" "%%I"
)
set /a _all=UNINST_ROWS+1
echo/
%Print%{0;185;255} %_all% - ALL OPTIONS \n
echo/
echo ---------------------------------
echo/
%Print%{231;72;86}Type your choices with a space after each choice
%Print%{255;112;0}(ie: 1 2 3 4) \n
set "unchoices="
set /p "unchoices=Type and press Enter when finished: "
if not defined unchoices goto :UninstallPicker
call :ExpandNumericAll "%unchoices%" %UNINST_ROWS% %_all% unchoices
cls
color 0C
echo/
%Print%{231;72;86} Are you sure you want to Uninstall these selected programs? \n
echo ---------------------------------
echo/
for %%N in (%unchoices%) do (
    call :PrintNthFromList %%N "%UNINST_ROW_IDS%"
    call :EchoItemName "!PICKED_ID!"
)
echo/
echo ---------------------------------
%Print%{204;204;204} 1 = Yes, Uninstall \n
%Print%{255;112;0} 2 = No, Cancel \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
if errorlevel 2 goto :UninstallPicker
if errorlevel 1 goto :DoUninstalls
goto :UninstallPicker

:UninstallPickerRow
:: Only rows where count >= 1
set "UPR_ID=%~1"
call set "UPR_GROUP=%%%UPR_ID%.group%%"
call set "UPR_CNT=%%count.%UPR_ID%%%"
if not "%UPR_GROUP%"=="%ACTIVE_GROUP%" exit /b
if not defined UPR_CNT exit /b
if %UPR_CNT% LSS 1 exit /b
set /a UNINST_ROWS+=1
set "UNINST_ROW_IDS=%UNINST_ROW_IDS% %UPR_ID%"
exit /b

:NothingToUninstall
cls
color 0C
echo Nothing installed in this group that the script can uninstall.
echo Returning to menu...
timeout /T 4 /nobreak >nul
goto :GroupMenu

:UninstallNeedsSysCheck
cls
color 0C
echo/
%Print%{231;72;86}To Uninstall with the script, you need
%Print%{244;255;0} System Checks enabled
%Print%{231;72;86} under the script Settings. \n
echo/
%Print%{231;72;86}Returning to the Main Menu...
timeout /T 6 /nobreak >nul
goto :GroupMenu

:DoUninstalls
cls
color 0C
for %%N in (%unchoices%) do (
    call :PrintNthFromList %%N "%UNINST_ROW_IDS%"
    call :UninstallItem "!PICKED_ID!"
)
echo/
echo Finished all uninstall tasks
timeout /T 4 /nobreak >nul
goto :GroupHub

:UninstallItem
set "UI_ID=%~1"
call set "UI_NAME=%%%UI_ID%.name%%"
call set "UI_PATTERNS=%%%UI_ID%.regs%%"
%Print%{244;255;0} %UI_NAME% \n
:UI_NextPat
if not defined UI_PATTERNS exit /b
if "%UI_PATTERNS%"=="" exit /b
set "UI_PAT="
set "_UI_NEXT="
for /f "tokens=1* delims=|" %%A in ("%UI_PATTERNS%") do (
    set "UI_PAT=%%A"
    set "_UI_NEXT=%%B"
)
set "UI_PATTERNS=!_UI_NEXT!"
if defined UI_PAT call :UninstallByDisplayNamePrefix "!UI_PAT!"
:: MAXON MBL + UNI drop their OFX plugin folder
if /I "%UI_ID%"=="rg" forfiles /P "C:\Program Files\Common Files\OFX\Plugins" /M "Magic Bullet Suite*" /C "cmd /c if @isdir==TRUE rmdir /s /q @path" 2>nul
if /I "%UI_ID%"=="rg" forfiles /P "C:\Program Files\Common Files\OFX\Plugins" /M "Red Giant Universe*" /C "cmd /c if @isdir==TRUE rmdir /s /q @path" 2>nul
goto :UI_NextPat

:UninstallByDisplayName
:: Exact match version used for VP uninstalls
set "UDN_NAME=%~1"
for /f "delims=" %%G in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "%UDN_NAME%" /D /E 2^>nul ^| findstr /V "DisplayName"') do (
    for /f "tokens=2,*" %%H in ('reg query "%%G" /V "UninstallString" 2^>nul ^| findstr /I "UninstallString"') do (
        set "MsiStr=%%I"
        call set "MsiStr=%%MsiStr:/I=/X%%"
        call :RunUninstallString
    )
)
exit /b

:UninstallByDisplayNamePrefix
:: Matches entries whose DisplayName contains the substring
set "UDN_PAT=%~1"
for /f "delims=" %%G in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "%UDN_PAT%" /D 2^>nul ^| findstr /V "DisplayName"') do (
    for /f "tokens=2,*" %%H in ('reg query "%%G" /V "UninstallString" 2^>nul ^| findstr /I "UninstallString"') do (
        set "MsiStr=%%I"
        call set "MsiStr=%%MsiStr:/I=/X%%"
        call :RunUninstallString
    )
)
for /f "delims=" %%G in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /S /F "%UDN_PAT%" /D 2^>nul ^| findstr /V "DisplayName"') do (
    for /f "tokens=2,*" %%H in ('reg query "%%G" /V "UninstallString" 2^>nul ^| findstr /I "UninstallString"') do (
        set "MsiStr=%%I"
        call set "MsiStr=%%MsiStr:/I=/X%%"
        call :RunUninstallString
    )
)
exit /b

:RunUninstallString
:: Run a registry UninstallString silently in the background
if not defined MsiStr exit /b
set "_RUS_LOWER=%MsiStr%"
set "_RUS_FLAGS="
set "_RUS_ISBAT="
:: Batch-file uninstallers
echo %MsiStr%|findstr /I /L /C:".bat" >nul && set "_RUS_ISBAT=1"
echo %MsiStr%|findstr /I /L /C:".cmd" >nul && set "_RUS_ISBAT=1"
if defined _RUS_ISBAT (
    call %MsiStr%
    set "MsiStr="
    set "_RUS_FLAGS="
    set "_RUS_LOWER="
    set "_RUS_ISBAT="
    exit /b
)
echo %MsiStr%|findstr /I /C:"msiexec" >nul && set "_RUS_FLAGS=/quiet /norestart"
:: BitRock/InstallBuilder uninstallers (Red Giant products) need unattended mode
if not defined _RUS_FLAGS echo %MsiStr%|findstr /I /C:"Red Giant" >nul && set "_RUS_FLAGS=--mode unattended --unattendedmodeui none"
if not defined _RUS_FLAGS echo %MsiStr%|findstr /I /C:"unins" >nul && set "_RUS_FLAGS=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
if not defined _RUS_FLAGS set "_RUS_FLAGS=/S"
start "" /B /wait %MsiStr% %_RUS_FLAGS% 2>nul
set "MsiStr="
set "_RUS_FLAGS="
set "_RUS_LOWER="
set "_RUS_ISBAT="
exit /b


:: ======================================================================================================================
::  SETTINGS MENU
:SettingsMenu
cd /d "%ROOT%"
cls
color 0C
echo            ************************************
echo            ***    ^(Option #3^) Settings      ***
echo            ************************************
echo/
%Print%{255;255;255}          Select what option you want. \n
echo/
%Print%{244;255;0}            1) Check Software Versions (opens web browser) \n
echo/
%Print%{204;204;204}            2) Toggle System Checks:
if exist "%SET_DIR%\System-Check-0.txt"     %Print%{255;0;50} [Disabled] \n
if not exist "%SET_DIR%\System-Check-0.txt" %Print%{0;255;50} [Enabled] \n
echo/
%Print%{204;204;204}            3) Clear VEGAS Pro Plugin Cache \n
echo/
%Print%{204;204;204}            4) Clean Installer Files \n
echo/
echo/
%Print%{204;204;204}            5) Preferences \n
echo/
%Print%{255;112;0}            6) Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123456 /M "Type the number (1-6) of what you want." /N
set "SM_CHOICE=%errorlevel%"
cls
if %SM_CHOICE% EQU 6 goto :Main
if %SM_CHOICE% EQU 5 goto :PreferencesMenu
if %SM_CHOICE% EQU 4 goto :CleanInstallerFiles
if %SM_CHOICE% EQU 3 goto :ClearVPPluginCache
if %SM_CHOICE% EQU 2 goto :ToggleSysCheck
if %SM_CHOICE% EQU 1 (
    start "" "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/edit?usp=sharing"
    goto :SettingsMenu
)
goto :SettingsMenu

:ToggleSysCheck
if not exist "%SET_DIR%\System-Check*.txt" type nul > "%SET_DIR%\System-Check-1.txt"
if exist "%SET_DIR%\System-Check-1.txt" (
    ren "%SET_DIR%\System-Check-1.txt" "System-Check-0.txt" 2>nul
) else if exist "%SET_DIR%\System-Check-0.txt" (
    ren "%SET_DIR%\System-Check-0.txt" "System-Check-1.txt" 2>nul
)
goto :SettingsMenu

:ClearVPPluginCache
cls
color 0C
echo/
%Print%{231;72;86}Are you sure you want to delete your
%Print%{244;255;0} VEGAS Pro Plugin Cache? \n
%Print%{231;72;86}This will remove the plugin cache for
%Print%{244;255;0}all current installations of VEGAS Pro
%Print%{231;72;86}on your system. \n
%Print%{231;72;86}Upon re-opening VEGAS Pro, it will re-build your plugin cache \n
%Print%{231;72;86}(may take a while depending on how many plugins you have installed). \n
echo/
%Print%{231;72;86}Re-building your plugin cache may resolve issues with \n
%Print%{0;255;50} - Plugins not being detected by VP \n
%Print%{0;255;50} - Plugins crashing VP \n
%Print%{0;255;50} - Old/uninstalled plugins still appearing in the cache \n
echo/
%Print%{204;204;204} 1) Yes \n
%Print%{255;112;0} 2) No  \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "CP_CHOICE=%errorlevel%"
cls
if %CP_CHOICE% EQU 2 goto :SettingsMenu
:: 1) Clear the per-user cache under %localappdata%\VEGAS Pro
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_Ofx*.log) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (plugin_manager_cache.bin) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_plugin_cache.bin) do del "%%~fa" 2>nul
:: 2) Newer Boris FX-branded VEGAS Pro builds (e.g. "Vegas Pro 2026") install
::    under C:\Program Files\BorisFX\ instead of C:\Program Files\VEGAS\.
::    Walk every "Vegas Pro*" subfolder in there and wipe the same cache files
::    that may live inside those install dirs.
if exist "C:\Program Files\BorisFX" (
    for /d %%V in ("C:\Program Files\BorisFX\Vegas Pro*") do (
        for /r "%%V" %%a in (svfx_Ofx*.log) do del "%%~fa" 2>nul
        for /r "%%V" %%a in (plugin_manager_cache.bin) do del "%%~fa" 2>nul
        for /r "%%V" %%a in (svfx_plugin_cache.bin) do del "%%~fa" 2>nul
    )
)
%Print%{0;255;50} Finished clearing your VEGAS Pro Plugin Cache \n
timeout /T 5 /nobreak >nul
goto :SettingsMenu

:CleanInstallerFiles
cls
color 0C
echo Are you sure you want to clean all files from the installer?
echo This will remove all downloaded files, but will NOT uninstall any VEGAS software or plugin.
echo 1 = Yes
echo 2 = No
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "CF_CHOICE=%errorlevel%"
cls
if %CF_CHOICE% EQU 2 goto :SettingsMenu
if %CF_CHOICE% EQU 1 goto :DoCleanFiles
goto :SettingsMenu

:DoCleanFiles
cd /d "%ROOT%"
cls
color 0C
echo Cleaning up VEGAS software files
if exist "%MGX_DIR%" (
    for /d %%D in ("%MGX_DIR%\*") do rmdir /s /q "%%D" 2>nul
    del /q "%MGX_DIR%\*.rar" 2>nul
)
echo Cleaning up plugin files
if exist "%PLG_DIR%" (
    for /d %%D in ("%PLG_DIR%\*") do rmdir /s /q "%%D" 2>nul
    del /q "%PLG_DIR%\*.rar" 2>nul
)
echo Cleaning up extra archive files
del "%IF_DIR%\*.rar" 2>nul
del "%IF_DIR%\*.zip" 2>nul
echo Finished cleaning up all installer files
timeout /T 3 /nobreak >nul
goto :SettingsMenu

:: ======================================================================================================================
::  PREFERENCES MENU
:PreferencesMenu
cls
color 0C
echo            ***************************
echo            ***    Preferences      ***
echo            ***************************
echo/
%Print%{255;255;255}          Select what option you want. \n
echo/
%Print%{204;204;204}            1) Toggle Auto Updating:
if exist "%SET_DIR%\auto-update-1.txt" %Print%{0;255;50} [Enabled] \n
if exist "%SET_DIR%\auto-update-2.txt" %Print%{255;0;50} [Disabled] \n
if not exist "%SET_DIR%\auto-update-1.txt" if not exist "%SET_DIR%\auto-update-2.txt" %Print%{255;0;50} [N/A] \n
echo/
%Print%{204;204;204}            2) Reset All Preferences \n
echo/
%Print%{255;112;0}            3) Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123 /M "Type the number (1-3) of what you want." /N
set "PM_CHOICE=%errorlevel%"
cls
if %PM_CHOICE% EQU 3 goto :Main
if %PM_CHOICE% EQU 2 goto :ResetAllPrefs
if %PM_CHOICE% EQU 1 goto :ToggleAutoUpdate
goto :PreferencesMenu

:ToggleAutoUpdate
if exist "%SET_DIR%\auto-update-1.txt" (
    ren "%SET_DIR%\auto-update-1.txt" "auto-update-2.txt" 2>nul
) else if exist "%SET_DIR%\auto-update-2.txt" (
    ren "%SET_DIR%\auto-update-2.txt" "auto-update-1.txt" 2>nul
) else (
    type nul > "%SET_DIR%\auto-update-1.txt"
)
goto :PreferencesMenu

:ResetAllPrefs
cls
color 0C
echo/
%Print%{231;72;86}Are you sure you want to delete
%Print%{244;255;0} ALL
%Print%{231;72;86} preferences? \n
%Print%{231;72;86}The script will ask you for these preferences when opened again. \n
echo/
%Print%{204;204;204}1 = Yes \n
%Print%{255;112;0}2 = No  \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "RP_CHOICE=%errorlevel%"
cls
if %RP_CHOICE% EQU 2 goto :PreferencesMenu
echo Deleting all user-made preferences
del "%SET_DIR%\*.txt" 2>nul
echo Finished.
timeout /T 3 /nobreak >nul
goto :PreferencesMenu


:: ======================================================================================================================
::  HELPER SUBROUTINES
:FatalNotExtracted
cls
color 0C
echo/
%Print%{231;72;86}             Error: Script contents not found. \n
%Print%{0;185;255}        Please ensure script contents are properly \n
%Print%{0;185;255}              extracted from its zipped file. \n
echo/
%Print%{231;72;86}To extract files: Right click on "Nifer Installer Script.rar" and press "Extract files" \n
%Print%{231;72;86}   Choose a destination to extract the files to, or extract to the current directory. \n
echo/
%Print%{231;72;86}If you have WinRAR or 7zip installed, simply extract the zipped contents. \n
pause
exit /b

:ResetRunState
:: Called at the start of every top-level navigation to clear per-run state
:: NOTE: ACTIVE_GROUP is deliberately NOT cleared here, because it is set by the caller (Main -> GroupHub) right before we arrive
set "VPUADD_CONFIRMED=" 2>nul
set "QUEUE=" 2>nul
set "QUEUE_SIZE=" 2>nul
set "QUEUE_POS=" 2>nul
set "FAIL_CT=" 2>nul
set "INST_POS=" 2>nul
set "INST_TOTAL=" 2>nul
set "HAS_INSTALLED=" 2>nul
set "HAS_DLONLY=" 2>nul
set "HAS_FAILED=" 2>nul
set "ALR_ANY=" 2>nul
set "PICKS_ANY=" 2>nul
set "GROUP_COUNT=" 2>nul
set "GROUP_COUNT_PLUS1=" 2>nul
set "UNINST_ROWS=" 2>nul
set "UNINST_ROW_IDS=" 2>nul
:: Clear per-item flags
for %%I in (%ITEMS%) do (
    set "count.%%I=" 2>nul
    set "PICK.%%I=" 2>nul
    set "ALR.%%I=" 2>nul
    set "SKIP_DL.%%I=" 2>nul
    set "INSTALL.%%I=" 2>nul
    set "RESULT.%%I=" 2>nul
)
:: Clear scan counters for the VPU bundle sub-products
for %%I in (%VPU_SUBS%) do set "count.%%I=" 2>nul
exit /b

:ClearPicks
set "PICKS_ANY=0"
for %%I in (%ITEMS%) do set "PICK.%%I="
exit /b

:: Scan routines
:ScanAllForGroup
:: %1 = "magix" or "plugin"
set "SG=%~1"
for %%I in (%ITEMS%) do (
    call :ScanIfGroup %%I "%SG%"
)
exit /b

:ScanIfGroup
set "SI_ID=%~1"
set "SI_GROUP=%~2"
call set "SI_ITEMGRP=%%%SI_ID%.group%%"
if /I "%SI_ITEMGRP%"=="%SI_GROUP%" call :ScanItem %SI_ID%
exit /b

:ScanItem
:: Sets count.<id>=N where N is the number of installed matches
set "SCAN_ID=%~1"
call set "SCAN_PATTERNS=%%%SCAN_ID%.regs%%"
call set "SCAN_EXCL=%%%SCAN_ID%.regexclude%%"
set /a SCAN_CNT=0
:: Forget any _SEEN_* markers from a previous item's scan
for /f "tokens=1 delims==" %%A in ('set _SEEN_ 2^>nul') do set "%%A="
if not defined SCAN_PATTERNS (
    set "count.%SCAN_ID%=0"
    exit /b
)
:ScanItemLoop
if not defined SCAN_PATTERNS goto :ScanItemFinish
if "%SCAN_PATTERNS%"=="" goto :ScanItemFinish
:: Split on first | — first part to %%A, rest to %%B
set "_NEXT_PAT="
for /f "tokens=1* delims=|" %%A in ("%SCAN_PATTERNS%") do (
    call :ScanOnePattern "%%A"
    set "_NEXT_PAT=%%B"
)
:: When the for variable %%B is empty, _NEXT_PAT stays unset, terminating the loop
set "SCAN_PATTERNS=!_NEXT_PAT!"
goto :ScanItemLoop
:ScanItemFinish
set "count.%SCAN_ID%=%SCAN_CNT%"
exit /b

:ScanOnePattern
:: %1 = display-name search pattern
set "SCAN_PAT=%~1"
if "%SCAN_PAT%"=="" exit /b
for /f "tokens=1,2*" %%J in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "%SCAN_PAT%" 2^>nul ^| findstr /C:"DisplayName"') do call :ScanOneLine "%%J" "%%L"
for /f "tokens=1,2*" %%J in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "%SCAN_PAT%" 2^>nul ^| findstr /C:"DisplayName"') do call :ScanOneLine "%%J" "%%L"
exit /b

:ScanOneLine
:: %1 = the token we expect to be "DisplayName"
:: %2 = the actual display-name value
:: Increments SCAN_CNT unless excluded OR already seen for this item
if /I not "%~1"=="DisplayName" exit /b
set "SCAN_DN=%~2"
call :ScanCheckExcluded
if not "%_excluded%"=="0" exit /b
set "SCAN_KEY=%SCAN_DN: =_%"
set "SCAN_KEY=%SCAN_KEY:.=_%"
set "SCAN_KEY=%SCAN_KEY:-=_%"
set "SCAN_KEY=%SCAN_KEY:(=_%"
set "SCAN_KEY=%SCAN_KEY:)=_%"
set "SCAN_KEY=%SCAN_KEY:,=_%"
set "SCAN_KEY=%SCAN_KEY::=_%"
set "SCAN_KEY=%SCAN_KEY:/=_%"
if defined _SEEN_%SCAN_KEY% exit /b
set "_SEEN_%SCAN_KEY%=1"
set /a SCAN_CNT+=1
exit /b

:ScanCheckExcluded
set "_excluded=0"
if not defined SCAN_EXCL exit /b
if "%SCAN_EXCL%"=="" exit /b
set "_rem=%SCAN_EXCL%"
:SCE_Loop
if not defined _rem exit /b
if "%_rem%"=="" exit /b
set "_one="
for /f "tokens=1* delims=|" %%A in ("%_rem%") do (
    set "_one=%%A"
    set "_rem=%%B"
)
if not defined _one exit /b
set "_check=!SCAN_DN:%_one%=!"
if not "!_check!"=="!SCAN_DN!" set "_excluded=1" & exit /b
goto :SCE_Loop

::Display routines
:DisplayGroup
:: %1 = 1 to show row numbers, 0 to hide them
set "DG_SHOWNUM=%~1"
for %%I in (%ITEMS%) do (
    call :DisplayItemIfInGroup %%I %DG_SHOWNUM%
)
exit /b

:DisplayItemIfInGroup
set "DI_ID=%~1"
set "DI_NUMS=%~2"
call set "DI_GROUP=%%%DI_ID%.group%%"
if /I "%DI_GROUP%"=="%ACTIVE_GROUP%" call :DisplayItem %DI_ID% %DI_NUMS%
exit /b

:DisplayItem
:: %1 = item id, %2 = show row number? (0/1)
set "DI_ID=%~1"
set "DI_NUMS=%~2"
call set "DI_NAME=%%%DI_ID%.name%%"
call :ResolveSizeFor "%DI_ID%" DI_SIZE
call set "DI_ROW=%%%DI_ID%.optrow%%"
call set "DI_CNT=%%count.%DI_ID%%%"
if not defined DI_CNT set "DI_CNT=0"
call :ColorForCount %DI_CNT%
if "%DI_NUMS%"=="1"     %Print%{%COLOR_RGB%}            %DI_ROW%) %DI_NAME%
if not "%DI_NUMS%"=="1" %Print%{%COLOR_RGB%}            %DI_NAME%
%Print%{0;185;255}(%DI_SIZE%) \n
exit /b

:ResolveSizeFor
:: %1 = item id, %2 = output var name. Prefers live_size.<id>, else <id>.size
set "RSF_ID=%~1"
call set "RSF_LIVE=%%live_size.%RSF_ID%%%"
call set "RSF_STATIC=%%%RSF_ID%.size%%"
if defined RSF_LIVE if not "%RSF_LIVE%"=="" (set "%~2=%RSF_LIVE%" & exit /b)
set "%~2=%RSF_STATIC%"
exit /b

:DisplayItemName
set "DIN_ID=%~1"
call set "DIN_NAME=%%%DIN_ID%.name%%"
%Print%{244;255;0} %DIN_NAME% \n
exit /b

:ColorForCount
set /a _n=%~1
if %_n% LEQ 0 set "COLOR_RGB=231;72;86" & exit /b
if %_n% EQU 1 set "COLOR_RGB=0;255;50"  & exit /b
set "COLOR_RGB=244;255;0"
exit /b

:DisplayLegend
set "HAS_RED=0" & set "HAS_GRN=0" & set "HAS_YEL=0"
for %%I in (%ITEMS%) do call :LegendCheck %%I
if "%HAS_RED%"=="1" %Print%{231;72;86}        Red =        not installed \n
if "%HAS_GRN%"=="1" %Print%{0;255;50}        Green =      installed \n
if "%HAS_YEL%"=="1" if /I "%ACTIVE_GROUP%"=="plugin"     %Print%{244;255;0}        Yellow =     multiple installed [May detect AE plugins] \n
if "%HAS_YEL%"=="1" if /I not "%ACTIVE_GROUP%"=="plugin" %Print%{244;255;0}        Yellow =     multiple installed \n
exit /b

:LegendCheck
set "LC_ID=%~1"
call set "LC_GROUP=%%%LC_ID%.group%%"
if /I not "%LC_GROUP%"=="%ACTIVE_GROUP%" exit /b
call set "LC_CNT=%%count.%LC_ID%%%"
if not defined LC_CNT set "LC_CNT=0"
if %LC_CNT% LEQ 0 set "HAS_RED=1"
if %LC_CNT% EQU 1 set "HAS_GRN=1"
if %LC_CNT% GEQ 2 set "HAS_YEL=1"
exit /b

:CountGroupItems
set /a GROUP_COUNT=0
for %%I in (%ITEMS%) do (
    call :CountIfGroup %%I
)
set /a GROUP_COUNT_PLUS1=GROUP_COUNT+1
exit /b

:CountIfGroup
set "CIG_ID=%~1"
call set "CIG_GROUP=%%%CIG_ID%.group%%"
if /I "%CIG_GROUP%"=="%ACTIVE_GROUP%" set /a GROUP_COUNT+=1
exit /b

:: Selection routines
:ExpandAll
:: %1 = input choices string, %2 = out var name
setlocal enabledelayedexpansion
set "_in=%~1"
set "_allnum=%GROUP_COUNT_PLUS1%"
set "_out="
set "_found=0"
for %%X in (%_in%) do if %%X EQU %_allnum% set "_found=1"
if "!_found!"=="1" (
    for /L %%I in (1,1,%GROUP_COUNT%) do set "_out=!_out! %%I"
) else (
    set "_out=%_in%"
)
endlocal & set "%~2=%_out%"
exit /b

:ExpandNumericAll
setlocal enabledelayedexpansion
set "_in=%~1"
set /a _max=%~2
set /a _allnum=%~3
set "_out="
set "_found=0"
for %%X in (%_in%) do if %%X EQU !_allnum! set "_found=1"
if "!_found!"=="1" (
    for /L %%I in (1,1,!_max!) do set "_out=!_out! %%I"
) else (
    set "_out=%_in%"
)
endlocal & set "%~4=%_out%"
exit /b

:ApplyPicksByRow
:: %1 = space-separated row numbers, sets PICK.<id> for matching rows
set "PICKS_ANY=0"
for %%N in (%~1) do (
    call :PickByRow %%N
)
exit /b

:PickByRow
set "PBR_N=%~1"
for %%I in (%ITEMS%) do (
    call :PickByRowCheck %%I %PBR_N%
)
exit /b

:PickByRowCheck
set "PBC_ID=%~1"
set "PBC_N=%~2"
call set "PBC_GROUP=%%%PBC_ID%.group%%"
call set "PBC_ROW=%%%PBC_ID%.optrow%%"
if /I not "%PBC_GROUP%"=="%ACTIVE_GROUP%" exit /b
if not "%PBC_ROW%"=="%PBC_N%" exit /b
set "PICK.%PBC_ID%=1"
set "PICKS_ANY=1"
exit /b

:DisplayPicked
for %%I in (%ITEMS%) do (
    if defined PICK.%%I call :DisplayPickedOne %%I
)
exit /b

:DisplayPickedOne
set "DPO_ID=%~1"
call set "DPO_CNT=%%count.%DPO_ID%%%"
if not defined DPO_CNT set "DPO_CNT=0"
call :ColorForCount %DPO_CNT%
call set "DPO_NAME=%%%DPO_ID%.name%%"
call :ResolveSizeFor "%DPO_ID%" DPO_SIZE
%Print%{%COLOR_RGB%}            %DPO_NAME%
%Print%{0;185;255}(%DPO_SIZE%) \n
exit /b

:PrintNthFromList
set "PNFL_N=%~1"
set "PNFL_LIST=%~2"
set /a _i=0
set "PICKED_ID="
for %%X in (%PNFL_LIST%) do (
    set /a _i+=1
    if !_i! EQU %PNFL_N% set "PICKED_ID=%%X"
)
exit /b

:EchoItemName
set "EIN_ID=%~1"
if not defined EIN_ID exit /b
call set "EIN_NAME=%%%EIN_ID%.name%%"
echo   %EIN_NAME%
exit /b

:EchoNumberedName
set "ENN_N=%~1"
set "ENN_ID=%~2"
if not defined ENN_ID exit /b
call set "ENN_NAME=%%%ENN_ID%.name%%"
echo   %ENN_N% - %ENN_NAME%
exit /b

:: VP specific helpers
:ListInstalledVP
:: Writes the unique VP installation display names to VP-Installations-found.txt and sets VP_INSTALLED_COUNT
set "VP_LOG=%SET_DIR%\VP-Installations-found.txt"
set "VP_LOG_TMP=%SET_DIR%\VP-Installations-found.tmp"
if exist "%VP_LOG%"     del "%VP_LOG%"     2>nul
if exist "%VP_LOG_TMP%" del "%VP_LOG_TMP%" 2>nul
for /f "tokens=1,2*" %%J in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "VEGAS Pro" 2^>nul ^| findstr /C:"DisplayName"')        do call :ListInstalledVPLine "%%J" "%%L"
for /f "tokens=1,2*" %%J in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "VEGAS Pro" 2^>nul ^| findstr /C:"DisplayName"') do call :ListInstalledVPLine "%%J" "%%L"
:: De-duplicate
if exist "%VP_LOG_TMP%" (
    for /f "usebackq delims=" %%L in ("%VP_LOG_TMP%") do (
        findstr /ixc:"%%L" "%VP_LOG%" >nul 2>&1 || >>"%VP_LOG%" echo %%L
    )
)
set /a VP_INSTALLED_COUNT=0
if exist "%VP_LOG%" (
    for /f %%C in ('find /c /v "" ^< "%VP_LOG%" 2^>nul') do set /a VP_INSTALLED_COUNT=%%C
)
if exist "%VP_LOG_TMP%" del "%VP_LOG_TMP%" 2>nul
exit /b

:ListInstalledVPLine
:: %1 = the registry token
:: %2 = the actual DisplayName value
if /I not "%~1"=="DisplayName" exit /b
set "VP_LINE=%~2"
echo %VP_LINE%|findstr /I /C:"Voukoder" /C:"Mocha" /C:"Deep Learning" /C:"Effects" /C:"Image" /C:"Capture" /C:"Patch" >nul && exit /b
if /I "%VP_LINE:~0,9%"=="Boris FX " set "VP_LINE=%VP_LINE:~9%"
>>"%VP_LOG_TMP%" echo %VP_LINE%
exit /b
