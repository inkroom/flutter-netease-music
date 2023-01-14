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
@REM 替换版本更新信息
set rc_file=windows\runner\Runner.rc
set rc_file_tmp=Runner.rc
set rc_file_bak=Runner.rc.bak

set versionNumber=%1
set versionString=%1

@REM 修改为数字版的版本号 1.0.0 == 1,0,0
set "versionNumber=!versionNumber:.=,!"

for /f "delims=" %%i in (%rc_file%) do (
    set str=%%i
echo !str! | findstr /C:"#define VERSION_AS_NUMBER " >nul && (
            echo #define VERSION_AS_NUMBER %versionNumber% >>%rc_file_tmp%
) || (
    echo !str! | findstr /C:"#define VERSION_AS_" >nul && (
                echo #define VERSION_AS_STRING "%versionString%" >>%rc_file_tmp%
    ) || (

        echo !str! | findstr /C:"AFX_RESOURCE_DLL" >nul && (
@REM          此处的感叹号会被移除掉，所以要特殊处理，好像和变量延迟有关系，也就是第2行的命令
            echo #if ^^!defined^(AFX_RESOURCE_DLL^) ^|^| defined^(AFX_TARG_ENU^) >> %rc_file_tmp%
        ) || (
             echo !str!>>%rc_file_tmp%
        )
    )
)
)

move %rc_file% %rc_file_bak%
move %rc_file_tmp% %rc_file%


@REM 开始构建
flutter build windows
if ("true" != "CI" ) {

}

else {
del %rc_file%  && move %rc_file_bak% %rc_file% && cd build\windows\runner\Release && Rar.exe a -r quiet-windows-v%1.zip *.* && mc cp quiet-windows-v%1.zip bc/temp/quiet/v%1/quiet-windows-v%1.zip && mc cp quiet-windows-v%1.zip bc/temp/quiet/quiet-windows-latest.zip && del windows-v%1.zip && cd ../../../../ && mc cp %file% bc/temp
}



