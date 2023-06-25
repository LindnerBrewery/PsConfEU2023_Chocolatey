cd .\package

# create package template
choco new 7zip

# download 7zip setup file https://www.7-zip.org/a/7z2201-x64.exe
Invoke-WebRequest https://www.7-zip.org/a/7z2201-x64.exe -OutFile ./7zip/tools/7zip.exe