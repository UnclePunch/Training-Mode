xcopy /s /y "assets\labData.dat" "output/EvLab.dat"
"../../../MexTK/MexTK.exe" -ff -i "source/lab.c" -s evFunction -dat "output/EvLab.dat" -t "../../../MexTK/evFunction.txt" -q -ow -w -c -l "../../../MexTK/melee.link" -op 1
"../../../MexTK/MexTK.exe" -trim "output/EvLab.dat"

xcopy /s /y "assets\importData.dat" "output/EvLabCSS.dat"
"../../../MexTK/MexTK.exe" -ff -i "source/lab_css.c" -s cssFunction -dat "output/EvLabCSS.dat" -t "../../../MexTK/cssFunction.txt" -q -ow -w -c -l "../../../MexTK/melee.link" -op 1
"../../../MexTK/MexTK.exe" -trim "output/EvLabCSS.dat"
pause