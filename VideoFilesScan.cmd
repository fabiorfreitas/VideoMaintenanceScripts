@echo off
chcp 65001
setlocal EnableDelayedExpansion
set LF=^


REM The two empty lines are required here
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    echo ---
    echo processing "%%a"
    if /i not "%%~xa" == ".mkv" (
        mkvmerge -q -o "%%~pna.mkv" -S -M -T -B --no-global-tags --no-chapters "%%~a"
        if errorlevel 1 (
            echo Warnings/errors generated during remuxing, original file not deleted
            mkvmerge -i --ui-language en "%aa">>errors.txt
        ) else (
            del "%%~a"
        )
    ) else (
        set "mkvmergeinfo="
        for /f "delims=" %%b in ('mkvmerge --ui-language en -i "%%a"') do (
            if defined mkvmergeinfo set "mkvmergeinfo=!mkvmergeinfo!!LF!"
            set "mkvmergeinfo=!mkvmergeinfo!%%b"
        )
        echo !mkvmergeinfo!
        for /f "usebackq delims= eol=$" %%c in (`echo !mkvmergeinfo! ^| find /c /i "subtitles"`) do (
            echo --
            echo %%c
            echo --
            if [%%c]==[0] (
                echo %%a has no subtitles
                for /f %%d in ('^(for /L %%n in ^(1 1 !info_count!^) do echo !info[%%n]!^)^| findstr "chapter bytes"') do (
			        if [%%d]==[] (
			            echo "%%a" has no extras
				    ) else (
                        echo "%%a" has extras
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