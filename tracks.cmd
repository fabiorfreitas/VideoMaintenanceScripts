for /r %%g in (*.mkv) do mkvmerge -i "%%~fg" >>tracks.txt
cmd /k