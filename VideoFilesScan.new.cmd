@echo off
chcp 65001
setlocal EnableExtensions DisableDelayedExpansion
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    echo Processing "%%a"
    if /i not "%%~xa" == ".mkv" (
        mkvmerge -o "%%~pna.mkv" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
        if errorlevel 1 (
            echo Warnings/errors generated during remuxing, original file not deleted
            mkvmerge -i --ui-language en "%%a">>errors.txt
            del "%%~pna.mkv"
        ) else (
            echo Deleting old file
            del "%%~a"
        )
    ) else (
        call :mkvmergeinfoloop "%%a"
    )
)
exit /b

:mkvmergeinfoloop
for /f "delims=" %%l in ('mkvmerge -i %~1 --ui-language en) do (
    for /f "tokens=1,4 delims=:( " %%t in (%%l) do (
        if "%%t" == "subtitles"
            echo "%%a" has subtitles
            mkvmerge -o "%%~dpna.nosubs%%~xa" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%a"
            if errorlevel 1 (
                echo Warnings/errors generated during remuxing, original file not deleted
                mkvmerge -i --ui-language en "%%a">>errors.txt
                del "%%~dpna.nosubs%%~xa"
            ) else (
				echo Deleting old file
                del /f "%%a"
				echo Renaming new file
				ren "%%~dpna.nosubs%%~xa" "%%~nxa"
            )
            goto :eof
    )
)