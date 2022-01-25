@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "WindowTitle=%~n0"
setlocal EnableDelayedExpansion
for /F "tokens=1,2" %%G in ("!CMDCMDLINE!") do (
    if /I "%%~nG" == "cmd" if /I "%%~H" == "/c" (
        endlocal
        start %SystemRoot%\System32\cmd.exe /D /K %0
        if not errorlevel 1 exit /B
        setlocal EnableDelayedExpansion
    )
)
title !WindowTitle!
endlocal

for /F delims^=^=^ eol^= %%G in ('set ^| %SystemRoot%\System32\findstr.exe /B /I /L /V "ComSpec= PATH= PATHEXT= SystemRoot= TEMP= TMP="') do set "%%G="

if exist "%~dp0mkvmerge.exe" (set "ToolsPath=%~dp0") else if exist mkvmerge.exe (set "ToolsPath=%CD%") else for %%I in (mkvmerge.exe) do set "ToolsPath=%%~dp$PATH:I"
if not defined ToolsPath echo ERROR: Could not find mkvmerge.exe!& exit /B 2
if "%ToolsPath:~-1%" == "\" set "ToolsPath=%ToolsPath:~0,-1%"
if not exist "%ToolsPath%\mkvpropedit.exe" echo ERROR: Could not find mkvpropedit.exe!& exit /B 2

for /F "tokens=*" %%G in ('%SystemRoot%\System32\chcp.com') do for %%H in (%%G) do set /A "CodePage=%%H" 2>nul
%SystemRoot%\System32\chcp.com 65001 >nul 2>&1

(
    for /f "delims=" %%G in (ExtraTracksList.txt) do (
    echo --^> Processing file "%%G" ...
    mkvmerge.exe -o "%%~dpnG.oneaudio%%~xG" -a 1 -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~fG"
    if %errorlevel% NEQ 0 (
        echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
        mkvmerge.exe -i --ui-language en "%%~fG" >> Errors.txt
        del "%%~dpnG.oneaudio%%~xG" 2>nul
    ) else (
    	echo --^> Deleting old file
        del /f "%%~fG"
    	echo --^> Renaming new file
    	ren "%%~dpnG.oneaudio%%~xG" "%%~nxG"
    )
    echo.
    echo ##########
    echo.
)
if exist ExtraTracksList.txt del ExtraTracksList.txt 2>nul
%SystemRoot%\System32\chcp.com %CodePage% >nul
)
endlocal