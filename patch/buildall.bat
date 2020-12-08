@Echo Off

cd patch
for /R %%f in (*build.bat) do (
    echo "`n`nBuilding -> %%f"
    cmd.exe /c "%%f"
)
cd ..