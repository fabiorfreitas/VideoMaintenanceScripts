@echo off
for /r %%a in (*.mp4 *.avi *.mov) do (
    mkvmerge -o "%%~pna.mkv" -S -M --no-chapters "%%~a"
    mkvmerge -o "%%~pna.mkv" -S -M -T --no-global-tags --no-chapters "%%~a"
	del "%%~a"
)
cmd /k 