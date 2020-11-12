xcopy /s /y "assets\lclData.dat" "output/EvLCl.dat"
"../../../MexTK/MexTK.exe" -ff -i "source/lcancel.c" -s evFunction -dat "output/EvLCl.dat" -t "../../../MexTK/evFunction.txt" -q -ow -w -c -l "../../../MexTK/melee.link" -op 1
"../../../MexTK/MexTK.exe" -trim "output/EvLCl.dat"

pause