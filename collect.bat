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
bins\RawCopy.exe /FileNamePath:"C:\Documents and Settings\Administrator\NTUSER.DAT"
move bins\NTUSER.dat collected_files\Admin_NTUSER.DAT

bins\RawCopy.exe /FileNamePath:C:\WINDOWS\system32\config\SYSTEM
move bins\SYSTEM collected_files\SYSTEM

echo Listing Root Directory
dir c:\ > collected_files\C_Dir.txt

echo Compressing into collected_files.zip
bins\zip.exe -r collected_files.zip collected_files

pause