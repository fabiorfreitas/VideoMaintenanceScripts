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

del /A /F /Q Errors.txt ExtraTracksList.txt 2>nul

(
set "ToolsPath="
set "CodePage="

for /F "delims=" %%G in ('dir *.mkv /A-D-H /B /S 2^>nul') do (
    echo --^> Processing file "%%G" ...
    setlocal
    set "FullFileName=%%G"
    for /F "tokens=1,4 delims=: " %%H in ('^""%ToolsPath%\mkvmerge.exe" -i "%%G" --ui-language en^"') do (
        if /I "%%I" == "audio" (
            set /A AudioTracks+=1
            setlocal EnableDelayedExpansion
            if !AudioTracks! == 2 echo !FullFileName!>>ExtraTracksList.txt
            endlocal
        ) else if not defined SkipFile if /I "%%I" == "subtitles" (
            echo --^> "%%~nxG" has subtitles
            "%ToolsPath%\mkvmerge.exe" -o "%%~dpnG.nosubs%%~xG" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%G"
            if not errorlevel 1 (
                echo --^> Deleting old file ...
                del /F "%%G"
                echo --^> Renaming new file ...
                ren "%%~dpnG.nosubs%%~xG" "%%~nxG"
            ) else (
                echo Warnings/errors generated during remuxing, original file not deleted, check Errors.txt
                "%ToolsPath%\mkvmerge.exe" -i --ui-language en "%%G">>Errors.txt
                del "%%~dpnG.nosubs%%~xG" 2>nul
            )
            set "SkipFile=1"
        ) else if /I "%%H" == "Attachment"  (
            set /A Attachments+=1
        ) else if /I "%%H" == "Global" (
            set "TagsAll=--tags all:"
        ) else if /I "%%H" == "Chapters" (
            set "Chapters=--chapters """
        )
    )
    if not defined SkipFile (
        set "OnlyFileName=%%~nxG"
        setlocal EnableDelayedExpansion
        if defined Attachments (
            set "PropEditOptions= --delete-attachment 1"
            for /L %%H in (2,1,!Attachments!) do set "PropEditOptions=!PropEditOptions! --delete-attachment %%H"
        )
        if defined TagsAll set "PropEditOptions=!PropEditOptions! !TagsAll!"
        if defined Chapters set "PropEditOptions=!PropEditOptions! !Chapters!"
        if defined PropEditOptions (
            echo --^> "!OnlyFileName!" has extras ...
            "%ToolsPath%\mkvpropedit.exe" "!FullFileName!"!PropEditOptions!
        )
        endlocal
    )
    echo.
    echo ##########
    echo.
    endlocal
)
for /F "delims=" %%G in ('dir *.avi *.mp4 *.mov /A-D-H /B /S 2^>nul') do (
    echo Processing file "%%G" ...
    "%ToolsPath%\mkvmerge.exe" -o "%%~dpnG.mkv" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%G"
    if not errorlevel 1 (
        echo --^> Deleting old file ...
        del /F "%%G"
    ) else (
        echo --^> Warnings/errors generated during remuxing, original file not deleted.
        "%ToolsPath%\mkvmerge.exe" -i --ui-language en "%%G">>Errors.txt
        del "%%~dpnG.mkv" 2>nul
    )
    echo.
    echo ##########
    echo.
)

if exist Errors.txt for %%G in (Errors.txt) do if %%~zG == 0 del Errors.txt 2>nul
%SystemRoot%\System32\chcp.com %CodePage% >nul
)
endlocal