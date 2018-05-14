@echo off

::================================================
:: Local PC (개발용 환경설정) ====================
::================================================
:: 기본 디렉토리
set WORKSPACE=D:\Workspace\TDE-Batch

:: TDE로부터 업로드 된 점검대상 mbs파일 저장 경로
set UPLOAD_DIR=%WORKSPACE%\upload

:: 점검결과 pdf 파일 저장 경로
set RESULT_DIR=%WORKSPACE%\result


::================================================
:: (개발서버 환경설정) ===============
::================================================
:: 기본 디렉토리
::set WORKSPACE=D:\TDE-Batch

:: TDE로부터 업로드 된 점검대상 mbs파일 저장 경로
::set UPLOAD_DIR=D:\FTP_HOME\tde\upload

:: 점검결과 pdf 파일 저장 경로
::set RESULT_DIR=D:\FTP_HOME\tde\result


::================================================
:: (운영서버 환경설정) =============
::================================================
:: 기본 디렉토리
::set WORKSPACE=D:\TDE-Batch

:: TDE로부터 업로드 된 점검대상 mbs파일 저장 경로
::set UPLOAD_DIR=D:\FTPhome\tde\upload

:: 점검결과 pdf 파일 저장 경로
::set RESULT_DIR=D:\FTPhome\tde\result


::================================================

:: Scan 수행할 mbs파일 저장 경로
set SCAN_DIR=%WORKSPACE%\scan

:: FTP전송 Script 파일
set FTP_SCRIPT_FILE=%WORKSPACE%\ftp_script.txt

:: 로그 디렉토리
set LOG_DIR=%WORKSPACE%\logs
:: 로그 파일
set LOG_FILE=%LOG_DIR%\%DATE%.log
:: FTP로그 파일
set LOG_FILE_FTP=%LOG_DIR%\%DATE%-FTP.log

::================================================

:: TEST(Local PC)
set TARGET_IP_0=192.168.118.128
set TARGET_PORT_0=21
set FTP_ID_0=test
set FTP_PW_0=test

:: TDE Server
set TARGET_IP_1=
set TARGET_PORT_1=
set FTP_ID_1=
set FTP_PW_1=

:: C&C Server
set TARGET_IP_2=
set TARGET_PORT_2=
set FTP_ID_2=
set FTP_PW_2=