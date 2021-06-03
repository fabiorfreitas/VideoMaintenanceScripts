@echo off
setlocal EnableDelayedExpansion
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    echo ---
    if /i not "%%~xa" == ".mkv" (
        mkvmerge -q -o "%%~pna.mkv" -S -M -T --no-global-tags --no-chapters "%%~a"
	    echo mkvmerge
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
                echo %%a has no subtitles
                for /f %%c in ('echo !info! ^| findstr /R /C:"[0-9s]: [0-9]" /C:"bytes" ^| find /c /v ""') do (
			        if [%%c]==[0] (
			            echo "%%a" has no extras
				    ) else (
                        mkvpropedit "%%~fa" --delete-attachment mime-type:image/jpeg --chapters "" --tags all:
                        mkvpropedit "%%~fa" --delete-attachment mime-type:application/x-truetype-font
                        mkvpropedit "%%~fa" --delete-attachment mime-type:application/vnd.ms-opentype
                    )
		    )

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
    echo --- 
)
cmd /k