@echo off
for /r %%g in (*.mkv) do (
    echo "%%g"
    mkvpropedit "%%~fg" --delete-attachment mime-type:image/jpeg
    mkvpropedit "%%~fg" --delete-attachment mime-type:application/x-truetype-font
    mkvpropedit "%%~fg" --delete-attachment mime-type:application/vnd.ms-opentype
	)
cmd /k