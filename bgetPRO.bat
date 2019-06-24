title STARTING UP BGET-PRO UI . . .
@ECHO OFF & cls & setlocal enableDelayedExpansion & mode 120,55 & call :macros & call :init

:main
TITLE BGET UI USER-INTERFACE ^| PRO ITCMD EXE EDITION

call :updateToggleButtons
IF defined category (
    SET "script[list]=!scriptInfo[%category%][list][%page%]!"
) else (
    FOR /L %%G in (%dispMin%, 1, %dispMax%) DO (
	
		if /i "!searching!" equ "true" (
			FOR /F "tokens=2,7 delims==" %%a in ("!scriptInfo[%%G]!") DO (
                            FOR %%X in ("%%~a" "%%~b") DO (
                                IF /I "!searchThis!" == "%%~X" set "script[list]=!script[list]! %%G"
                            )
                        )
                        IF "!script[list]!" == "" (
                            ECHO %esc%[%sbyp1%;%sbxp1%HNo results...
                        )
			set /a "dispMin=1", "dispMax=20"
		) else (
		
			SET "script[list]=!script[list]! %%G"
		)
    )
)
set "searching=false"
set "searchThis="

FOR %%# in (%script[list]%) DO (
    SET /a "clickable[%%#]=(%%# - dispMin + 1) * 2 + 1"
    SET "disp[line]=!disp[line]!!line[%%#]!%ESC%[2B"
)
echo %esc%[1;1H%topl%%esc%[0m%esc%[3;0H%template%%botl%%esc%[0m%esc%[48;5;7m%esc%[38;5;16m%button[1]%%button[2]%%button[3]%%button[4]%%button[5]%%button[6]%%esc%[0m%toggleDisplay%%esc%[0m%searchBox%%esc%[2;1H³ ID  ³ Name             ³ Catagory      ³ Author               ³ Description              ³%ESC%[4;1H%disp[line]%%esc%[1;1H
SET "disp[line]="&SET "script[list]="

for /f "tokens=1-3" %%W in ('"bin\Mouse.exe"') do set /a "mouseC=%%W,mouseX=%%Y,mouseY=%%X"

%ifUserClicksButton[1]% ( IF defined category ( IF %page% NEQ 0 ( SET /A "page-=1" ) ) else IF %dispMin% NEQ 1 ( SET /A "dispMin-=20", "dispMax-=20" ) )
%ifUserClicksButton[2]% ( IF defined category ( SET /A "page+=1" ) else ( SET /A "dispMin+=20", "dispMax+=20" ) )
%ifUserClicksButton[3]% ( del /f /q "%~dp0\master.txt" & ( call :checkDownloadMethod "https://raw.githubusercontent.com/ITCMD/BgetPro/master/master/master.txt" "%~dp0\master.txt" ) )
%ifUserClicksButton[4]% ( SET "page=1" & SET "category=game" )
%ifUserClicksButton[5]% ( SET "category=" )

%ifUserToggles[0]SET_TOGGLE%
%ifUserToggles[1]SET_TOGGLE%
%ifUserToggles[2]SET_TOGGLE%
%ifUserToggles[3]SET_TOGGLE%
%ifUserToggles[4]SET_TOGGLE%

%ifUserClicksSearchBar% ( set /a "dispMax=script_count" & set "searching=true" & set /p "searchThis=%esc%[%sbyp1%;%sbxp1%HSearch: " )

set /a "scriptButton=mouseY / 2 + dispMin - 1"
IF %mouseX% LEQ 92 ( IF %mouseY% LEQ 43 ( IF %mouseY% EQU !clickable[%scriptButton%]! (
	CALL :GET_INFO & ( IF %mouseC% EQU 1 ( CALL :GET_RECURSE ) else ( CALL :GET_DISP ) )
) ) )
goto :main

:createSearchBar x y c
	set "searchBox=%esc%[%~2;%~1H%esc%[38;5;%~3mÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿%esc%[93D%esc%[B³                                                                                          ³%esc%[93D%esc%[BÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ%esc%[0m"
	set /a "searchBox[Xmin]=%~1","searchBox[Xmax]=%~1 + 92","searchBox[Ymin]=%~2","searchBox[Ymax]=%~2 + 2", "sbxp1=%~1+1", "sbyp1=%~2+1"
	set "ifUserClicksSearchBar=if ^!mouseY^! geq ^!searchBox[Ymin]^! if ^!mouseY^! leq ^!searchBox[Ymax]^! if ^!mouseX^! geq ^!searchBox[Xmin]^! if ^!mouseX^! leq ^!searchBox[Xmax]^!"
goto :eof

:createToggle
	if not defined toggleBoxTemplate set "toggleBoxTemplate=ÚÄÄÄ¿%esc%[B%esc%[5D³   ³%esc%[B%esc%[5DÀÄÄÄÙ%esc%[2A"
	set /a "toggleArray=%~4 - 1", "togX=%~2", "togY=%~3", "oX=togX + 1", "oY=togY + 1", "up1=togY - 1", "ov1=oX", "togCol=%~5"
	( if "%~6" neq "" ( set /a "defaultToggle=%~6" ) else ( set /a "defaultToggle=0" )) & set /a "currentToggle=defaultToggle"
	set "toggleBoxes=%esc%[%up1%;%ov1%H%~1%esc%[%togY%;%togX%H" & set "toggleOverlay=%esc%[%oY%;%oX%H"
	
	for /l %%a in (0,1,%toggleArray%) do (
		set "toggleBoxes=!toggleBoxes!%toggleBoxTemplate%"
		if %currentToggle% equ %%a ( set "toggle[%%a]=%esc%[38;5;%~5mÛÛÛ" ) else set "toggle[%%a]=%esc%[38;5;16mÛÛÛ"
		set "toggleOverlay=!toggleOverlay!!toggle[%%a]!%esc%[0m³³"
		set /a "toggleX[%%a]=(%%a + 1) * 5 + %~2 - 6"
	)
	set /a "toggleX[%~4]=(%~4 + 1) * 5 + %~2 - 6"
	
	for /l %%a in (0,1,%toggleArray%) do (
		set /a "n=%%a + 1"
		for %%n in (!n!) do (
			set "ifUserToggles[%%a]SET_TOGGLE=if ^!mouseY^! geq ^!toggleY[min]^! if ^!mouseY^! leq ^!toggleY[max]^! if ^!mouseX^! geq ^!toggleX[%%a]^! if ^!mouseX^! lss ^!toggleX[%%n]^! set currentToggle=%%a"
		)
	)

	set /a "toggleY[min]=%~3 - 1", "toggleY[max]=%~3 + 1"
	set "toggleOverlay=!toggleOverlay:~0,-1!"
	set "toggleDisplay=^!toggleBoxes^!^!toggleOverlay^!"
goto :eof


:updateToggleButtons
	set "toggleOverlay=%esc%[%oY%;%oX%H"
	for /l %%a in (0,1,%toggleArray%) do (
		if !currentToggle! equ %%a ( set "toggle[%%a]=%esc%[38;5;%togCol%mÛÛÛ" ) else set "toggle[%%a]=%esc%[38;5;16mÛÛÛ"
		set "toggleOverlay=!toggleOverlay!!toggle[%%a]!%esc%[0m³³"
	)
	set "toggleOverlay=%toggleOverlay:~0,-1%"
goto :eof

:createButton
	set /a "buttons+=1", "len=0"
	set /a "button[X][%buttons%]=%~1", "button[Y][%buttons%]=%~2"
	set "s=%~3#" & ( for %%P in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do ( if "!s:~%%P,1!" NEQ "" ( set /a "len+=%%P" & set "s=!s:~%%P!" ))) & set /a "len[%%e]=len" 2>nul
	set /a "e=len&1", "len+=(((~(0-e)>>31)&1)&((~(e-0)>>31)&1))+1", "len+=(((~(1-e)>>31)&1)&((~(e-1)>>31)&1))", "back=len + 2"
	set "buttonWidth=" & (for /l %%a in (1,1,%len%) do set "buttonWidth=!buttonWidth!Ä")
	set "button[%buttons%]=%esc%[!button[Y][%buttons%]!;!button[X][%buttons%]!HÚ%buttonWidth%¿%esc%[%back%D%esc%[B³ %~3 ³%esc%[%back%D%esc%[BÀ%buttonWidth%Ù"
	set /a "button[%buttons%][Xmin]=%~1-1","button[%buttons%][Xmax]=%~1 + len","button[%buttons%][Ymin]=%~2-1","button[%buttons%][Ymax]=%~2 + 1"
	set "ifUserClicksButton[!buttons!]=if ^!mouseY^! geq ^!button[%buttons%][Ymin]^! if ^!mouseY^! leq ^!button[%buttons%][Ymax]^! if ^!mouseX^! geq ^!button[%buttons%][Xmin]^! if ^!mouseX^! leq ^!button[%buttons%][Xmax]^!"
goto :eof

:checkDownloadMethod
	if %currentToggle%==3 (
		set /a rnd=%random% & ( bitsadmin /transfer BgetUI!rnd! /download /priority HIGH "%~1" "%~2" >nul ) & set rnd=
	) else if %currentToggle%==0 (
		cscript //NoLogo //e:Jscript "%~dp0\bin\download.js" "%~1" "%~2"
	) else if %currentToggle%==4 (
		"%~dp0\curl\curl.exe" -s "%~1" -o "%~2"
	) else if %currentToggle%==1 (
		Powershell.exe -command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;(New-Object System.Net.WebClient).DownloadFile('%~1','%~2')"
	) else if %currentToggle%==2 (
		cscript //NoLogo //e:VBScript "%~dp0\bin\download.vbs" "%~1" "%~2"
	)
goto :eof

:GET_INFO
FOR /F "tokens=1-9 delims==" %%a in ("!scriptInfo[%scriptButton%]!") DO (
    SET "scriptInfo[temp][fileName]=%%~e"
    SET "scriptInfo[temp][name]=%%~b"
    SET "scriptInfo[temp][scriptLocation]=%%~c"
    SET "scriptInfo[temp][author]=%%~g"
    SET "scriptInfo[temp][hash]=%%~f"
    SET "scriptInfo[temp][description]=%%~d"
    SET "scriptInfo[temp][Date]=%%~i"
)
GOTO :EOF

:GET_DISP
FOR %%G in (Author Filename Date) DO (
    SET "scriptInfo[disp]=!scriptInfo[disp]!%ESC%[93G%%G : !scriptInfo[temp][%%G]!%ESC%[0K%ESC%[1B"
)
ECHO %ESC%[16d!scriptInfo[disp]!
SET "scriptInfo[disp]="
GOTO :EOF

:get_recurse
	title Downloading %scriptInfo[temp][fileName]% by %scriptInfo[temp][author]%
	echo Downloading %scriptInfo[temp][fileName]% by %scriptInfo[temp][author]% . . .
	if not exist "%script_location%\%scriptInfo[temp][name]%" ( md "%script_location%\%scriptInfo[temp][name]%" ) else ( echo script already downloaded. & pause & goto :eof )
	call :checkDownloadMethod "%scriptInfo[temp][scriptLocation]%" "%script_location%\%scriptInfo[temp][name]%\%scriptInfo[temp][fileName]%"
        FOR %%Q in (hash description author) DO (
            ECHO !scriptInfo[temp][%%Q]!>%script_location%\%scriptInfo[temp][name]%\%%Q.txt"
        )
	if "%scriptInfo[temp][fileName]:~-4%"==".cab" (
		echo Extracting...
		call :cab "%script_location%\%scriptInfo[temp][name]%\%scriptInfo[temp][fileName]%" "%script_location%\%scriptInfo[temp][name]%"
	) else if "!scriptInfo[temp][fileName]:~-4!"==".zip" (
		echo Extracting...
		call :unzip "%script_location%\%scriptInfo[temp][name]%\%scriptInfo[temp][fileName]%" "%script_location%\%scriptInfo[temp][name]%"
	)
	echo Download Complete.
	pause
goto :eof

:unzip
	set zip=%~1
	set unzip_path=%~2
	set zip=!zip:\\=\!
	set /a ziprand=%random%
	set unzip_path=!unzip_path:\\=\!


	echo ZipFile="!zip!">"%~dp0\temp\unzip!ziprand!.vbs"
	echo ExtractTo="!unzip_path!">>"%~dp0\temp\unzip!ziprand!.vbs"
	echo set objShell = CreateObject^("Shell.Application"^)>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo set FilesInZip=objShell.NameSpace(ZipFile).items>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo objShell.NameSpace^(ExtractTo^).CopyHere^(FilesInZip^)>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo Set fso = Nothing>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo Set objShell = Nothing>>"%~dp0\temp\unzip!ziprand!.vbs"
	cscript //NOLOGO "%~dp0\temp\unzip!ziprand!.vbs"
	if exist "%~dp0\temp\unzip!ziprand!.vbs" del /f /q "%~dp0\temp\unzip!ziprand!.vbs"
	
	if not exist "!unzip_path!\package" md "!unzip_path!\package"
	move /Y "!zip!" "!unzip_path!\package"	
	
	set ziprand=
	set zip=
	set unzip_path=
	exit /b

:cab
	set cab=%~1
	set cab_path=%~2
	set cab=!cab:\\=\!
	set cab_path=!cab_path:\\=\!
	
	expand "!cab!" -F:* "!cab_path!" >nul
	if not exist "!cab_path!\package" md "!cab_path!\package"
	move /Y "!cab!" "!cab_path!\package"
	
	set cab=
	set cab_path=
	exit /b

:macros
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

( for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a" ) & <nul set /p "=!esc![?25l"

set "topl=ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
set "line=ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
set "botl=ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

goto :eof

:init
SET /A "game[col]=9","utilities[col]=10","tools[col]=11","library[col]=12","graphics[col]=13","example[col]=5","devtools[col]=7"
	if not exist %~dp0scripts md %~dp0scripts
	set "script_location=%~dp0scripts"
	call :createButton 93 8 "Prev Page"
	call :createButton 106 8 "Next Page"
	call :createButton 93 12 "Update list"
	CALL :CREATEBUTTON 93 16 "Games"
	CALL :CREATEBUTTON 93 20 "All"
	call :createSearchBar 1 44 10
	call :createToggle "JS   PS   VBS  BITS CURL" 93 3 5 12 3
	IF not exist master.txt (
		call :checkDownloadMethod "https://raw.githubusercontent.com/ITCMD/BgetPro/master/master/master.txt" "%~dp0\master.txt"
	)
	for /f "tokens=1-9 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0master.txt"') do (
		set /a "script_count+=1"
		ECHO %ESC%[27;55H%ESC%[38;2;0;!script_count!;!script_count!mLoading !script_count!
		REM ID name scriptLocation description fileName hash author category dateAdded
		SET "scriptInfo[!script_count!]="%%~a"="%%~b"="%%~c"="%%~d"="%%~e"="%%~f"="%%~g"="%%~h"="%%~i""
        IF not defined scriptInfo[%%~h][page] (
			SET "scriptInfo[%%~h][page]=0"
            SET "scriptInfo[Category][%%~h]=-1"
        )
        SET /A "scriptInfo[Category][%%~h]+=1","check=scriptInfo[Category][%%~h] %% 20"
        IF !check! EQU 0  SET /A "scriptInfo[%%~h][page]+=1"
               
        FOR /F %%X in ("!scriptInfo[%%~h][page]!") DO SET "scriptInfo[%%~h][list][%%X]=!scriptInfo[%%~h][list][%%X]! !script_count!"
                
        FOR %%G in ("5=!script_count!=2" "17=%%~b=8" "14=%%~h=27" "21=%%~g=43" "25=%%~d=66") DO (
			FOR /F "tokens=1-4 delims==" %%A in ("%%~G=!script_count!") DO (
				SET "temp[script]=%%B"
				IF defined %%B[col] SET "col[temp]=%ESC%[38;5;!%%B[col]!m"
                SET "line[%%D]=!line[%%D]!%ESC%[%%CG!col[temp]!!temp[script]:~0,%%A!%ESC%[0m"
                SET "col[temp]="
            )
        )
	)
	set /a "dispMin=1", "dispMax=20","page=1"
	for /l %%a in (1,1,%dispMax%) do set "template=!template!ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´%esc%[B%esc%[92D³     ³                  ³               ³                      ³                          ³%esc%[B%esc%[92D"

	echo %esc%[0m & CLS
goto :eof