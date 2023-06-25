$AppName = "Config_Demo_App"
# Get Install directory from service path
$InstallDir = ((Get-CimInstance -ClassName Win32_Service -Filter "name = 'config_demo_app'").pathname -split "config_demo_app")[0]
$fullAppPath = Join-Path $InstallDir $AppName

# Set Java_Home in this session for deinstallation of service
$javapath = Get-ChildItem (Join-Path $fullAppPath 'Java')
$Env:Java_Home = $javapath.FullName 

# uninstall service
& (Join-Path $fullAppPath "config_demo_app\wrapper\bat\uninstallService.bat")

# remove environment variable

# Remove application property file environment variables
[System.Environment]::SetEnvironmentVariable('DEMO_CONFIG_APP', '', 'machine')

# Remove application folder
Remove-Item -Path $fullAppPath -Recurse -Force