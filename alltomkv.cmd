@echo off
for /r %%a in (*.mp4 *.avi) do (
    mkvmerge -o "%%~pna.mkv" "%%~a"
	del "%%~a"
)
cmd /k