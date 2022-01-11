@echo off
chcp 65001
setlocal EnableExtensions DisableDelayedExpansion
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    echo ###
    echo Processing "%%a"
    if /i not "%%~xa" == ".mkv" (
        mkvmerge.exe -o "%%~pna.mkv" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
        if errorlevel 1 (
            echo Warnings/errors generated during remuxing, original file not deleted
            mkvmerge.exe -i --ui-language en "%%a" >> Errors.txt
            del "%%~pna.mkv"
        ) else (
            echo Deleting old file
            del "%%~a"
        )
    ) else (
        call :mkvmergeinfoloop "%%a" "%%~fa"
    )
)
cmd /k

:mkvmergeinfoloop
setlocal EnableExtensions EnableDelayedExpansion
for /f "delims=" %%l in ('mkvmerge.exe -i "%~1" --ui-language en') do (
    for /f "tokens=1,4 delims=: " %%t in ("%%l") do (
        if /i "%%u" == "audio" (
            if not defined audiotracks (
                set /a "audiotracks=1"
            ) else (
                set /a "audiotracks+=1"
            )
            if !audiotracks! EQU 2 (
                echo %~2 >> ExtraTracksList.txt
            )
        )
        if /i "%%u" == "subtitles" (
            echo ###
            echo "%~1" has subtitles
            mkvmerge.exe -o "%~dpn1.nosubs%~x1" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%~1"
            if errorlevel 1 (
                echo ###
                echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
                mkvmerge.exe -i --ui-language en "%~1" >> Errors.txt
                del "%~dpn1.nosubs%~x1"
            ) else (
				echo Deleting old file
                del /f "%~1"
				echo Renaming new file
				ren "%~dpn1.nosubs%~x1" "%~nx1"
            )
            goto :eof
        )
        if /i "%%t" == "Attachment" (
            if not defined attachments (
                set /a "attachments=1"
            ) else (
                set /a "attachments+=1"
            )
            if not defined propeditcmd (
                set "propeditcmd= --delete-attachment !attachments!"
            ) else (
                set "propeditcmd=!propeditcmd! --delete-attachment !attachments!"
            )
        )
        if /i "%%t" == "Global" (
            if not defined propeditcmd (
                set "propeditcmd= --tags all:"
            ) else (
                set "propeditcmd=!propeditcmd! --tags all:"
            )
        )
        if /i "%%t" == "Chapters" (
            if not defined propeditcmd (
                set propeditcmd= --chapters ""
            ) else (
                set propeditcmd=!propeditcmd! --chapters ""
            )
        )
    )
)
if defined propeditcmd (
    echo ###
    echo "%~1" has extras
    mkvpropedit.exe "%~f1" !propeditcmd!
)
endlocal
goto :eof