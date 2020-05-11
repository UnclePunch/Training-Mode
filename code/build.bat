SET "MEX_REPO="
SET "OUTPUT_FOLDER="

cd "%MEX_REPO%\patch\code"
"../../MexFF/MexTK.exe" -ff -i "source/events.c" -s tmFunction -dat "%OUTPUT_FOLDER%\TmDt.dat" -o "../output/tmFunction.dat" -t "../../MexFF/tmFunction.txt" -q -ow -w -c