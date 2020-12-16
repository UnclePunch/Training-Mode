SET "OUTPUT_FOLDER=output"
SET "FILENAME=EvWdsh.dat"
SET "SOURCEFILE=wavedash"
SET "ASSETS=wdshData"

xcopy /s /y "assets\%ASSETS%.dat" "%OUTPUT_FOLDER%/%FILENAME%"
"../../../MexTK/MexTK.exe" -ff -i "source/%SOURCEFILE%.c" -s evFunction -dat "%OUTPUT_FOLDER%\%FILENAME%" -t "../../../MexTK/evFunction.txt" -q -ow -w -c -l "../../../MexTK/melee.link" -op 1
"../../../MexTK/MexTK.exe" -trim "%OUTPUT_FOLDER%\%FILENAME%"

pause