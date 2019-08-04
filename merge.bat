rmdir /s /q waterlua
rmdir /s /q wc3libs
rmdir /s /q procTools
rmdir /s /q postproc

rmdir /s /q .git

merge.sh

rmdir /s /q .git
del /q .git*
del /s /q *.git*

copy /y config.conf postproc\config.conf

pause