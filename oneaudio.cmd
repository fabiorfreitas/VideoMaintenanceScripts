@echo off
chcp 65001
for %%a in (*.mkv) do (
    mkvmerge.exe -o "%%~dpna.1audio%%~xa" -a 1 -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
    if errorlevel 1 (
        echo ###
        echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
        mkvmerge.exe -i --ui-language en "%%~a">>errors.txt
        del "%%~dpna.1audio%%~xa"
    ) else (
    	echo Deleting old file
        del /f "%%~a"
    	echo Renaming new file
    	ren "%%~dpna.1audio%%~xa" "%%~nxa"
    )
)
cmd /k