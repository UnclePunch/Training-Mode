xcopy /s /y "assets\ldshData.dat" "output/EvLdsh.dat"
"../../../MexTK/MexTK.exe" -ff -i "source/ledgedash.c" -s evFunction -dat "output/EvLdsh.dat" -t "../../../MexTK/evFunction.txt" -q -ow -w -c -l "../../../MexTK/melee.link" -op 1
"../../../MexTK/MexTK.exe" -trim "output/EvLdsh.dat"

pause