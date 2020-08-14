"../../MexTK/MexTK.exe" -ff -i "source/events.c" -s tmFunction -o "output/TmDt.dat" -t "../../MexTK/tmFunction.txt" -q -ow -w -c -op 1
"../../MexTK/MexTK.exe" -addSymbol "output/TmDt.dat" "assets/evMenu.dat" -ow
"../../MexTK/MexTK.exe" -trim "output/TmDt.dat"
pause