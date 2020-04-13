@echo off
setlocal EnableDelayedExpansion EnableDelayedExpansion

:: --------------------------------------------------------------------------
:: SERVER STARTER
::                  v1.1
::
:: change source directory and put this file
:: into your server-data folder (with your server.cfg)
:: NOTE: If you use the multi versions folder keep the folder name
::       of the single version with only the version number. In case of there isn't a
::       folder with number the script will select the first founded folder with the starter
:: best practice: don't let the artifact and the server in the same place
::       create different folder for each other
::
:: @author: Meyler#6686 (discord)
:: --------------------------------------------------------------------------


:: paste here the artifact position or, if you prefer, the folder with all artifacts
:: !IMPORTANT the folder must not end with '\' character
set source=C:\change\this\folder\with\your\artifact\folder
:: when this script was created the artifacts use FXServer but I let it dynamic just in case
set starter=FXServer.exe
:: change this only if your server has a different file where is all configurations
set config=server.cfg
:: by default the script search the configuration file in the same folder where it is
set configFolder=%~dp0
:: todo: config the download of the artifacts
set autoUpgrade=0
:: the server select the best artifact in the folder (only if the folder is not the artifact)
set autoSelect=1
:: for debug in case you can't start the server properly
set pauseBeforeStart=0



:: --------------------
:: now the script starts
:: Don't change this! if you are not a developer, you don't know what you can mess up.
:: --------------------

:: Define some useful colorcode vars with c_ prefix to avoid coding problems
:: color codes taken from https://gist.github.com/mlocati/fdabcaeb8071d5c75a2d51712db24011
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"
set "c_white=%ESCchar%[97m"
set "c_gray=%ESCchar%[37m"
set "c_black=%ESCchar%[30m"
set "c_bold=%ESCchar%[1m"
set "c_red=%ESCchar%[91m"
set "c_green=%ESCchar%[92m"
set "c_cyan=%ESCchar%[96m"
set "c_yellow=%ESCchar%[93m"
set "c_blue=%ESCchar%[94m"
set "c_magenta=%ESCchar%[95m"

call :heading

:: Marketing time >.<
timeout 1 > NUL


:: by default the search the configuration file where the script is located
set server=%configFolder%%config%

:: version to start (in case of multiple versions)
call :checkConfig
call :getVersion versionSelected
call :run %versionSelected%

echo.&pause&goto:eof

:: get the artifact version to start
:getVersion
call :checkSource version
set "%~1=%version%"
::set "%~1=%ciao%"
exit /B 0

:: check if the configuration file exists
:checkConfig
echo.
echo %c_white%Looking for server configuration file
echo %c_cyan%[FILE] %c_gray% %server%
if exist %server% (
    echo  - %c_green%Server configuration file founded%c_gray%
) else (
    echo %c_red%[ERROR] Server configuration file does not exist%c_gray%
    echo.
    call :configurations
    pause
    goto :end
)
exit /B 0


:: check if the source folder contains the artifact other way check versions in folder
:checkSource
echo.
echo %c_white%Checking artifact folder
echo %c_cyan%[DIR] %c_gray% %source%
if exist %source%\ (
    echo  - %c_green%Artifact folder exists%c_gray%
) else (
    echo %c_red%[ERROR^^!] Artifact folder doesn't exists%c_gray%
    echo.
    call :configurations
    pause
    goto :end
)
echo.
echo %c_white%Looking for server artifact
echo %c_cyan%[DIR] %c_gray% %source%\

if exist %source%\%starter% (
    echo  - %c_green%This is the server artifact%c_gray%
    set "%~1=%source%\%starter%"
) else (
    echo %c_cyan%File [FILE]%starter% not found in this folder.%c_gray%
    echo %c_cyan%Searching in subfolders%c_gray%
    echo.
    :: check versions inside the folder
    call :checkVersionInSource versionInSource
    set "%~1=!versionInSource!"
)
exit /B 0

:: check if the source folder contains some versions of the artifact
:checkVersionInSource
echo %c_white%Looking for a version in the source directory%gray%
echo %c_cyan%[DIR] %c_gray% %source%\
echo.
:: vector is used to store valid versions to let user select one
set vector=
:: stores the sub-folder that contains the starter file even if is not a version number
set backup=
set n=0
set /a num=0
set /a max=0
for /D  %%G in ("%source%\*") DO (
    echo %c_white%[SEARCHING] %source%\%%~nxG\ %c_gray%
    :: checking if folder name is a number >nul 2>nul to not print error case
    set /a num=%%~nxG >nul 2>nul
    if !num! == %%~nxG (
        if exist %source%\%%~nxG\%starter% (
            set /a vector[!n!]=%%~nxG
            set /a "n+=1"
            echo %c_green%     - Version "%%~nxG" is compatible%c_gray%
            if !max! LSS !num! (
                set /a max = !num!
            )
        ) else (
            echo %c_yellow%     - Missing %c_cyan%[FILE] %c_yellow%%starter%%c_gray%
            echo %c_yellow%     - Incompatible version "%%~nxG"%c_gray%
        )
    ) else (
        echo %c_yellow%     - No version name [may will be ignored]%c_gray%
        if exist %source%\%%~nxG\%starter% (
            echo %c_green%     - Folder has %c_cyan%[FILE] %c_green%%starter%%c_gray%
            if [!backup!] == [] (
                set backup=%%~nxG
                echo %c_green%     - Setted up as directory if no version folder will be found%c_gray%
            ) else (
                echo %c_yellow%     - Directory ignored%c_gray%
            )
        ) else (
            echo %c_yellow%     - Missing %c_cyan%[FILE] %c_yellow%%starter%%c_gray%
        )
    )
)
echo.
if !max! == 0 (
    echo %c_yellow%No versioned folder founded%c_gray%
    if [!backup!] == [] (
        echo %c_red%NO VERSION FOUNDED AND NO BACKUP VERSION!%c_gray%
        call :configurations
        pause
        goto:eof
    ) else (
        echo %c_yellow%Backup version is "!backup!"%c_gray%
    )
) else (
    set backup=!max!
    echo Max version founded %c_green%!max!%c_gray%
)

:: if we founded at least 2 versions check autoSelect to let choose user the version
if %n% GTR 1 (
    if %autoSelect% == 0 (
        echo.
        call :selectInput selection
        if [!selection!] == [] (
            echo %c_yellow%No version selected from input%c_gray%
            echo.
            call :configurations
            pause
            exit /B 0
        ) else (
            set "%~1=%source%\!selection!\%starter%"
        )
    ) else (
        set "%~1=%source%\!backup!\%starter%"
    )
) else (
    set "%~1=%source%\!backup!\%starter%"
)
exit /B 0

:: let input in a function to reiterate in case of failure
:selectInput
echo.
echo %c_white%Choose one version from this list:%c_gray%
echo.
set /a pv=0
call :printProgressiveVersion
echo.
set versionInput=
set /P versionInput="Enter version [or let empty]:%c_yellow%"
echo %c_gray%

if "!versionInput!"=="" (
    :: empty selection = auto select
    echo Automatic selection
    set "%~1=!max!"
    exit /B 0
) else (
    set /a checknum=!versionInput! >nul 2>nul
    if !checknum! == !versionInput! (
        set "x=0"
        :: checkVersion return empty if isn't a valid version
        call :checkVersion !versionInput! versionOutput
        if [!versionOutput!] == [] (
            echo %c_red%Invalid^^!%c_gray% Please enter one of the version number in list
            echo.
            echo.
            call :selectInput input
            set "%~1=!input!"
        ) else (
            set "%~1=!versionOutput!"
        )
    ) else (
        echo %c_red%Invalid^^!%c_gray% Please enter one of the version number in list
        echo.
        echo.
        call :selectInput input
        set "%~1=!input!"
    )
)
exit /B 0


:: just print the list of versions
:printProgressiveVersion
if defined vector[%pv%] (
    call echo   - Version %c_cyan%%%vector[%pv%]%%%c_gray%
    set /a "pv+=1"
    goto :printProgressiveVersion
)
exit /B 0


:: control version in the current 'x' element of array `vector`
:checkVersion
if defined vector[%x%] (
    set /a selected = %~1 >nul 2>nul
    call set /a item=%%vector[%x%]%%
    if !selected! == !item! (
        echo Version %c_green%[OK]%c_gray%
        set "%~2=!selected!"
        exit /B 0
    )
    :: reiterate to next element
    set /a "x+=1"
    goto :checkVersion
) else (
    :: end of array means not a valid version
    echo Version %c_yellow%%~1%c_gray% does not exist
    echo.
)

exit /B 0


:: start the server after all checks
:run
echo.
echo.
echo.
echo %c_white%Artifact%c_gray% running:
echo    %c_yellow%%~1%c_gray%
echo.
echo %c_white%Server data%c_gray% folder
echo    %c_yellow%%configFolder%%c_gray%
echo.
echo %c_white%Config%c_gray% file
echo    %c_yellow%%configFolder%%config%%c_gray%
echo.
echo.

echo Now the following commands will be executed:
echo    %c_white%cd /d %configFolder%%c_gray%
echo    %c_white%%~1 +exec %config%%c_gray%
echo.
echo.

:: little pause just in case user wants to cancel operation
timeout 1 > NUL

if %pauseBeforeStart% == 1 (
    pause
)
echo %c_green%---------------------------------------------------------------------%c_gray%
echo.

:: change folder to config folder [cache could be stored here so pay attention if you change the script]
:: /d avoids different drive issues
:: %~1 is the current artifact starter file
cd /d %configFolder%
%~1 +exec %config%

exit /B 0


:: this is a little bit of marketing, you can change it, just let some reference of me please
:heading
cls
echo %c_cyan%##########################################################################################
echo #                                                                                        #
echo #       %c_red%XXXXXX    XXXXXXX  XXXXXXX   XX     XXX  XXXXXXX  XXXXXXX%c_cyan%                        #
echo #     %c_red%XXX     X  XX       XX     XX  XX    XX   XX       XX     XX%c_cyan%                       #
echo #      %c_red%XXXXXX    XXXXX    XXXXXX     XX   XX    XXXXX    XXXXXX%c_cyan%                          #
echo #    %c_red%x     XXX  XX       XX    XX    XX  XX    XX       XX    XX%c_cyan%                         #
echo #     %c_red%XXXXXX    XXXXXXX  XX      XX  XXXX      XXXXXXX  XX      XX%c_cyan%                       #
echo #                                                                                        #
echo #                       %c_red%XXXXXX    XXXXXXXXXX   XXXX       XXXXXXX   XXXXXXXXXX%c_cyan%           #
echo #                     %c_red%XXX     X      XX       XXXXX      XX     XX     XX%c_cyan%                #
echo #                      %c_red%XXXXXX        XX      XX   XX     XXXXXX        XX%c_cyan%                #
echo #                    %c_red%x     XXX      XX      XXXXXXXX    XX    XX      XX%c_cyan%                 #
echo #                     %c_red%XXXXXX        XX     XX      XX   XX      XX    XX%c_cyan%                 #
echo #                                                                                        #
echo #%c_cyan%----------------------------------------------------------------------------------------%c_cyan%#
echo #                                                                 %c_white%v1.1 by %c_red%Meyler%c_white%#6686%c_cyan%    #
echo ##########################################################################################%c_gray%
echo.
echo.
exit /B 0


:: print current configurations to make easy to solve problems
:configurations
echo.
echo %c_white%CURRENT CONFIGURATIONS
echo.
echo   %c_cyan%source           %c_white%= %c_yellow%%source%
echo   %c_cyan%starter          %c_white%= %c_yellow%%starter%
echo   %c_cyan%config           %c_white%= %c_yellow%%config%
echo   %c_cyan%configFolder     %c_white%= %c_yellow%%configFolder%
echo   %c_cyan%autoUpgrade      %c_white%= %c_yellow%%autoUpgrade%
echo   %c_cyan%autoSelect       %c_white%= %c_yellow%%autoSelect%
echo   %c_cyan%pauseBeforeStart %c_white%= %c_yellow%%pauseBeforeStart%%c_gray%
echo.
echo.
exit /B 0

