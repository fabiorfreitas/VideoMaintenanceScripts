@echo off
chcp 65001
for /f "delims=" %%a in (ExtraTracksList.txt) do (
    mkvmerge.exe -o "%%~dpna.oneaudio%%~xa" -a 1 -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
    if errorlevel 1 (
        echo ###
        echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
        mkvmerge.exe -i --ui-language en "%%~a" >> Errors.txt
        del "%%~dpna.oneaudio%%~xa"
    ) else (
    	echo Deleting old file
        del /f "%%~a"
    	echo Renaming new file
    	ren "%%~dpna.oneaudio%%~xa" "%%~nxa"
    )
)
cmd /k