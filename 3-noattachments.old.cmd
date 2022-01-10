@echo off
chcp 65001
for /r %%g in (*.mkv) do (
    for /f %%b in ('mkvmerge -i "%%g" --ui-language en ^| find /c /i "bytes"') do (
	    if [%%b]==[0] (
            for /f %%c in ('mkvmerge -i "%%g" --ui-language en ^| find /c /i "chapter"') do (
			    if [%%c]==[0] (
			        echo "%%g" has no extras
				) else (
				    echo "%%g"
					mkvpropedit "%%~fg" --tags all: --chapters ""
					)
		    )
		) else (
            echo "%%g"
            mkvpropedit "%%~fg" --delete-attachment mime-type:image/jpeg --chapters "" --tags all:
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/x-truetype-font
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/vnd.ms-opentype
	        )
	)
)
cmd /k