::@echo off
chcp 65001
setlocal EnableDelayedExpansion
set linebreak=^


REM linebreak
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
        set "info="
        for /f "delims=" %%b in ('mkvmerge --ui-language en -i "%%a"') do (
            if defined info set "info=!info!!linebreak!"
            set "info=!info!%%b"
        )
        for /f %%c in ('^(for /L %%m in ^(1 1 !info_count!^) do echo !info[%%m]!^) ^| find /c /i "subtitles"') do (
            if [%%c]==[0] (
                echo %%a has no subtitles
                for /f %%d in ('echo !info!^| findstr /R /C:"[0-9s]: [0-9]" /C:"bytes"^| find /c /v ""') do (
			        if [%%d]==[0] (
			            echo "%%a" has no extras
				    ) else (
                        for /l %%e in (1,1,%%d) do (
                            mkvpropedit "%%~fa" --delete-attachment 1 --chapters "" --tags all:
                        )
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
            )

        )
    )
    echo --- 
)
cmd /k