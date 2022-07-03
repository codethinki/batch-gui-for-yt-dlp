@echo off  
setlocal enabledelayedexpansion
cd /d %~dp0
if not exist %cd%\src\ mkdir %cd%\src\
pip show yt-dlp 2>%cd%\src\check.txt>nul
set count=0
for /f "tokens=*" %%i in (%cd%\src\check.txt) do (
   	set error[!count!]=%%i
	set /a count+=1
)
if not "%error[0]%"=="" goto install-dlp
del %cd%\src\check.txt
:main
	cls
	set command=""
	set \t=  
	echo ------------------------------------
	echo This is simple a yt-dlp batch gui :)  
	echo ------------------------------------
	echo ------------------------------------
	echo.
	set option=0
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	if "%text[0]%"=="" goto genTextFile
	if "%text[1]%"=="." goto askForInstall
	if "%text[2]%"=="." goto askForInstall
	if "%text[3]%"=="." goto askForInstall
	echo [1] start
	echo [2] set video output path
	echo [3] set audio output path
	echo [4] set ffmpeg path
	echo [5] update
	echo [6] version
	echo [0] quit
	set/P option=
	if /i "%option%"=="1" goto start
	if /i "%option%"=="2" goto videoPath
	if /i "%option%"=="3" goto audioPath
	if /i "%option%"=="4" goto ffmpegPath
	if /i "%option%"=="5" goto update
	if /i "%option%"=="6" goto version
	if /i "%option%"=="0" EXIT

	echo invalid option try again!
	pause
	cls
	goto main

:install-dlp
	echo installing yt-dlp
	pip install yt-dlp>nul
	echo -----------------
	echo.
	del %cd%\src\check.txt
	echo please restart to continue
	pause 
	EXIT

:genTextFile
	set text[0]=generated
	set text[1]=.
	set text[2]=.
	set text[3]=.
	echo %text[0]%>%cd%\src\path.txt
	echo %text[1]%>>%cd%\src\path.txt
	echo %text[2]%>>%cd%\src\path.txt
	echo %text[3]%>>%cd%\src\path.txt
	goto main

:askForFfmpegInstall
	echo path to ffmpeg is not set:
	echo    [0] install ffmpeg
	echo    [1] install and/or set path to ffmpeg manually
	set /P options=
	if "%options%"=="0" goto installFfmpeg
	if "%options%"=="1" goto ffmpegPath
	echo option invalid try againy
	goto askForFfmpegInstall

:askForInstall
	cls
	echo.
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	if "%text[1]%"=="." goto videoPath
	if "%text[2]%"=="." goto audioPath
	if "%text[3]%"=="." goto askForFfmpegInstall

:videoPath
	echo.
	echo set video output path (leave empty to output in same directory or type 0 to go back)
	set /P videoOutputPath=
	set pathToFfmpeg=.
	set audioOutputPath=.
	if not "%videoOutputPath%"=="0" goto updatePath
	goto main

:audioPath
	echo.
	echo set audio output path (empty to output to same directory, type 0 to go back, type 1 for audio output path)
	set /P audioOutputPath=
	set pathToFfmpeg=.
	set videoOutputPath=.
	if "%audioOutputPath%"=="0" goto main
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	if "%audioOutputPath%"=="1" set audioOutputPath=%text[1]%
	goto updatePath

:ffmpegPath
	echo.
	echo set the Path to ffmpeg or get instructions (NOT NEEDED IF DOWNLOADED FROM CODETHINKI'S GIT-REPO OR FULL INSTALL HAS BEEN COMPLEATED):
	echo   [1] auto install ffmpeg (only windows)
	echo   [2] set path to ffmpeg binarys
	echo   [3] get instructions
	echo   [0] go to main

	set /P options=
	if "%options%"=="1" goto installFfmpeg
	if "%options%"=="2" goto setFfmpegPath
	if "%options%"=="3" goto ffmpegInstructions
	if "%options%"=="0" goto main
	echo option invalid try again
	pause
	goto ffmpegPath

	:setFfmpegPath
		echo.
		echo Set the path to the ffmpeg binarys (set "0" to go back):
		set /P pathToFfmpeg=
		if "%pathToFfmpeg%"=="0" goto ffmpegPath
		set videoOutputPath=.
		set audioOutputPath=.
		goto updatePath
	:ffmpegInstructions
		cls
		echo.
		echo  1:	go to https://github.com/yt-dlp/ffmpeg-builds
		echo.
		echo  2:	click on the image with your operating system (it will download the binarys in a compressed file)
		echo.
		echo  3:	exract the compressed file and copy the "bin" folder
		echo.
		echo  4:	paste the "bin" folder somewhere (recommended: in "src" in the folder of this gui of this gui)
		echo.
		echo  5:	copy the path to the binarys ("\bin" should be at the end) NOT NEEDED IF YOU PLACED THE "BIN" IN THE "SRC" FOLDER
		echo.
		echo  6:	set path in menu NOT NEEDED IF YOU PLACED THE "BIN" IN THE "SRC" FOLDER
		echo.
		pause
		cls
		goto ffmpegPath
	
:installFull
	pip install yt-dlp
	goto installFfmpeg

:createRegKey
	echo Windows Registry Editor Version 5.00 >%cd%\src\preMaxspeed.txt
	echo.>>%cd%\src\preMaxspeed.txt
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\BITS]>>%cd%\src\preMaxspeed.txt
	echo "UseSystemMaximum"=dword:00000001>>%cd%\src\preMaxspeed.txt
	ren %cd%\src\preMaxspeed.txt "maxspeed.reg"
	pause

:installFfmpeg
	if not exist %cd%\src\maxspeed.reg goto createRegKey
	reg query HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\BITS /s /f UseSystemMaximum
	if not %errorlevel%==0 %cd%\src\maxspeed.reg
	bitsadmin /reset
	bitsadmin /create "down"
	bitsadmin /addfile "down" "http://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" %cd%\src\ffmpeg.zip
	bitsadmin /setpriority "down" HIGH
	bitsadmin /resume "down"
	:getState
		set count=0
		bitsadmin /getstate "down" >%cd%\src\state.txt
		bitsadmin /info "down" >>%cd%\src\state.txt
		for /f "tokens=*" %%i in (%cd%\src\state.txt) do (
				set text[!count!]=%%i
			set /a count+=1
		)
		set state=%text[3]%
		cls
		echo.
		echo If the download is very slow, you can exit the download with ctrl + c
		echo.
		echo State: %state%
		set text[7]=%text[7]:~65,20%
		echo Progress: %text[7]% bits
		timeout /t 3 >nul
		if not "%state%"=="TRANSFERRED" goto getState

	bitsadmin /complete "down"
	start /w powershell Expand-Archive -Path %cd%\src\ffmpeg.zip -DestinationPath %cd%\src\ -Force
	move "%cd%\src\ffmpeg-master-latest-win64-gpl\bin" "%cd%\src\"
	del /q %cd%\src\state.txt
	rmdir /q /s %cd%\src\ffmpeg-master-latest-win64-gpl
	del /q %cd%\src\ffmpeg.zip
	set pathToFfmpeg=%cd%\src\bin
	goto updatePath

:update
	pip install pip --upgrade
	pip install yt-dlp --upgrade
	pause
	goto main

:version
	yt-dlp --version
	pause
	goto main
	
:start	
	set option=0
	echo.
	echo url:
	set /P url=

	echo download type options:
	echo    [1] video
	echo    [2] audio
	echo    [0] main menu
	set /P option=

	if /i "%option%"=="1" goto videoDownload
	if /i "%option%"=="2" goto audioDownload
	if /i "%option%"=="0" goto main

	echo invalid option try again!
	pause
	cls
	goto start

:videoDownload
	echo.
	set option=0
	set command=yt-dlp
	echo quality options (closest available):
	echo    [1] 2160p
	echo    [2] 1440p
	echo    [3] 1080p
	echo    [4] 720p
	echo    [5] 480p
	echo    [6] 360p
	echo    [7] 144p
	echo    [0] main menu
	set /P option=

	if /i "%option%"=="1" (
		set command=%command% -S "res:2160
		goto fps)
	if /i "%option%"=="2" (
		set command=%command% -S "res:1440
		goto fps)
	if /i "%option%"=="3" (
		set command=%command% -S "res:1080
		goto fps)
	if /i "%option%"=="4" (
		set command=%command% -S "res:720
		goto fps)
	if /i "%option%"=="5" (
		set command=%command% -S "res:480
		goto fps)
	if /i "%option%"=="6" (
		set command=%command% -S "res:360
		goto fps)
	if /i "%option%"=="7" (
		set command=%command% -S "res:144
		goto fps)
	if /i "%option%"=="0" goto main

	echo invalid option try again!
	pause
	goto videoDownload

:fps
	set option=0
	echo.
	echo frames per second (closest available):
	echo    [1] 60 fps
	echo    [2] 30 fps
	echo    [0] main menu

	set /P option=

	if /i "%option%"=="1" (
		set command3=,fps:60"
		goto startVideoDownload)
	if /i "%option%"=="2" (
		set command3=,fps:30"
		goto startVideoDownload)
	if /i "%option%"=="0" goto main

	echo invalid option try again!
	pause
	goto fps

:audioDownload
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	set audioPath="%text[2]%"
	set pathToFfmpeg="%text[3]%"
	set command=-x --audio-quality 0 -q --progress --audio-format "m4a" --ffmpeg-location %pathToFfmpeg%
	if not "%audioPath%"=="" set command=%command% -P %audioPath%
	set command=%command% %url% 2>nul
	set command=yt-dlp %command% 2>nul
	echo Downloading...
	%command% 2>nul
	cls
	echo.
	echo finished
	pause
	goto main

:startVideoDownload
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	set command=%command%%command3% 2>nul
	set command=%command% -q --progress -P %text[1]% %url% 2>nul
	echo Downloading...
	%command% 2>nul
	cls
	echo.
	echo finished
	pause
	goto main

:updatePath
	set count=0
	for /f "tokens=*" %%i in (%cd%\src\path.txt) do (
    	set text[!count!]=%%i
		set /a count+=1
	)
	if not "%videoOutputPath%"=="." set text[1]=%videoOutputPath%
	if not "%audioOutputPath%"=="." set text[2]=%audioOutputPath%
	if not "%pathToFfmpeg%"=="." set text[3]=%pathToFfmpeg%
	echo generated>%cd%\src\path.txt
	echo %text[1]%>>%cd%\src\path.txt
	echo %text[2]%>>%cd%\src\path.txt
	echo %text[3]%>>%cd%\src\path.txt
	goto main
