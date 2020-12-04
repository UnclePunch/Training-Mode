@echo off	

echo #####################################
echo ##                                 ##
echo ##                                 ##
echo ## Training Mode Start.dol Creator ##
echo ##                                 ##
echo ##                                 ##
echo #####################################
echo.

echo Creating Training Mode Start.dol...
echo.

cd /d %~dp0

xdelta.exe -d -f -s %1 "patch.xdelta" "..\Additional ISO Files\Start.dol"

echo.
echo Done!
echo The file is located in the "Additional ISO Files" folder!

pause