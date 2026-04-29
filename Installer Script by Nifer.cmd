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
set "ScriptVersion=v7.2.2"
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

set "vpdlm.name=VEGAS Pro AI Models"
set "vpdlm.group=magix"
set "vpdlm.root=MGX_DIR"
set "vpdlm.folder=VEGAS Pro AI Models"
set "vpdlm.fs_id=bYnZa9LR"
set "vpdlm.fs_file=AI Models.rar"
set "vpdlm.size=1.38 GB"
set "vpdlm.regs=Deep Learning Models|Vegas AI Models"
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
set "ignite.regs=Ignite Pro OFX|Ignite Pro for OFX"
set "ignite.regexclude="
set "ignite.optrow=5"

set "rg.name=MAXON - Red Giant Suite"
set "rg.group=plugin"
set "rg.root=PLG_DIR"
set "rg.folder=MAXON - Red Giant Suite"
set "rg.fs_id=8yM3boe7"
set "rg.fs_file=MXN-RGSuite.rar"
set "rg.size=2.30 GB"
set "rg.regs=Red Giant"
set "rg.regexclude=Magic Bullet PhotoLooks"
set "rg.optrow=6"

set "nfxtitler.name=NEWBLUEFX - Titler Pro 7"
set "nfxtitler.group=plugin"
set "nfxtitler.root=PLG_DIR"
set "nfxtitler.folder=NewBlueFX - Titler Pro 7 Ultimate"
set "nfxtitler.fs_id=8yM3boe7"
set "nfxtitler.fs_file=NFX-Titler.rar"
set "nfxtitler.size=630 MB"
set "nfxtitler.regs=NewBlue Titler Pro 7 Ultimate|NewBlue TotalFX 7"
set "nfxtitler.regexclude="
set "nfxtitler.optrow=7"

set "nfxtotal.name=NEWBLUEFX - TotalFX 360"
set "nfxtotal.group=plugin"
set "nfxtotal.root=PLG_DIR"
set "nfxtotal.folder=NewBlueFX - TotalFX 360"
set "nfxtotal.fs_id=8yM3boe7"
set "nfxtotal.fs_file=NFX-TotalFX.rar"
set "nfxtotal.size=790 MB"
set "nfxtotal.regs=NewBlue TotalFX 360"
set "nfxtotal.regexclude="
set "nfxtotal.optrow=8"

set "rfxeff.name=REVISIONFX - Effections Plus"
set "rfxeff.group=plugin"
set "rfxeff.root=PLG_DIR"
set "rfxeff.folder=REVisionFX - Effections Plus"
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

:: VEGAS Pro 2026 Ultimate Addons bundle
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

:: ======================================================================================================================
:: PATCH ITEMS
set "patch_partilu.name=Boris FX Particle Illusion 2025.5"
set "patch_partilu.regs=Boris FX Particle Illusion 2025.5|Particle Illusion 2025.5"
set "patch_partilu.regexclude="

set "patch_vp2026.name=Boris FX VEGAS Pro 2026"
set "patch_vp2026.regs=Boris FX VEGAS Pro 2026|Boris FX Vegas Pro 2026"
set "patch_vp2026.regexclude="

set "patch_mocha2026.name=Boris FX Mocha Plug-ins 2026 for OFX"
set "patch_mocha2026.regs=Boris FX Mocha Plug-ins 2026 for OFX"
set "patch_mocha2026.regexclude=for After Effects|for Adobe|for Photoshop"

set "PATCH_ITEMS=vpu_bcc vpu_crumpl vpu_forge vpu_optics vpu_soundapp patch_partilu patch_vp2026 patch_mocha2026"

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
echo/
call :DisplayItemTableHeader
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
::  DOWNLOAD PICKER
:DownloadPicker
cls
color 0C
echo/
if /I "%ACTIVE_GROUP%"=="magix"  call :PrintMagixHeader
if /I "%ACTIVE_GROUP%"=="plugin" call :PrintPluginHeader
if /I "%ACTIVE_GROUP%"=="magix"  %Print%{255;255;255}         Available software to Download: \n
if /I "%ACTIVE_GROUP%"=="plugin" %Print%{255;255;255}         Available plugins to Download: \n
echo/
call :DisplayItemTableHeader
call :DisplayGroup 1
call :CountGroupItems
call :GroupTotalSize
if /I "%ACTIVE_GROUP%"=="plugin" (set "GROUP_LABEL=PLUGINS") else (set "GROUP_LABEL=SOFTWARE")
echo/
%Print%{0;185;255}            %GROUP_COUNT_PLUS1%) ALL %GROUP_LABEL% (%GROUP_TOTAL_SIZE%) \n
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
call :ExpandAll "%choices%" choices
call :ClearPicks
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
echo/
call :DisplayItemTableHeader
call :DisplayPicked
echo/
echo         --------------------------------
echo/
%Print%{204;204;204}            1) Yes, continue \n
%Print%{255;112;0}            2) No, go back \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "CD_CHOICE=%errorlevel%"
cls
if %CD_CHOICE% EQU 2 (
    for /f "tokens=1 delims==" %%A in ('set PICK. 2^>nul') do set "%%A="
    goto :GroupHub
)
if defined PICK.vpuadd if not defined VPUADD_CONFIRMED goto :VPUAddPicker
goto :CheckExistingVPBeforeInstall

:: ======================================================================================================================
::  VPU ADDONS BUNDLE
:VPUAddPicker
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
set "VDS_ID=%~1"
call set "VDS_NAME=%%%VDS_ID%.name%%"
call set "VDS_CNT=%%count.%VDS_ID%%%"
if not defined VDS_CNT set "VDS_CNT=0"
if %VDS_CNT% GEQ 1 %Print%{0;255;50}      [INSTALLED]      %VDS_NAME% \n
if %VDS_CNT% LSS 1 %Print%{231;72;86}      [NOT INSTALLED]  %VDS_NAME% \n
exit /b

:: ======================================================================================================================
::  RE-PATCH
:RepatchPicker
for %%I in (%PATCH_ITEMS%) do call :ScanItem %%I
cls
color 0C
echo/
%Print%{231;72;86}      Re-Patch - Detected Installations \n
echo         --------------------------------
echo/
%Print%{0;185;255} The following items will be re-patched if installed: \n
echo/
for %%I in (%PATCH_ITEMS%) do call :RepatchDisplay %%I
echo/
echo         --------------------------------
echo/
%Print%{244;255;0} This will reapply the NiferEdits patch to every detected install. \n
%Print%{244;255;0} Items not installed will be skipped automatically by the patcher. \n
echo/
%Print%{204;204;204}            1) Continue - Patch all installed software \n
%Print%{255;112;0}            2) Cancel - go back \n
echo/
%SystemRoot%\System32\choice.exe /C 12 /M "Type the number (1-2) of what you want." /N
set "RP_CHOICE=%errorlevel%"
cls
if %RP_CHOICE% EQU 2 goto :SettingsMenu
if %RP_CHOICE% EQU 1 goto :RepatchRun
goto :RepatchPicker

:RepatchDisplay
set "RPD_ID=%~1"
call set "RPD_NAME=%%%RPD_ID%.name%%"
call set "RPD_CNT=%%count.%RPD_ID%%%"
if not defined RPD_CNT set "RPD_CNT=0"
if %RPD_CNT% GEQ 1 %Print%{0;255;50}      [INSTALLED]      %RPD_NAME% \n
if %RPD_CNT% LSS 1 %Print%{231;72;86}      [NOT INSTALLED]  %RPD_NAME% \n
exit /b

:RepatchRun
cls
color 0C
echo/
%Print%{0;185;255}     Downloading the latest NiferEdits patch... \n
echo/
:: Download the patch executable from the PixelDrain folder
set "RP_OUT=%SCR_DIR%\NiferEdits_VEGAS_Pro_2026_Patch.exe"
if exist "%RP_OUT%" del "%RP_OUT%" >nul 2>&1
%wget% -q --no-check-certificate --output-document="%RP_OUT%" "https://pixeldrain.com/api/filesystem/3rVxkRD5/NiferEdits_VEGAS_Pro_2026_Patch.exe" 2>nul
if not exist "%RP_OUT%" (
    %Print%{231;72;86}     Download failed. Please check your connection and try again. \n
    echo/
    pause
    goto :SettingsMenu
)
for %%G in ("%RP_OUT%") do if %%~zG LEQ 0 (
    %Print%{231;72;86}     Downloaded file is empty. Please try again later. \n
    del "%RP_OUT%" >nul 2>&1
    echo/
    pause
    goto :SettingsMenu
)
echo/
%Print%{0;185;255}     Running the patch silently. This may take a moment... \n
echo/
start "" /wait "%RP_OUT%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
del "%RP_OUT%" >nul 2>&1
cls
color 0C
echo/
echo/
%Print%{0;255;50}     Everything has been Patched. \n
echo/
%Print%{255;255;255}     Press any key to return to Settings. \n
echo/
pause >nul
goto :SettingsMenu

:: ======================================================================================================================
::  Prompt to uninstall existing VEGAS Pro(s) before installing VP2026
:CheckExistingVPBeforeInstall
if not defined PICK.vp goto :CheckAlreadyDownloaded
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
:: PixelDrainDownload sets DL_OK=1 on success
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
::    DL_OK = 1 on success, 0 on failure
:PixelDrainDownload
set "PDD_FS_ID=%~1"
set "PDD_FILE=%~2"
set "PDD_DEST=%~3"
set "DL_OK=0"
if "%PDD_FS_ID%"=="" exit /b
if "%PDD_FILE%"=="" exit /b

:: download the folder's JSON manifest
set "PDD_JSON=%SCR_DIR%\pd_fs_%PDD_FS_ID%.json"
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
:: download the file directly to the destination with the correct name
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
call :LoadPrefetchCache
if "%CACHE_HIT%"=="1" goto :PrefetchUseCache
%Print%{0;185;255}           Fetching latest script information \n
echo/
%Print%{204;204;204}          (this only happens once per session) \n
call :PrefetchLiveSizes
:: When the "Live Versions" toggle is on, also pull the latest plugin/program versions from the public Google Sheet so DisplayItem can show them
if exist "%SET_DIR%\Live-Versions-1.txt" call :PrefetchLatestVersions
:: Save the parsed results to a disk cache so the next run can skip the network
call :SavePrefetchCache
call :RestoreConsole
set "PREFETCH_DONE=1"
exit /b

:PrefetchUseCache
%Print%{0;185;255}           Using cached script information \n
echo/
%Print%{204;204;204}             (cache refreshes every hour) \n
call :RestoreConsole
set "PREFETCH_DONE=1"
exit /b

:LoadPrefetchCache
:: Sets CACHE_HIT=1 and populates live_size.*, live_bytes.*, latest_ver.* from the cache file IF it exists AND was modified within the last hour. Otherwise CACHE_HIT=0
set "CACHE_HIT=0"
set "CACHE_FILE=%SCR_DIR%\prefetch_cache.txt"
if not exist "%CACHE_FILE%" exit /b
call :WriteCacheAgeScript
set "CACHE_AGE="
for /f "usebackq delims=" %%A in (`cscript //nologo //E:JScript "%SCR_DIR%\cache_age.js" "%CACHE_FILE%" 60 2^>nul`) do set "CACHE_AGE=%%A"
if /I not "%CACHE_AGE%"=="FRESH" exit /b
:: Cache is fresh — load it. Each line is "key=value" and we set them directly
set "_HAS_LATEST=0"
for /f "usebackq delims=" %%L in ("%CACHE_FILE%") do call :LoadCacheLine "%%L"
if exist "%SET_DIR%\Live-Versions-1.txt" if "%_HAS_LATEST%"=="0" exit /b
set "CACHE_HIT=1"
exit /b

:WriteCacheAgeScript
:: Writes a tiny JScript that reports whether a file was modified within the last N minutes
set "CAS_JS=%SCR_DIR%\cache_age.js"
if exist "%CAS_JS%" exit /b
if not exist "%SCR_DIR%" mkdir "%SCR_DIR%" >nul 2>&1
> "%CAS_JS%" echo var args=WScript.Arguments;
>>"%CAS_JS%" echo if(args.length^<2){WScript.StdOut.Write("STALE");WScript.Quit(0);}
>>"%CAS_JS%" echo var fso=new ActiveXObject("Scripting.FileSystemObject");
>>"%CAS_JS%" echo try{var f=fso.GetFile(args(0));var modified=new Date(f.DateLastModified);var now=new Date();var diffMs=now-modified;var maxMs=parseInt(args(1),10)*60*1000;WScript.StdOut.Write(diffMs^<=maxMs?"FRESH":"STALE");}catch(e){WScript.StdOut.Write("STALE");}
exit /b

:LoadCacheLine
set "_LINE=%~1"
if not defined _LINE exit /b
:: Skip comment / empty lines
if "%_LINE:~0,1%"=="#" exit /b
if "%_LINE:~0,1%"==";" exit /b
:: Track whether the cache contains latest_ver entries
if /I "%_LINE:~0,11%"=="latest_ver." set "_HAS_LATEST=1"
:: Set the variable. set's parser handles "key=value" format directly.
set "%_LINE%"
exit /b

:SavePrefetchCache
:: Writes all live_size.*, live_bytes.*, latest_ver.* vars to the cache file.
set "CACHE_FILE=%SCR_DIR%\prefetch_cache.txt"
> "%CACHE_FILE%" echo # Prefetch cache - auto-generated, refreshed hourly
>> "%CACHE_FILE%" echo # Delete this file or change Settings to force a refresh
:: Iterate the var space for each prefix. CMD's "set <prefix>" lists matching vars.
for /f "usebackq delims=" %%V in (`set live_size. 2^>nul`) do >>"%CACHE_FILE%" echo %%V
for /f "usebackq delims=" %%V in (`set live_bytes. 2^>nul`) do >>"%CACHE_FILE%" echo %%V
for /f "usebackq delims=" %%V in (`set latest_ver. 2^>nul`) do >>"%CACHE_FILE%" echo %%V
exit /b

:PrefetchLatestVersions
:: Downloads the same CSV the Settings menu uses
set "SHEET_JS=%SCR_DIR%\sheet_renderer.js"
set "PLV_CSV=%SCR_DIR%\version_sheet.csv"
set "PLV_OUT=%SCR_DIR%\version_sheet.txt"
set "PLV_JS=%SHEET_JS%"
:: DIAGNOSTIC LOG
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
> "%LOG_DIR%\latest_debug.log" echo --- latest run at %DATE% %TIME% ---
:: Force the renderer JS to exist
call :WriteSheetScript
if not exist "%PLV_JS%" (
    >>"%LOG_DIR%\latest_debug.log" echo [FAIL] sheet_renderer.js missing
    exit /b
)
:: Fetch CSV
if exist "%PLV_CSV%" del "%PLV_CSV%" >nul 2>&1
curl -kLsA "Mozilla/5.0" "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/gviz/tq?tqx=out:csv&range=A2:B200&headers=0" -o "%PLV_CSV%" 2>nul
if not exist "%PLV_CSV%" (
    >>"%LOG_DIR%\latest_debug.log" echo [FAIL] curl produced no version_sheet.csv
    exit /b
)
for %%G in ("%PLV_CSV%") do >>"%LOG_DIR%\latest_debug.log" echo [OK] version_sheet.csv size=%%~zG
for %%G in ("%PLV_CSV%") do if %%~zG EQU 0 (del "%PLV_CSV%" >nul 2>&1 & exit /b)
:: Run JS
if exist "%PLV_OUT%" del "%PLV_OUT%" >nul 2>&1
cscript //nologo //E:JScript "%PLV_JS%" "%PLV_CSV%" > "%PLV_OUT%" 2>nul
if not exist "%PLV_OUT%" (
    >>"%LOG_DIR%\latest_debug.log" echo [FAIL] cscript produced no output
    exit /b
)
for %%G in ("%PLV_OUT%") do >>"%LOG_DIR%\latest_debug.log" echo [OK] version_sheet.txt size=%%~zG
:: For each "R<TAB>name<TAB>version" row, find a matching item id and stash the version in latest_ver.<id>
for /f "usebackq tokens=1,2,* delims=	" %%A in ("%PLV_OUT%") do call :StashLatestForRow "%%A" "%%B" "%%C"
:: Dump final state
>>"%LOG_DIR%\latest_debug.log" echo --- final latest_ver.* values ---
for %%I in (%ITEMS%) do call :LogLatestForItem %%I
del "%PLV_CSV%" >nul 2>&1
del "%PLV_OUT%" >nul 2>&1
exit /b

:LogLatestForItem
call set "LLI_VAL=%%latest_ver.%~1%%"
>>"%LOG_DIR%\latest_debug.log" echo   latest_ver.%~1=!LLI_VAL!
exit /b

:StashLatestForRow
:: %1 = tag (R / S), %2 = sheet name, %3 = version
:: Looks up an item id whose .sheet_name (or .name as fallback) matches the sheet's name cell, and stores latest_ver.<id> = version
if /I not "%~1"=="R" exit /b
set "SLR_NAME=%~2"
set "SLR_VER=%~3"
if not defined SLR_NAME exit /b
if not defined SLR_VER exit /b
for %%I in (%ITEMS%) do call :StashLatestMatch "%%I" "%SLR_NAME%" "%SLR_VER%"
exit /b

:StashLatestMatch
:: %1 = item id, %2 = sheet name, %3 = version
:: Tries .sheet_name first, falls back to .name
set "SLM_ID=%~1"
set "SLM_NAME=%~2"
set "SLM_VER=%~3"
call set "SLM_SHEET=%%%SLM_ID%.sheet_name%%"
call set "SLM_REAL=%%%SLM_ID%.name%%"
:: Match via sheet_name if defined, otherwise via .name
if defined SLM_SHEET if /I "%SLM_SHEET%"=="%SLM_NAME%" set "latest_ver.%SLM_ID%=%SLM_VER%" & exit /b
if /I "%SLM_REAL%"=="%SLM_NAME%" set "latest_ver.%SLM_ID%=%SLM_VER%"
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
set "FOS_PRETTY="
set "FOS_BYTES="
set "FOS_JSON=%SCR_DIR%\pd_size_%FOS_FS%.json"
if exist "%FOS_JSON%" del "%FOS_JSON%" >nul 2>&1
%wget% -q --no-check-certificate --output-document="%FOS_JSON%" "https://pixeldrain.com/api/filesystem/%FOS_FS%" 2>nul
if not exist "%FOS_JSON%" (
    >>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] FAIL: JSON download failed (fs=%FOS_FS% file=%FOS_FILE%)
    exit /b
)
call :ParseJsonSize "%FOS_JSON%" "%FOS_FILE%" FOS_BYTES
del "%FOS_JSON%" >nul 2>&1
if not defined FOS_BYTES (
    >>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] FAIL: parse returned empty (fs=%FOS_FS% file=%FOS_FILE%)
    exit /b
)
if "%FOS_BYTES%"=="" (
    >>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] FAIL: parse returned empty (fs=%FOS_FS% file=%FOS_FILE%)
    exit /b
)
call :BytesToHuman %FOS_BYTES% FOS_PRETTY
:: One summary line per item — much cheaper than 4 separate redirects.
>>"%LOG_DIR%\prefetch_debug.log" echo [%FOS_KEY%] OK fs=%FOS_FS% file=%FOS_FILE% bytes=%FOS_BYTES% pretty=%FOS_PRETTY%
if defined FOS_PRETTY if not "%FOS_PRETTY%"=="" set "live_size.%FOS_KEY%=%FOS_PRETTY%"
set "live_bytes.%FOS_KEY%=%FOS_BYTES%"
exit /b

:ParseJsonSize
:: PixelDrain JSON parser. Uses a tiny inline JScript run under cscript
:: %1 = path to JSON file
:: %2 = filename to look up inside the "children" array
:: %3 = output variable name
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
:: Write a small JScript file to parse PixelDrain JSON
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
:: Write a small JScript that reads a GitHub release JSON, extracts the'body' field (the markdown release notes), strips Markdown formatting, and emits one tagged line per source line for the batch renderer
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

:WriteSheetScript
:: Write a small JScript that reads a Google Sheets CSV export and emits one tagged line per data row for the batch renderer
> "%SHEET_JS%" echo var fso=new ActiveXObject("Scripting.FileSystemObject"^);
>>"%SHEET_JS%" echo if (WScript.Arguments.length^<1){WScript.Quit(1);}
>>"%SHEET_JS%" echo var p=WScript.Arguments(0);
>>"%SHEET_JS%" echo if (^^^!fso.FileExists(p)){WScript.Quit(2);}
>>"%SHEET_JS%" echo var f=fso.OpenTextFile(p,1,false), d=f.ReadAll(); f.Close(^);
>>"%SHEET_JS%" echo if (d.length===0){WScript.Quit(3);}
>>"%SHEET_JS%" echo if (d.charAt(0)==='^<'){WScript.Quit(4);}
>>"%SHEET_JS%" echo function trim(s){var a=0,b=s.length;while(a^<b ^&^& s.charAt(a)^<=' ')a++;while(b^>a ^&^& s.charAt(b-1)^<=' ')b--;return s.substring(a,b);}
>>"%SHEET_JS%" echo function parseCsv(text){
>>"%SHEET_JS%" echo var rows=[],row=[],cell='',q=false,i=0,n=text.length;
>>"%SHEET_JS%" echo while (i^<n){
>>"%SHEET_JS%" echo var ch=text.charAt(i);
>>"%SHEET_JS%" echo if (q){
>>"%SHEET_JS%" echo if (ch==='"'){
>>"%SHEET_JS%" echo if (i+1^<n ^&^& text.charAt(i+1)==='"'){cell+='"';i+=2;continue;}
>>"%SHEET_JS%" echo q=false;i++;continue;
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo cell+=ch;i++;continue;
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo if (ch==='"'){q=true;i++;continue;}
>>"%SHEET_JS%" echo if (ch===','){row.push(cell);cell='';i++;continue;}
>>"%SHEET_JS%" echo if (ch==='\r'){i++;continue;}
>>"%SHEET_JS%" echo if (ch==='\n'){row.push(cell);rows.push(row);row=[];cell='';i++;continue;}
>>"%SHEET_JS%" echo cell+=ch;i++;
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo if (cell.length^>0^|^|row.length^>0){row.push(cell);rows.push(row);}
>>"%SHEET_JS%" echo return rows;
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo var rows=parseCsv(d);
>>"%SHEET_JS%" echo WScript.StdErr.WriteLine('[JS] rows.length='+rows.length);
>>"%SHEET_JS%" echo for (var d2=0;d2^<Math.min(rows.length,20);d2++){
>>"%SHEET_JS%" echo WScript.StdErr.WriteLine('[JS] row['+d2+'] cells='+rows[d2].length+' c0='+(rows[d2][0]^|^|'').substring(0,40)+' c1='+(rows[d2][1]^|^|'').substring(0,40));
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo var dataStartIdx=-1;
>>"%SHEET_JS%" echo for (var k=0;k^<rows.length;k++){
>>"%SHEET_JS%" echo var c0=trim(rows[k][0]^|^|''),c1=trim(rows[k][1]^|^|'');
>>"%SHEET_JS%" echo if (c0.toLowerCase()==='name' ^&^& c1.toLowerCase()==='version'){dataStartIdx=k+1;break;}
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo if (dataStartIdx===-1)dataStartIdx=0;
>>"%SHEET_JS%" echo WScript.StdErr.WriteLine('[JS] dataStartIdx='+dataStartIdx);
>>"%SHEET_JS%" echo var sectionEmitted=0;
>>"%SHEET_JS%" echo WScript.Echo('S\tSoftware');
>>"%SHEET_JS%" echo for (var r=dataStartIdx;r^<rows.length;r++){
>>"%SHEET_JS%" echo var name=trim(rows[r][0]^|^|''),ver=trim(rows[r][1]^|^|'');
>>"%SHEET_JS%" echo if (name.length===0 ^&^& ver.length===0){
>>"%SHEET_JS%" echo if (sectionEmitted===0){WScript.Echo('S\tOFX Plugins');sectionEmitted=1;}
>>"%SHEET_JS%" echo continue;
>>"%SHEET_JS%" echo }
>>"%SHEET_JS%" echo if (ver.length===0)continue;
>>"%SHEET_JS%" echo if (sectionEmitted===0 ^&^& name.toLowerCase().indexOf('vegas')^^^!==0){WScript.Echo('S\tOFX Plugins');sectionEmitted=1;}
>>"%SHEET_JS%" echo WScript.Echo('R\t'+name+'\t'+ver^);
>>"%SHEET_JS%" echo }
set "SHEET_WRITTEN=1"
exit /b

:RenderChangelog
:: Downloads the full GitHub release JSON, runs the JScript parser to extract the markdown body, and prints each line in the appropriate color
set "CLG_JS=%SCR_DIR%\release_notes.js"
set "CLG_JSON=%SCR_DIR%\release.json"
set "CLG_OUT=%SCR_DIR%\release_notes.txt"
:: DIAGNOSTIC LOG
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
> "%LOG_DIR%\changelog_debug.log" echo --- changelog run at %DATE% %TIME% ---
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
:: Run JScript > parsed output to file
if exist "%CLG_OUT%" del "%CLG_OUT%" >nul 2>&1
cscript //nologo //E:JScript "%CLG_JS%" "%CLG_JSON%" > "%CLG_OUT%" 2>>"%LOG_DIR%\changelog_debug.log"
if not exist "%CLG_OUT%" (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] cscript produced no output file
    del "%CLG_JSON%" >nul 2>&1
    exit /b
)
for %%G in ("%CLG_OUT%") do >>"%LOG_DIR%\changelog_debug.log" echo [OK] release_notes.txt size=%%~zG
for %%G in ("%CLG_OUT%") do if %%~zG EQU 0 (
    >>"%LOG_DIR%\changelog_debug.log" echo [FAIL] parsed output empty - body field missing or unparseable
    del "%CLG_JSON%" >nul 2>&1
    del "%CLG_OUT%" >nul 2>&1
    exit /b
)
%Print%{231;72;86}           ==== What's New in This Release ==== \n
echo/
for /f "usebackq tokens=1,* delims=	" %%A in ("%CLG_OUT%") do call :RenderChangelogLine "%%A" "%%B"
del "%CLG_JSON%" >nul 2>&1
del "%CLG_OUT%" >nul 2>&1
exit /b

:RenderChangelogLine
:: %1 = tag character (H / B / T / -)
:: %2 = the line text (may contain shell metacharacters like & | < > ^)
set "RCL_TAG=%~1"
set "RCL_TXT=%~2"
if /I "%RCL_TAG%"=="H" %Print%{0;185;255}     !RCL_TXT! \n
if /I "%RCL_TAG%"=="B" %Print%{255;255;255}       - !RCL_TXT! \n
if /I "%RCL_TAG%"=="T" %Print%{204;204;204}     !RCL_TXT! \n
if /I "%RCL_TAG%"=="-" echo/
exit /b

:RenderVersionSheet
set "SHEET_JS=%SCR_DIR%\sheet_renderer.js"
set "SHEET_CSV=%SCR_DIR%\version_sheet.csv"
set "SHEET_OUT=%SCR_DIR%\version_sheet.txt"
set "RVS_OK=0"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
> "%LOG_DIR%\sheet_debug.log" echo --- sheet run at %DATE% %TIME% ---

:: Always rewrite the JS file
if not exist "%SHEET_JS%" (
    >>"%LOG_DIR%\sheet_debug.log" echo [FAIL] sheet_renderer.js not written
    exit /b
)
:: Fetch the CSV export. -L follows redirects, -A sets a UA header
if exist "%SHEET_CSV%" del "%SHEET_CSV%" >nul 2>&1
curl -kLsA "Mozilla/5.0" "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/gviz/tq?tqx=out:csv&range=A2:B200&headers=0" -o "%SHEET_CSV%" 2>>"%LOG_DIR%\sheet_debug.log"
if not exist "%SHEET_CSV%" (
    >>"%LOG_DIR%\sheet_debug.log" echo [FAIL] curl produced no version_sheet.csv
    exit /b
)
for %%G in ("%SHEET_CSV%") do >>"%LOG_DIR%\sheet_debug.log" echo [OK] version_sheet.csv size=%%~zG
:: An empty file or one starting with '<' means we got an HTML sign in page, not real CSV
for %%G in ("%SHEET_CSV%") do if %%~zG EQU 0 (
    >>"%LOG_DIR%\sheet_debug.log" echo [FAIL] CSV file is 0 bytes
    del "%SHEET_CSV%" >nul 2>&1 & exit /b
)
:: Run JScript > tagged output to file
if exist "%SHEET_OUT%" del "%SHEET_OUT%" >nul 2>&1
cscript //nologo //E:JScript "%SHEET_JS%" "%SHEET_CSV%" > "%SHEET_OUT%" 2>>"%LOG_DIR%\sheet_debug.log"
if not exist "%SHEET_OUT%" (
    >>"%LOG_DIR%\sheet_debug.log" echo [FAIL] cscript produced no version_sheet.txt
    del "%SHEET_CSV%" >nul 2>&1
    exit /b
)
for %%G in ("%SHEET_OUT%") do >>"%LOG_DIR%\sheet_debug.log" echo [OK] version_sheet.txt size=%%~zG
for %%G in ("%SHEET_OUT%") do if %%~zG EQU 0 (
    >>"%LOG_DIR%\sheet_debug.log" echo [FAIL] parsed output empty
    del "%SHEET_CSV%" >nul 2>&1
    del "%SHEET_OUT%" >nul 2>&1
    exit /b
)
echo/
%Print%{231;72;86}           ==== Software / Plugin Versions ==== \n
echo         --------------------------------
echo/
for /f "usebackq tokens=1,2,* delims=	" %%A in ("%SHEET_OUT%") do call :RenderVersionSheetLine "%%A" "%%B" "%%C"
echo/
echo         --------------------------------
del "%SHEET_CSV%" >nul 2>&1
del "%SHEET_OUT%" >nul 2>&1
set "RVS_OK=1"
exit /b

:RenderVersionSheetLine
:: %1 = tag character (R = data row, S = section header), %2 = name, %3 = version
set "RVS_TAG=%~1"
set "RVS_NAME=%~2"
set "RVS_VER=%~3"
:: Section header
if /I "%RVS_TAG%"=="S" (
    echo/
    %Print%{244;255;0}        !RVS_NAME! \n
    echo/
    exit /b
)
if /I not "%RVS_TAG%"=="R" exit /b
:: Pad name to 40 chars
call :PadRight "%RVS_NAME%" 40 RVS_NAME_PAD
%Print%{0;255;50}     !RVS_NAME_PAD!
%Print%{0;185;255}!RVS_VER! \n
exit /b

:PadRight
:: %1 = string, %2 = total length, %3 = output var name
:: Appends trailing spaces so the result is exactly N chars wide.
set "PR_S=%~1"
set /a PR_LEN=%~2
set "PR_PAD=                                                                "
:: Force-evaluate length of input via :StrLen helper that already exists
call :StrLen "%PR_S%" PR_CUR
if %PR_CUR% GEQ %PR_LEN% (set "%~3=%PR_S%" & exit /b)
set /a PR_NEED=PR_LEN - PR_CUR
:: Take a slice of PR_PAD of exactly PR_NEED chars
call set "PR_TAIL=%%PR_PAD:~0,!PR_NEED!%%"
set "%~3=%PR_S%%PR_TAIL%"
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
::  EXTRACT PHASE
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
set /a FAIL_CT=0
for %%I in (%ITEMS%) do (
    if "!RESULT.%%I!"=="failed" set /a FAIL_CT+=1
)
cls
color 0C
echo/
echo How do you want to install?
echo/
%Print%{204;204;204} 1) Auto Install \n
%Print%{204;204;204} 2) Manual Install \n
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
%Print%{0;185;255} Opening download folders for manual installation... \n
echo/
set "MII_OPENED=0"
for %%I in (%ITEMS%) do call :ManualInstallOpenOne %%I
if "%MII_OPENED%"=="0" (
    %Print%{231;72;86} No successfully-downloaded items to open. \n
    echo/
    pause
    goto :ResultsReport
)
echo/
%Print%{255;255;255} Each download folder has been opened in Windows Explorer. \n
%Print%{255;255;255} Run the installer in each folder to complete installation. \n
echo/
pause
goto :ResultsReport

:ManualInstallOpenOne
:: %1 = item id. Skips items whose RESULT.<id> isn't "downloaded".
set "MIO_ID=%~1"
call set "MIO_RESULT=%%RESULT.%MIO_ID%%%"
if /I not "%MIO_RESULT%"=="downloaded" exit /b
:: Resolve the item's actual destination folder (PLG_DIR or MGX_DIR + folder name).
call set "MIO_ROOT=%%%MIO_ID%.root%%"
call set "MIO_FOLDER=%%%MIO_ID%.folder%%"
call set "MIO_NAME=%%%MIO_ID%.name%%"
if /I "%MIO_ROOT%"=="PLG_DIR" (set "MIO_PATH=%PLG_DIR%\%MIO_FOLDER%") else (set "MIO_PATH=%MGX_DIR%\%MIO_FOLDER%")
if not exist "%MIO_PATH%" (
    %Print%{231;72;86}   - %MIO_NAME% folder missing: %MIO_PATH% \n
    exit /b
)
%Print%{0;255;50}   - Opening: %MIO_NAME% \n
start "" "%MIO_PATH%"
set "MII_OPENED=1"
exit /b

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
:: quick re-patch in case the patch was overridden
cls
color 0C
echo/
%Print%{0;185;255}     Checking Patch... \n
echo/
:: Download the patch executable from the PixelDrain folder
set "RP_OUT=%SCR_DIR%\NiferEdits_VEGAS_Pro_2026_Patch.exe"
if exist "%RP_OUT%" del "%RP_OUT%" >nul 2>&1
%wget% -q --no-check-certificate --output-document="%RP_OUT%" "https://pixeldrain.com/api/filesystem/3rVxkRD5/NiferEdits_VEGAS_Pro_2026_Patch.exe" 2>nul
if not exist "%RP_OUT%" (
    %Print%{231;72;86}     Download failed. Please check your connection and try again. \n
    echo/
    pause
    goto :ResultsReport-1
)
for %%G in ("%RP_OUT%") do if %%~zG LEQ 0 (
    %Print%{231;72;86}     Downloaded file is empty. Please try again later. \n
    del "%RP_OUT%" >nul 2>&1
    echo/
    pause
    goto :ResultsReport-1
)
start "" /wait "%RP_OUT%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
del "%RP_OUT%" >nul 2>&1
:ResultsReport-1
cls
for /f "tokens=1 delims==" %%A in ('set SCAN_CACHED. 2^>nul') do set "%%A="
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
:: Batch file uninstallers
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
:: BitRock/InstallBuilder uninstallers
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
%Print%{244;255;0}            1) Check Software Versions \n
echo/
%Print%{204;204;204}            2) Clear VEGAS Pro Plugin Cache \n
echo/
%Print%{204;204;204}            3) Clean Installer Files \n
echo/
%Print%{204;204;204}            4) Re-Patch \n
echo/
%Print%{0;185;255}            5) Preferences \n
echo/
%Print%{255;112;0}            6) Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 123456 /M "Type the number (1-6) of what you want." /N
set "SM_CHOICE=%errorlevel%"
cls
if %SM_CHOICE% EQU 6 goto :Main
if %SM_CHOICE% EQU 5 goto :PreferencesMenu
if %SM_CHOICE% EQU 4 goto :RepatchPicker
if %SM_CHOICE% EQU 3 goto :CleanInstallerFiles
if %SM_CHOICE% EQU 2 goto :ClearVPPluginCache
if %SM_CHOICE% EQU 1 goto :CheckVersionSheet
goto :SettingsMenu

:CheckVersionSheet
:: Try to render the public Google Sheet inline. If the fetch or parse fails, fall back to the original behavior of opening it in the user's browser
cls
color 0C
%Print%{0;185;255}           Fetching latest software / plugin versions... \n
echo/
call :RenderVersionSheet
if not "%RVS_OK%"=="1" (
    %Print%{231;72;86} Could not fetch the version sheet inline. Opening in browser instead. \n
    timeout /T 3 /nobreak >nul
    start "" "https://docs.google.com/spreadsheets/d/1W3z_gS1MC7gVIBr9O_W4QgiFWvCIUR815NKKkehWt60/edit?usp=sharing"
    goto :SettingsMenu
)
echo/
%Print%{255;255;255}           Press any key to return to the Settings menu...
pause >nul
goto :SettingsMenu

:ToggleSysCheck
if not exist "%SET_DIR%\System-Check*.txt" type nul > "%SET_DIR%\System-Check-1.txt"
if exist "%SET_DIR%\System-Check-1.txt" (
    ren "%SET_DIR%\System-Check-1.txt" "System-Check-0.txt" 2>nul
) else if exist "%SET_DIR%\System-Check-0.txt" (
    ren "%SET_DIR%\System-Check-0.txt" "System-Check-1.txt" 2>nul
)
goto :PreferencesMenu

:ToggleLiveVersions
:: Default is OFF
if exist "%SET_DIR%\Live-Versions-1.txt" (
    del "%SET_DIR%\Live-Versions-1.txt" 2>nul
) else (
    type nul > "%SET_DIR%\Live-Versions-1.txt"
)
goto :PreferencesMenu

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
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_Ofx*.log) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (plugin_manager_cache.bin) do del "%%~fa" 2>nul
for /r "%localappdata%\VEGAS Pro" %%a in (svfx_plugin_cache.bin) do del "%%~fa" 2>nul
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
%Print%{204;204;204}            2) Toggle System Checks:
if exist "%SET_DIR%\System-Check-0.txt"     %Print%{255;0;50} [Disabled] \n
if not exist "%SET_DIR%\System-Check-0.txt" %Print%{0;255;50} [Enabled] \n
echo/
%Print%{204;204;204}            3) Toggle Display Live Version Names:
if exist "%SET_DIR%\Live-Versions-1.txt"     %Print%{0;255;50} [Enabled] \n
if not exist "%SET_DIR%\Live-Versions-1.txt" %Print%{255;0;50} [Disabled] \n
echo/
%Print%{204;204;204}            4) Reset All Preferences \n
echo/
%Print%{255;112;0}            5) Main Menu \n
echo/
%SystemRoot%\System32\choice.exe /C 12345 /M "Type the number (1-5) of what you want." /N
set "PM_CHOICE=%errorlevel%"
cls
if %PM_CHOICE% EQU 5 goto :Main
if %PM_CHOICE% EQU 4 goto :ResetAllPrefs
if %PM_CHOICE% EQU 3 goto :ToggleLiveVersions
if %PM_CHOICE% EQU 2 goto :ToggleSysCheck
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
for %%I in (%ITEMS%) do (
    set "PICK.%%I=" 2>nul
    set "ALR.%%I=" 2>nul
    set "SKIP_DL.%%I=" 2>nul
    set "INSTALL.%%I=" 2>nul
    set "RESULT.%%I=" 2>nul
)
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
:: Results are cached per session via SCAN_CACHED.<id>
set "SCAN_ID=%~1"
call set "_CACHED=%%SCAN_CACHED.%SCAN_ID%%%"
if defined _CACHED exit /b
call set "SCAN_PATTERNS=%%%SCAN_ID%.regs%%"
call set "SCAN_EXCL=%%%SCAN_ID%.regexclude%%"
set /a SCAN_CNT=0
for /f "tokens=1 delims==" %%A in ('set _SEEN_ 2^>nul') do set "%%A="
:: Forget any cached installed version for this item (we'll re-detect)
set "inst_ver.%SCAN_ID%="
if not defined SCAN_PATTERNS (
    set "count.%SCAN_ID%=0"
    set "SCAN_CACHED.%SCAN_ID%=1"
    exit /b
)
:ScanItemLoop
if not defined SCAN_PATTERNS goto :ScanItemFinish
if "%SCAN_PATTERNS%"=="" goto :ScanItemFinish
set "_NEXT_PAT="
for /f "tokens=1* delims=|" %%A in ("%SCAN_PATTERNS%") do (
    call :ScanOnePattern "%%A"
    set "_NEXT_PAT=%%B"
)
set "SCAN_PATTERNS=!_NEXT_PAT!"
goto :ScanItemLoop
:ScanItemFinish
set "count.%SCAN_ID%=%SCAN_CNT%"
:: Mark this item as scanned for this session.
set "SCAN_CACHED.%SCAN_ID%=1"
:: Special-case the Ultimate Addons bundle
if /I "%SCAN_ID%"=="vpuadd" call :RecountVPUBundle
:: Special-case Boris FX Continuum
if /I "%SCAN_ID%"=="bfxcontin" if %SCAN_CNT% GEQ 1 set "count.bfxcontin=1"
exit /b

:RecountVPUBundle
:: Scans each entry in VPU_SUBS, then sets count.vpuadd = 1 only if ALL of them have a non-zero count, else 0
set "RVB_SAVED_ID=%SCAN_ID%"
set "RVB_ALL=1"
for %%S in (%VPU_SUBS%) do (
    call :ScanItem %%S
    call set "RVB_C=%%count.%%S%%"
    if not defined RVB_C set "RVB_C=0"
    if "!RVB_C!"=="0" set "RVB_ALL=0"
)
:: Restore the parent's SCAN_ID since :ScanItem on each sub
set "SCAN_ID=%RVB_SAVED_ID%"
if "%RVB_ALL%"=="1" (
    set "count.vpuadd=1"
) else (
    set "count.vpuadd=0"
)
exit /b

:ScanOnePattern
:: %1 = display-name search pattern
set "SCAN_PAT=%~1"
if "%SCAN_PAT%"=="" exit /b
set "SCAN_LASTKEY="
for /f "usebackq delims=" %%L in (`reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "%SCAN_PAT%" 2^>nul ^| findstr /B /C:"HKEY" /C:"    DisplayName"`) do call :ScanLineRouter "%%L"
set "SCAN_LASTKEY="
for /f "usebackq delims=" %%L in (`reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "%SCAN_PAT%" 2^>nul ^| findstr /B /C:"HKEY" /C:"    DisplayName"`) do call :ScanLineRouter "%%L"
exit /b

:ScanLineRouter
set "SLR_RAW=%~1"
if "%SLR_RAW:~0,5%"=="HKEY_" (
    set "SCAN_LASTKEY=!SLR_RAW!"
    exit /b
)
:: reg query indents value lines with exactly 4 spaces
if /I not "%SLR_RAW:~0,15%"=="    DisplayName" (
    exit /b
)
set "SLR_TRIM=%SLR_RAW:~4%"
for /f "tokens=1,2*" %%A in ("%SLR_TRIM%") do (
    call :ScanOneLine "%%A" "%%C"
)
exit /b

:ScanOneLine
:: %1 = the token we expect to be "DisplayName"
:: %2 = the actual display-name value
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
if not exist "%SET_DIR%\Live-Versions-1.txt" exit /b
if not defined SCAN_LASTKEY exit /b
set "SCAN_THIS_VER="
for /f "tokens=2,*" %%A in ('reg query "!SCAN_LASTKEY!" /v DisplayVersion 2^>nul ^| findstr /C:"DisplayVersion"') do set "SCAN_THIS_VER=%%B"
if not defined SCAN_THIS_VER exit /b
call set "SCAN_BEST_VER=%%inst_ver.%SCAN_ID%%%"
if not defined SCAN_BEST_VER (
    set "inst_ver.%SCAN_ID%=!SCAN_THIS_VER!"
    exit /b
)
call :VersionGreater "!SCAN_THIS_VER!" "!SCAN_BEST_VER!"
if "%VG_RESULT%"=="1" set "inst_ver.%SCAN_ID%=!SCAN_THIS_VER!"
exit /b

:VersionGreater
:: %1 = version A, %2 = version B
:: Sets VG_RESULT=1 if A > B (A is greater), 0 otherwise
set "VG_RESULT=0"
set "VG_A=%~1"
set "VG_B=%~2"
if not defined VG_A exit /b
if not defined VG_B (set "VG_RESULT=1" & exit /b)
:: Tokenize each version on dots into up to 6 segments each
for /f "tokens=1-6 delims=." %%i in ("%VG_A%") do (
    set "VGA1=%%i" & set "VGA2=%%j" & set "VGA3=%%k" & set "VGA4=%%l" & set "VGA5=%%m" & set "VGA6=%%n"
)
for /f "tokens=1-6 delims=." %%i in ("%VG_B%") do (
    set "VGB1=%%i" & set "VGB2=%%j" & set "VGB3=%%k" & set "VGB4=%%l" & set "VGB5=%%m" & set "VGB6=%%n"
)
:: Compare each pair in sequence
call :CompareSeg "!VGA1!" "!VGB1!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
call :CompareSeg "!VGA2!" "!VGB2!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
call :CompareSeg "!VGA3!" "!VGB3!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
call :CompareSeg "!VGA4!" "!VGB4!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
call :CompareSeg "!VGA5!" "!VGB5!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
call :CompareSeg "!VGA6!" "!VGB6!"
if not "%CS_RESULT%"=="0" (set "VG_RESULT=%CS_GREATER%" & exit /b)
exit /b

:CompareSeg
:: %1 = segment A, %2 = segment B
:: Strips non-leading-digit characters so "5a" or "(build)" don't blow up set /a
set "CSA=%~1"
set "CSB=%~2"
call :LeadingDigits CSA
call :LeadingDigits CSB
if not defined CSA set "CSA=0"
if not defined CSB set "CSB=0"
if "%CSA%"=="" set "CSA=0"
if "%CSB%"=="" set "CSB=0"
set /a CS_DIFF=CSA - CSB 2>nul
if %CS_DIFF% EQU 0 (set "CS_RESULT=0" & set "CS_GREATER=0" & exit /b)
set "CS_RESULT=1"
if %CS_DIFF% GTR 0 (set "CS_GREATER=1") else (set "CS_GREATER=0")
exit /b

:LeadingDigits
:: %1 = name of var holding a string
:: Trims to leading digit prefix
call set "LD_S=%%%~1%%"
if not defined LD_S exit /b
set "LD_OUT="
:LD_Loop
if not defined LD_S goto :LD_Done
set "LD_C=%LD_S:~0,1%"
set "LD_REST=%LD_S:~1%"
echo %LD_C%| findstr /R "^[0-9]$" >nul
if errorlevel 1 goto :LD_Done
set "LD_OUT=%LD_OUT%%LD_C%"
set "LD_S=%LD_REST%"
goto :LD_Loop
:LD_Done
set "%~1=%LD_OUT%"
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
:: Name cell (with optional row number), padded to 36
if "%DI_NUMS%"=="1" (set "DI_LABEL=%DI_ROW%) %DI_NAME%") else (set "DI_LABEL=%DI_NAME%")
call :PadRight "%DI_LABEL%" 36 DI_LABEL_PAD
:: Size cell, padded to 14
set "DI_SIZE_CELL=(%DI_SIZE%)"
call :PadRight "%DI_SIZE_CELL%" 14 DI_SIZE_PAD
:: Optional version cells (only when Live Versions toggle is on)
set "DI_LATEST_CELL="
set "DI_CURRENT_CELL="
if exist "%SET_DIR%\Live-Versions-1.txt" call :BuildVersionCells "%DI_ID%"
set "_ROW=%/AE%[0m%/AE%[38;2;%COLOR_RGB%m    !DI_LABEL_PAD!%/AE%[38;2;0;185;255m!DI_SIZE_PAD!"
if defined DI_LATEST_CELL set "_ROW=!_ROW!%/AE%[38;2;255;112;0m!DI_LATEST_CELL!"
if defined DI_CURRENT_CELL set "_ROW=!_ROW!%/AE%[38;2;244;255;0m!DI_CURRENT_CELL!"
set "_ROW=!_ROW!%/AE%[0m"
<nul set /p "=!_ROW!"
echo/
exit /b

:BuildVersionCells
:: %1 = item id
set "BVC_ID=%~1"
call set "BVC_INST=%%inst_ver.%BVC_ID%%%"
call set "BVC_LATEST=%%latest_ver.%BVC_ID%%%"
if defined BVC_LATEST (set "BVC_LATEST_RAW=%BVC_LATEST%") else (set "BVC_LATEST_RAW=")
call :PadRight "%BVC_LATEST_RAW%" 22 DI_LATEST_CELL
if defined BVC_INST set "DI_CURRENT_CELL=%BVC_INST%"
exit /b

:DisplayItemTableHeader
:: Prints the column header row + a divider
:: When the Live Versions toggle is ON, includes Latest + Current columns
:: when OFF, just Name + Size.
if exist "%SET_DIR%\Live-Versions-1.txt" goto :DITH_Full
%Print%{231;72;86}    Name                                Size \n
%Print%{231;72;86}    --------------------------------    ------------ \n
exit /b
:DITH_Full
%Print%{231;72;86}    Name                                Size          Latest Version        Current Version \n
%Print%{231;72;86}    --------------------------------    ------------  --------------------  --------------- \n
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

:GroupTotalSize
:: Sums the byte sizes of every item whose .group matches ACTIVE_GROUP and writes the result to GROUP_TOTAL_SIZE as a readable string
set /a GTS_HI=0
set /a GTS_LO=0
for %%I in (%ITEMS%) do call :GroupTotalSizeAdd %%I
if %GTS_HI% LEQ 0 (
    call :BytesToHuman %GTS_LO% GROUP_TOTAL_SIZE
    exit /b
)
set "GTS_LO_PAD=000000000%GTS_LO%"
set "GTS_LO_PAD=%GTS_LO_PAD:~-9%"
set "GTS_FULL=%GTS_HI%%GTS_LO_PAD%"
:GTS_TrimZero
if "%GTS_FULL:~0,1%"=="0" if not "%GTS_FULL%"=="0" (set "GTS_FULL=%GTS_FULL:~1%" & goto :GTS_TrimZero)
call :BytesToHuman %GTS_FULL% GROUP_TOTAL_SIZE
exit /b

:GroupTotalSizeAdd
set "GTSA_ID=%~1"
call set "GTSA_GROUP=%%%GTSA_ID%.group%%"
if /I not "%GTSA_GROUP%"=="%ACTIVE_GROUP%" exit /b
call set "GTSA_BYTES=%%live_bytes.%GTSA_ID%%%"
if not defined GTSA_BYTES (
    call set "GTSA_HUMAN=%%%GTSA_ID%.size%%"
    if not defined GTSA_HUMAN exit /b
    call :HumanToBytes "!GTSA_HUMAN!" GTSA_BYTES
    if not defined GTSA_BYTES exit /b
)
:: Add GTSA_BYTES to (GTS_HI * 1_000_000_000 + GTS_LO)
call :StrLen "%GTSA_BYTES%" GTSA_LEN
if %GTSA_LEN% LEQ 9 (
    set /a GTS_LO+=GTSA_BYTES
    if %GTS_LO% GEQ 1000000000 (
        set /a GTS_HI+=1
        set /a GTS_LO-=1000000000
    )
    exit /b
)
:: 10+ digits: split
set "GTSA_HI=%GTSA_BYTES:~0,-9%"
set "GTSA_LO_STR=%GTSA_BYTES:~-9%"
:: Strip leading zeros
:GTSA_TrimZero
if "%GTSA_LO_STR:~0,1%"=="0" if not "%GTSA_LO_STR%"=="0" (set "GTSA_LO_STR=%GTSA_LO_STR:~1%" & goto :GTSA_TrimZero)
set /a GTS_HI+=GTSA_HI
set /a GTS_LO+=GTSA_LO_STR
if %GTS_LO% GEQ 1000000000 (
    set /a GTS_HI+=1
    set /a GTS_LO-=1000000000
)
exit /b

:HumanToBytes
:: %1 = human readable size string like "1.37 GB"
:: %2 = output var name. Sets var to integer byte count
set "HTB_RAW=%~1"
if not defined HTB_RAW (set "%~2=" & exit /b)
for /f "tokens=1,2" %%A in ("%HTB_RAW%") do (
    set "HTB_NUM=%%A"
    set "HTB_UNIT=%%B"
)
if not defined HTB_NUM (set "%~2=" & exit /b)
if not defined HTB_UNIT (set "%~2=" & exit /b)
set "HTB_INT=%HTB_NUM%"
set "HTB_SHIFT=0"
if not "%HTB_NUM%"=="%HTB_NUM:.=%" (
    for /f "tokens=1,2 delims=." %%A in ("%HTB_NUM%") do (
        set "HTB_WHOLE=%%A"
        set "HTB_FRAC=%%B"
    )
    :: Compute shift from fraction length
    call :StrLen "%HTB_FRAC%" HTB_SHIFT
    set "HTB_INT=%HTB_WHOLE%%HTB_FRAC%"
)
:: Determine factor
set "HTB_FACTOR=1"
if /I "%HTB_UNIT%"=="KB" set "HTB_FACTOR=1024"
if /I "%HTB_UNIT%"=="MB" set "HTB_FACTOR=1048576"
if /I "%HTB_UNIT%"=="GB" set "HTB_FACTOR=1073741824"
if /I "%HTB_UNIT%"=="B"  set "HTB_FACTOR=1"
:: Compute bytes = HTB_INT * HTB_FACTOR / 10^HTB_SHIFT.
if /I "%HTB_UNIT%"=="GB" goto :HTB_GB
:: KB / MB / B: stay in 32-bit
set /a HTB_RESULT=HTB_INT * HTB_FACTOR
:: Apply decimal shift
if %HTB_SHIFT% GTR 0 (
    set "HTB_DIVISOR=1"
    for /l %%S in (1,1,%HTB_SHIFT%) do set /a HTB_DIVISOR*=10
    set /a HTB_RESULT/=HTB_DIVISOR
)
set "%~2=%HTB_RESULT%"
exit /b

:HTB_GB
:: For "1.37 GB": 137 * 107 * 1e7 / 100 = 137 * 107 * 100000 = 1465900000. Close to the 1.47e9 from above.
:: For "8.19 GB": 819 * 107 * 1e7 / 100 = 819 * 107 * 100000 = 8763300000. OVERFLOWS 32-bit.
:: Compute n = HTB_INT * 107, then append zeros to make the result match (10^7 / 10^HTB_SHIFT)
set /a HTB_TIMES_107=HTB_INT * 107
:: Number of trailing zeros to append
set /a HTB_ZEROS=7 - HTB_SHIFT
if %HTB_ZEROS% LSS 0 set "HTB_ZEROS=0"
set "HTB_RESULT=%HTB_TIMES_107%"
for /l %%Z in (1,1,%HTB_ZEROS%) do set "HTB_RESULT=%HTB_RESULT%0"
set "%~2=%HTB_RESULT%"
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
:: Single inline-ANSI render — same approach as :DisplayItem but no row number.
set "DPO_ID=%~1"
call set "DPO_CNT=%%count.%DPO_ID%%%"
if not defined DPO_CNT set "DPO_CNT=0"
call :ColorForCount %DPO_CNT%
call set "DPO_NAME=%%%DPO_ID%.name%%"
call :ResolveSizeFor "%DPO_ID%" DPO_SIZE
call :PadRight "%DPO_NAME%" 36 DPO_NAME_PAD
set "DPO_SIZE_CELL=(%DPO_SIZE%)"
call :PadRight "%DPO_SIZE_CELL%" 14 DPO_SIZE_PAD
:: Reuse the BuildVersionCells helper; it writes DI_LATEST_CELL / DI_CURRENT_CELL.
set "DI_LATEST_CELL="
set "DI_CURRENT_CELL="
if exist "%SET_DIR%\Live-Versions-1.txt" call :BuildVersionCells "%DPO_ID%"
set "_ROW=%/AE%[0m%/AE%[38;2;%COLOR_RGB%m    !DPO_NAME_PAD!%/AE%[38;2;0;185;255m!DPO_SIZE_PAD!"
if defined DI_LATEST_CELL set "_ROW=!_ROW!%/AE%[38;2;255;112;0m!DI_LATEST_CELL!"
if defined DI_CURRENT_CELL set "_ROW=!_ROW!%/AE%[38;2;244;255;0m!DI_CURRENT_CELL!"
set "_ROW=!_ROW!%/AE%[0m"
<nul set /p "=!_ROW!"
echo/
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
