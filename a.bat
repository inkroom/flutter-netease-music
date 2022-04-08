@echo off
setlocal enabledelayedexpansion

set file=version.json
set file_tmp=version.json.tmp
set file_bak=windows-version.json
set source1=_version_
set source2=_file_

set version=%1
set out_file=quiet-android-v%1.apk
set isAndroid=false

for /f "delims=" %%i in (%file%) do (
    set str=%%i
    echo !str! | findstr /C:"android" >nul && (
                set isAndroid=true
    )

    echo !isAndroid! | findstr /C:"true" >nul && (
@REM                 判断是否是version
            echo !str! | findstr /C:"version" >nul && (

                echo     "version": "%version%", >>%file_tmp%
            ) || (
            echo !str! | findstr /C:"file" >nul && (
                        set isAndroid=false
                            echo     "file": "%out_file%" >>%file_tmp%
                        ) || (

                echo !str!>>%file_tmp%
                )
            )

    ) || (
             echo !str!>>%file_tmp%
         )
)

move %file_tmp% %file%


flutter build apk --target-platform android-arm && mc cp build\app\outputs\apk\release\app-v%1-release.apk bc/temp/out_file && mc cp build\app\outputs\apk\release\output-metadata.json bc/temp && mc cp %file% bc/temp