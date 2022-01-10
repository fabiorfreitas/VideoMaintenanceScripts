@echo off
for /r %%a in (*.mp4 *.avi *.mov) do (
    mkvmerge -o "%%~pna.mkv" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
	del "%%~a"
)
cmd /k 