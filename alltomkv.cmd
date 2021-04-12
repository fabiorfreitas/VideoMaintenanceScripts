@echo off
for /r %%a in (*.mp4 *.avi *.mov) do (
    mkvmerge -o "%%~pna.mkv" -S -M "%%~a"
	del "%%~a"
)
cmd /k