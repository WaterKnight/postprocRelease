cd %~dp0

call makeChecksums.bat

cd %~dp0

lua createUpload.lua

pause