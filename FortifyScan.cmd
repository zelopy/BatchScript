@echo off
rem 2018.03.23 - ��â��/����
rem TDE �����κ��� ���޹��� mbs������ ã�� Fortify SCA ���� ����.
rem TODO : AP2 ���� ȯ�濡 �°� ���� �����ϱ�
rem mbs���ϸ� ��Ģ : [ProjectKEY��]_[TimeStamp]_[�������� ex> 001].mbs
rem ��������
rem		001 : TDE
rem		002 : 

:: Local PC (���߿�)
call D:\Workspace\TDE-Batch\setEnv.cmd
:: (����)
::call D:\TDE-Batch\setEnv.cmd
:: (�)
::call D:\TDE-Batch\setEnv.cmd

:: Scan �۾� ���� ���� (y, n)
set RUN_SCAN=n
:: Scan ���丮�� �̵��� ���˴�� mbs���� (���+���ϸ�)
set SCAN_TARGET=
:: ���ϸ� (Ȯ���ڸ� ����)
set FILE_NAME_NOT_EXT=
:: ���˴�� BUILD ID
set BUILD_ID=
set REQ_TIMESTAMP=
set SERVER_TYPE=


:: ���ε�� mbs������ ã�� ���� ���丮 �̵�
cd /d %UPLOAD_DIR%

:: ���˿�û mbs���� ���ε� ���丮 ���� ��� ����
if not exist "%UPLOAD_DIR%" (
	mkdir "%UPLOAD_DIR%"
	echo 'upload' directory create
)
:: ��ĵ ���丮 ���� ��� ����
if not exist "%SCAN_DIR%" (
	mkdir "%SCAN_DIR%"
	echo 'scan' directory create
)
:: ���˰���������� ���丮 ���� ��� ����
if not exist "%RESULT_DIR%" (
	mkdir "%RESULT_DIR%"
	echo 'result' directory create
)
:: �α� ���丮 ������ ����
if not exist "%LOG_DIR%" (
	mkdir "%LOG_DIR%"
	echo 'logs' directory create
)
:: �α����� ����
if not exist "%LOG_FILE%" (
	echo %TIME% - �α����ϻ���> %LOG_FILE%
)

:: sourceanalyzer ���μ����� 5�� �̻� �������̶�� ����
set proccnt=0
for /f "skip=3" %%x in ('tasklist /FI "IMAGENAME eq sourceanalyzer.exe"') do set /a proccnt=proccnt+1
echo �������� sourceanalyzer.exe ���� : %proccnt%
if %proccnt% gtr 4 (
	echo sourceanalyzer �ִ� ������.. �۾����
	echo %TIME% - sourceanalyzer �ִ� %proccnt% ������.. �۾���� >> %LOG_FILE%
	goto end
)


:: upload ���丮 �� mbs ���� ��ȸ
for /r %%i in (*.mbs) do (
	if exist %%i (
		echo mbs file exists : %SCAN_DIR%\%%~ni%%~xi
		echo %TIME% - mbs file exists : %SCAN_DIR%\%%~ni%%~xi >> %LOG_FILE%
		set RUN_SCAN=y
		set FILE_NAME_NOT_EXT=%%~ni
		rem upload ���丮 �� mbs ���� �߰� �� scan ���丮�� �̵�
		move %%i %SCAN_DIR%\%%~ni%%~xi
		set SCAN_TARGET=%SCAN_DIR%\%%~ni%%~xi
		
		::set BUILD_ID=%%~ni
		for /f "DELIMS=_ TOKENS=1,2,3" %%a in ("%%~ni") do (
			set BUILD_ID=%%a
			set REQ_TIMESTAMP=%%b
			set SERVER_TYPE=%%c
		)
		:: Scan �ܰ�� �̵�
		goto scanrun
	)
)

:: ���� ��û ����
echo %TIME% - 
echo %TIME% - >> %LOG_FILE%

:: ������ �� 1�� �̻� ���� fpr������ ���˿Ϸ�� �Ǵ��ϰ� ���� ó����
cd /d %RESULT_DIR%
set /a thisMonth=%date:~5,2%
set /a today=%date:~8,2%

set ten1=%thisMonth:~0,1%
set ten2=%today:~0,1%
if %ten1% == 0 set thisMonth=%thisMonth:~1,1%
if %ten2% == 0 set today=%today:~1,1%

echo thisMonth : %thisMonth%
echo today : %today%

SETLOCAL ENABLEDELAYEDEXPANSION

for /r %%i in (*.fpr) do (
	if exist %%i (
		:: ������¥ Ȯ��
		set tmp=%%~ti
		set createdDate=!tmp:~8,2!
		set createdDateTmp=!createdDate:~0,1!
		echo createdDate : !createdDate!

		echo 11111

		echo createdDateTmp : !createdDateTmp!
		if !createdDateTmp! == 0 set createdDate=!tmp:~9,1!
		echo createdDate : !createdDate!

		if %today% neq !createdDate! (
			del %%i
			echo %%~ni%%~xi ����
			echo %TIME% - %%~ni%%~xi ����>> %LOG_FILE%
		)
	)
)
:: ���� ��¥�� 7�� ���Ķ��, �������� pdf���� ���� ���� => �ּ� 7���̻� ����� �ɷ� �� �� ����
if %today% gtr 7 (
	for /r %%j in (*.pdf) do (
		if exist %%j (
			set tmp=%%~tj
			set createdMonth=!tmp:~5,2!
			set createdMonthTmp=!createdMonth:~0,1!
			if !createdMonthTmp! == 0 set createdMonth=!tmp:~6,1!

			echo %thisMonth% : !createdMonth!

			if %thisMonth% neq !createdMonth! (
				del %%j
				echo %%~nj%%~xj ����
				echo %TIME% - %%~nj%%~xj ����>> %LOG_FILE%
			)
		)
	)
)

cd /d ..

goto end

:scanrun

echo SCAN_TARGET : "%SCAN_TARGET%"
echo BUILD_ID : "%BUILD_ID%"

echo %TIME% - [%BUILD_ID%] [0] Scan start : %SCAN_TARGET%>> %LOG_FILE%

:: �ش� build ����
sourceanalyzer -b "%BUILD_ID%" -clean
::sourceanalyzer -clean
echo [%BUILD_ID%] [1] Build ID "%BUILD_ID%" clean
echo %TIME% - [%BUILD_ID%] [1] Build ID "%BUILD_ID%" clean>> %LOG_FILE%

:: mbs���Ϸ� Build
sourceanalyzer -import-build-session "%SCAN_TARGET%"
echo [%BUILD_ID%] [2] build-session import : "%SCAN_TARGET%"
echo %TIME% - [%BUILD_ID%] [2] build-session import : "%SCAN_TARGET%">> %LOG_FILE%

if not exist "%RESULT_DIR%\%SERVER_TYPE%" (
	mkdir "%RESULT_DIR%\%SERVER_TYPE%"
	echo "%RESULT_DIR%\%SERVER_TYPE%" directory create
)

:: Fortify scan ���� & ���˰�� ����
sourceanalyzer -64 -Xmx8092M -b %BUILD_ID% -disable-source-bundling -scan -f %RESULT_DIR%\%SERVER_TYPE%\%FILE_NAME_NOT_EXT%.fpr
echo [%BUILD_ID%] [3] Scan �۾��Ϸ�
echo %TIME% - [%BUILD_ID%] [3] Scan �Ϸ�>> %LOG_FILE%
echo [%BUILD_ID%] [4] %FILE_NAME_NOT_EXT%.fpr create
echo %TIME% - [%BUILD_ID%] [4] %FILE_NAME_NOT_EXT%.fpr create>> %LOG_FILE%

:: scan ���丮�� �ش� mbs ���� ����
del "%SCAN_TARGET%"
echo [%BUILD_ID%] [5] "%SCAN_TARGET%" delete
echo %TIME% - [%BUILD_ID%] [5] "%SCAN_TARGET%" delete>> %LOG_FILE%

:: ���˰�� ���� pdf�� ��ȯ
ReportGenerator -template DeveloperWorkbook.xml -format pdf -f %RESULT_DIR%\%FILE_NAME_NOT_EXT%.pdf -source %RESULT_DIR%\%SERVER_TYPE%\%FILE_NAME_NOT_EXT%.fpr
::echo [%BUILD_ID%] [6] "%RESULT_DIR%\%BUILD_ID%".pdf created
::echo %TIME% - [%BUILD_ID%] [6] "%RESULT_DIR%\%BUILD_ID%".pdf created>> %LOG_FILE%

:: ���˿Ϸ� �� fpr���� ����
::del %RESULT_DIR%\%BUILD_ID%.fpr
::echo [%BUILD_ID%] [7] %BUILD_ID%.fpr deleted
::echo %TIME% - [%BUILD_ID%] [7] %BUILD_ID%.fpr deleted>> %LOG_FILE%

:end