@echo off
for /r %%g in (*.mkv) do (
    for /f %%b in ('mkvmerge -i "%%g" ^| find /c /i "bytes"') do (
	    if [%%b]==[0] (
            echo "%%g" has no attachments
		) else (
            echo "%%g"
            mkvpropedit "%%~fg" --delete-attachment mime-type:image/jpeg
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/x-truetype-font
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/vnd.ms-opentype
	        )
	)
)
cmd /k