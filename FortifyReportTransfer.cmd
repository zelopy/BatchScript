@echo off

:: Local PC (���߿�)
call D:\Workspace\TDE-Batch\setEnv.cmd
:: (����)
::call D:\TDE-Batch\setEnv.cmd
:: (�)
::call D:\TDE-Batch\setEnv.cmd

set REPORT_FILE=
set TARGET_IP=
set TARGET_PORT=
set FTP_ID=
set FTP_PW=

:: �α����� ����
if not exist "%LOG_FILE_FTP%" (
	echo %TIME% - �α����ϻ���> %LOG_FILE_FTP%
)

SETLOCAL ENABLEDELAYEDEXPANSION

cd /d %RESULT_DIR%

for /r %%i in (*.pdf) do (
	if exist %%i (
		echo FILE : %%~ni%%~xi
		set REPORT_FILE=%%i
		echo REPORT_FILE : !REPORT_FILE%!

		for /F "DELIMS=_ TOKENS=1,2,3" %%a in ("%%~ni") do (
			::echo --- %%a %%b %%c
			goto %%c
		)
	)
)

goto end

:000
	echo to 000
	set TARGET_IP=%TARGET_IP_0%
	set TARGET_PORT=%TARGET_PORT_0%
	set FTP_ID=%FTP_ID_0%
	set FTP_PW=%FTP_PW_0%
	goto upload

:001
	echo to 001
	set TARGET_IP=%TARGET_IP_1%
	set TARGET_PORT=%TARGET_PORT_1%
	set FTP_ID=%FTP_ID_1%
	set FTP_PW=%FTP_PW_1%
	goto upload

:002
	echo to 002
	set TARGET_IP=%TARGET_IP_2%
	set TARGET_PORT=%TARGET_PORT_2%
	set FTP_ID=%FTP_ID_2%
	set FTP_PW=%FTP_PW_2%
	goto upload



:upload

:: TEST
::echo !REPORT_FILE!
::echo %TARGET_IP%
::echo %TARGET_PORT%
::echo %FTP_ID%
::echo %FTP_PW%


rem ���˰������ FTP ����
echo open !TARGET_IP!> %FTP_SCRIPT_FILE%
echo %FTP_ID%>> %FTP_SCRIPT_FILE%
echo %FTP_PW%>> %FTP_SCRIPT_FILE%
echo put !REPORT_FILE!>> %FTP_SCRIPT_FILE%
echo quit>> %FTP_SCRIPT_FILE%
ftp -s:%FTP_SCRIPT_FILE%

echo %TIME% - %%~ni%%~xi ���ۿϷ�>> %LOG_FILE_FTP%

del !REPORT_FILE!
del %FTP_SCRIPT_FILE%

echo %TIME% - !REPORT_FILE! �����Ϸ�>> %LOG_FILE_FTP%


::==================================================
:: ����� ===========================================
::==================================================
::open ftp.yourserver.com
::username 
::password 
::cd public_html 
::cd Ftp 
::binary
::put C:\Users\Desktop\something.txt
::bye
::==================================================
::echo open 192.168.100.101> ftpgetscript.txt
::echo user1>> ftpgetscript.txt
::echo demo>> ftpgetscript.txt
::echo get %1>> ftpgetscript.txt
::echo quit>> ftpgetscript.txt
::ftp -s:ftpgetscript.txt

:end