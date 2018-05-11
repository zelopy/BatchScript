@echo off

:: notepad.exe
:: chrome.exe
set PROC_NAME_1=sourceanalyzer
set PROC_NAME_2=chrome
set PROC_EXT=exe


echo =====================================================================
:: sourceanalyzer 프로세스 못찾음
::tasklist /FI "IMAGENAME eq sourceanalyzer.exe" 2>NUL | find /I /N "sourceanalyzer.exe">NUL
::if "%ERRORLEVEL%"=="0" echo Program is running


echo =====================================================================
:: sourceanalyzer 프로세스 못찾음
for /f "tokens=1 delims=" %%# in ('qprocess^|find /i /c /n "%PROC_NAME_2%"') do (
    set number=%%#
)

echo number of %PROC_NAME_2%: %number%

echo =====================================================================
:: sourceanalyzer 프로세스 찾음
set proccnt=0
for /f "skip=3" %%x in ('tasklist /FI "IMAGENAME eq sourceanalyzer.exe"') do set /a proccnt=proccnt+1
echo Total sourceanalyzer.exe tasks running: %proccnt%

echo =====================================================================


