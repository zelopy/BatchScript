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

:: Scan 수행할 mbs파일 저장 경로
set SCAN_DIR=%WORKSPACE%\scan

:: 로그 디렉토리
set LOG_DIR=%WORKSPACE%\logs
:: 로그 파일
set LOG_FILE=%LOG_DIR%\%DATE%.log
:: FTP로그 파일
set LOG_FILE_FTP=%LOG_DIR%\%DATE%-FTP.log

::================================================

