@echo off

echo open 192.168.118.128> test_ftp_script.txt
echo test>> test_ftp_script.txt
echo test>> test_ftp_script.txt
echo put %%i>> test_ftp_script.txt
echo quit>> test_ftp_script.txt
ftp -s:test_ftp_script.txt