@echo off

echo Moving to correct working directory
cd /D "%~dp0"


fsutil dirty query %SystemDrive% > NUL 2>&1
if not %errorLevel% equ 0 (
    echo ERROR: This batch script must be run with Administrative privileges
    pause
    exit
)

mkdir collected_files

echo Collecting $MFT and $LogFile
bins\RawCopy.exe /FileNamePath:C:0
bins\RawCopy.exe /FileNamePath:c:\$LogFile
move bins\$MFT collected_files\MFT_C.bin
move bins\$LogFile collected_files\LogFile_C.bin

echo Collecting EVTX files and System Registry
xcopy %SystemRoot%\System32\Config collected_files\ /E /Y /C /Q
xcopy %SystemRoot%\system32\winevt\logs\*.evtx collected_files\ /E /Y /C /Q
bins\RawCopy.exe /FileNamePath:C:\WINDOWS\system32\config\SYSTEM
move bins\SYSTEM collected_files\SYSTEM

echo Collecting User Hives
if exist C:\Users\ (
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Users\"') do mkdir "collected_files\%%G"
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Users\"') do if exist "C:\Users\%%G\NTUSER.DAT" (bins\RawCopy.exe /FileNamePath:"C:\Users\%%G\NTUSER.DAT" /OutputPath:"collected_files\%%G\")
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Users\"') do if exist "C:\Users\%%G\AppData\Local\Microsoft\Windows\UsrClass.dat" (bins\RawCopy.exe /FileNamePath:"C:\Users\%%G\AppData\Local\Microsoft\Windows\UsrClass.dat" /OutputPath:"collected_files\%%G\")
) else (
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Documents and Settings\"') do mkdir "collected_files\%%G"
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Documents and Settings\"') do if exist "C:\Documents and Settings\%%G\NTUSER.DAT" (bins\RawCopy.exe /FileNamePath:"C:\Documents and Settings\%%G\NTUSER.DAT" /OutputPath:"collected_files\%%G\")
    for /f "tokens=*" %%G in ('dir /A:D /B "C:\Documents and Settings\"') do if exist "C:\Documents and Settings\%%G\Local Settings\Application Data\Microsoft\Windows\UsrClass.dat" bins\RawCopy.exe /FileNamePath:"C:\Documents and Settings\%%G\Local Settings\Application Data\Microsoft\Windows\UsrClass.dat" /OutputPath:"collected_files\%%G\"
)

echo Listing Root Directory
dir c:\ > collected_files\C_Dir.txt

set hour=%time:~0,2%
set min=%time:~3,2%
set sec=%time:~6,2%

set ftime=%hour%%min%%sec%

echo Compressing into collected_files.zip
bins\zip.exe -r CadoBatch_%computername%_%ftime%.zip collected_files

pause
