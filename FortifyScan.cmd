@echo off
rem 2018.03.23 - 김창현/보안
rem TDE 서버로부터 전달받은 mbs파일을 찾아 Fortify SCA 점검 수행.
rem TODO : AP2 서버 환경에 맞게 변수 수정하기
rem TODO : mbs파일명 규칙 협의 필요
rem		- 필요정보 : 구분자, IP, Port, Build ID, 프로젝트명, 버전

:: Local PC (개발용)
call D:\Workspace\TDE-Batch\setEnv.cmd
:: (개발)
::call D:\TDE-Batch\setEnv.cmd
:: (운영)
::call D:\TDE-Batch\setEnv.cmd

:: Scan 작업 실행 여부 (y, n)
set RUN_SCAN=n
:: Scan 디렉토리로 이동된 점검대상 mbs파일 (경로+파일명)
set SCAN_TARGET=
:: 점검대상 BUILD ID
set BUILD_ID=


:: 업로드된 mbs파일을 찾기 위해 디렉토리 이동
cd /d %UPLOAD_DIR%

:: 점검요청 mbs파일 업로드 디렉토리 없을 경우 생성
if not exist "%UPLOAD_DIR%" (
	mkdir "%UPLOAD_DIR%"
	echo 'upload' directory create
)
:: 스캔 디렉토리 없을 경우 생성
if not exist "%SCAN_DIR%" (
	mkdir "%SCAN_DIR%"
	echo 'scan' directory create
)
:: 점검결과파일저장 디렉토리 없을 경우 생성
if not exist "%RESULT_DIR%" (
	mkdir "%RESULT_DIR%"
	echo 'result' directory create
)
:: 로그 디렉토리 없으면 생성
if not exist "%LOG_DIR%" (
	mkdir "%LOG_DIR%"
	echo 'logs' directory create
)
:: 로그파일 생성
if not exist "%LOG_FILE%" (
	echo %TIME% - 로그파일생성> %LOG_FILE%
)

:: sourceanalyzer 프로세스가 5개 이상 동작중이라면 보류
set proccnt=0
for /f "skip=3" %%x in ('tasklist /FI "IMAGENAME eq sourceanalyzer.exe"') do set /a proccnt=proccnt+1
echo Total sourceanalyzer.exe tasks running: %proccnt%
if %proccnt% gtr 4 (
	echo sourceanalyzer 최대 동작중.. 작업대기
	echo %TIME% - sourceanalyzer 최대 %proccnt% 동작중.. 작업대기 >> %LOG_FILE%
	goto end
)


:: upload 디렉토리 내 mbs 파일 조회
for /r %%i in (*.mbs) do (
	if exist %%i (
		echo mbs file exists : %SCAN_DIR%\%%~ni%%~xi
		echo %TIME% - mbs file exists : %SCAN_DIR%\%%~ni%%~xi >> %LOG_FILE%
		set RUN_SCAN=y
		rem upload 디렉토리 내 mbs 파일 발견 시 scan 디렉토리로 이동
		move %%i %SCAN_DIR%\%%~ni%%~xi
		set SCAN_TARGET=%SCAN_DIR%\%%~ni%%~xi
		set BUILD_ID=%%~ni
		:: Scan 단계로 이동
		goto scanrun
	)
)

:: 점검 요청 없음
echo %TIME% - 
echo %TIME% - >> %LOG_FILE%

:: 생성된 지 1일 이상 지난 fpr파일은 점검완료로 판단하고 삭제 처리함
cd /d %RESULT_DIR%
set today=%date:~8,2%

SETLOCAL ENABLEDELAYEDEXPANSION
for /r %%i in (*.fpr) do (
	if exist %%i (
		:: 생성날짜 확인
		set tmp=%%~ti
		set createdDate=!tmp:~8,2!

		set /a before = %today% - !createdDate!
		echo !before!

		:: 날짜 비교해서 1일이상 지났다면 삭제
		if !before! gtr 0 (
			del %%i
			echo %%~ni%%~xi 삭제
			echo %TIME% - %%~ni%%~xi 삭제>> %LOG_FILE%
		)
	)
)
:: 생성된 지 7일일 이상 지난 pdf파일은 삭제 처리함
for /r %%j in (*.pdf) do (
	if exist %%j (
		:: 생성날짜 확인
		set tmp=%%~tj
		set createdDate=!tmp:~8,2!

		set /a before = %today% - !createdDate!
		echo !before!

		:: 날짜 비교해서 7일이상 지났다면 삭제
		if !before! gtr 6 (
			del %%j
			echo %%~nj%%~xj 삭제
			echo %TIME% - %%~nj%%~xj 삭제>> %LOG_FILE%
		)
	)
)

cd /d ..

goto end

:scanrun

echo SCAN_TARGET : "%SCAN_TARGET%"
echo BUILD_ID : "%BUILD_ID%"

echo %TIME% - [%BUILD_ID%] [0] Scan start : %SCAN_TARGET%>> %LOG_FILE%

:: 해당 build 정리
::sourceanalyzer -b "%BUILD_ID%" -clean
sourceanalyzer -clean
echo [%BUILD_ID%] [1] Build ID "%BUILD_ID%" clean
echo %TIME% - [%BUILD_ID%] [1] Build ID "%BUILD_ID%" clean>> %LOG_FILE%

:: mbs파일로 Build
sourceanalyzer -import-build-session "%SCAN_TARGET%"
echo [%BUILD_ID%] [2] build-session import : "%SCAN_TARGET%"
echo %TIME% - [%BUILD_ID%] [2] build-session import : "%SCAN_TARGET%">> %LOG_FILE%

:: Fortify scan 수행 & 점검결과 추출
sourceanalyzer -64 -Xmx8092M -b %BUILD_ID% -disable-source-bundling -scan -f %RESULT_DIR%\%BUILD_ID%.fpr
echo [%BUILD_ID%] [3] Scan 작업완료
echo %TIME% - [%BUILD_ID%] [3] Scan 완료>> %LOG_FILE%
echo [%BUILD_ID%] [4] %BUILD_ID%.fpr create
echo %TIME% - [%BUILD_ID%] [4] %BUILD_ID%.fpr create>> %LOG_FILE%

:: scan 디렉토리의 해당 mbs 파일 삭제
del "%SCAN_TARGET%"
echo [%BUILD_ID%] [5] "%SCAN_TARGET%" delete
echo %TIME% - [%BUILD_ID%] [5] "%SCAN_TARGET%" delete>> %LOG_FILE%

:: 점검결과 파일 pdf로 변환
ReportGenerator -template DeveloperWorkbook.xml -format pdf -f %RESULT_DIR%\%BUILD_ID%.pdf -source %RESULT_DIR%\%BUILD_ID%.fpr
::echo [%BUILD_ID%] [6] "%RESULT_DIR%\%BUILD_ID%".pdf created
::echo %TIME% - [%BUILD_ID%] [6] "%RESULT_DIR%\%BUILD_ID%".pdf created>> %LOG_FILE%

:: 점검완료 된 fpr파일 삭제
::del %RESULT_DIR%\%BUILD_ID%.fpr
::echo [%BUILD_ID%] [7] %BUILD_ID%.fpr deleted
::echo %TIME% - [%BUILD_ID%] [7] %BUILD_ID%.fpr deleted>> %LOG_FILE%

:end