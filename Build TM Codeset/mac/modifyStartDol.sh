output_dir=../../Additional\ ISO\ Files/Start.dol
xdelta_patch_path=../../Build\ TM\ Start.dol/StartDolTMPatch.xdelta

echo Creating Training Mode Start.dol...

echo Mofifying Start.dol located at $1

xdelta3 -d -f -s $1 "${xdelta_patch_path}" "${output_dir}"


echo Done!
echo The file is located at ../../Additional ISO Files/Start.dol