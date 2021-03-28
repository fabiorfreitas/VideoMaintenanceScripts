@echo off
for /r %%a in (*.mp4 *.avi) do (
    mkvmerge -o "%%~pna.mkv" -S -M "%%~a"
	del "%%~a"
)
cmd /k