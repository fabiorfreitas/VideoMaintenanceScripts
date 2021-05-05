@echo off
for /r %%a in (*.mkv) do (
    for /f %%b in ('mkvmerge -i "%%a" ^| find /c /i "subtitles"') do (
        if [%%b]==[0] (
            echo "%%a" has no subtitles
        ) else (
            echo.
            echo "%%a" has subtitles
            mkvmerge -q -o "%%~dpna.nosubs%%~xa" -S -M --no-chapters "%%a"
            if errorlevel 1 (
                echo Warnings/errors generated during remuxing, original file not deleted
            ) else (
				echo Deleting old file
                del /f "%%a"
				echo Renaming new file
				ren "%%~dpna.nosubs%%~xa" "%%~nxa"
            )
            echo.
        )
    )
)
cmd /k