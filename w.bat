@echo off
setlocal enabledelayedexpansion


@REM 替换版本更新信息

set file=version.json
set file_tmp=version.json.tmp

set version=%1
set out_file=quiet/quiet-windows-v%1.zip
set isWindows=false

for /f "delims=" %%i in (%file%) do (
    set str=%%i
    echo !str! | findstr /C:"windows" >nul && (
                set isWindows=true
    )

    echo !isWindows! | findstr /C:"true" >nul && (
@REM                 判断是否是version
            echo !str! | findstr /C:"version" >nul && (
                echo     "version": "%version%", >>%file_tmp%
            ) || (
            @REM             判断是否是file
             echo !str! | findstr /C:"file" >nul && (
                        set isWindows=false
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



@REM 替换打包前的版本信息
chcp 65001


@REM 开始构建
flutter build windows




