@echo off

echo %TIME%

::echo ==========================================

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
::echo hour=%hour%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
::echo min=%min%
set sec=%time:~6,2%
if "%sec:~0,1%" == " " set sec=0%sec:~1,1%

set hhmm=%hour%%min%
echo %hhmm%


set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%

set yyyyMMdd=%year%%month%%day%

echo %yyyyMMdd%

echo %yyyyMMdd%%hhmm%