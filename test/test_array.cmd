@echo off

setlocal EnableDelayedExpansion
set n=0
for %%a in (A B C D) do (
   set vector[!n!]=%%a
   set /A n+=1
)


for /L %%i in (0,1,3) do (
   echo !vector[%%i]!
)

echo %vector[0]%