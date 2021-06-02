@echo off
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    if /i not %%~xa==mkv do (
        mkvmerge -o "%%~pna.mkv" -S -M -T --no-global-tags --no-chapters "%%~a"
	    if errorlevel 1 (
            echo Warnings/errors generated during remuxing, original file not deleted
        ) else (
            del "%%~a"
        )
    ) else (
        for /f "delims=" %%b in ('mkvmerge -i "%%a"') do (
            set "info=%%b"
        )
        for /f %%c in ('echo !info! ^| find /c /i "subtitles"') do (
            if [%%c]==[0] (
                echo "search for extras"
            ) else (
                mkvmerge -o "%%~dpna.nosubs%%~xa" -S -M -T --no-global-tags --no-chapters "%%a"
                if errorlevel 1 (
                    echo Warnings/errors generated during remuxing, original file not deleted
                ) else (
                    del /f "%%a"
				    ren "%%~dpna.nosubs%%~xa" "%%~nxa"
                )
            echo.
            )

        )
    ) 
)
