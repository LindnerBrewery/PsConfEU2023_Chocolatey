$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = (Split-Path -Parent $MyInvocation.MyCommand.Definition)

$AppName = "Config_Demo_App"
$InstallDir = "C:\Temp\"
$port = "81"
$PSConfLocation = 'DontKnow'
$AreWeHavingFun = 'Maybe'

$pp = Get-PackageParameters

if ($pp['InstallDir']) { $InstallDir = $pp['InstallDir'] } # change $installdir to $installdirc to demo debugging?
if ($pp['Port']) { $port = $pp['Port'] }
if ($pp['PSConfLocation']) { $PSConfLocation = $pp['PSConfLocation'] }
if ($pp['AreWeHavingFun']) { $AreWeHavingFun = $pp['AreWeHavingFun'] }

$validParams = @('Debug', 'Port', 'InstallDir', 'PSConfLocation','AreWeHavingFun')
foreach ($key in $pp.keys) {
    if ($validParams -notcontains $key) {
        Throw "$key is not an allowed parameter. Valid params are: `n$($validParams -join "`n") "
    }
}

if ($pp['debug']) {
    $runspace = [System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace
    Write-Host "Debug was passed in as a parameter"
    Write-Host "To enter debugging write: Enter-PSHostProcess -Id $pid"
    Write-Host "Debug-Runspace -Id $($runspace.id)"
    Wait-Debugger
}

# Set application path
$fullAppPath = Join-Path $InstallDir $AppName

# Unzip and set javahome environment variable for this session
$javazip =  Get-ChildItem -Path $toolsDir | Where name -like "amazon-corretto-*-windows-x64-jdk.zip"
Get-ChocolateyUnzip $javazip.Fullname -Destination (Join-Path $fullAppPath 'Java')
$javapath = Get-ChildItem (Join-Path $fullAppPath 'Java')
$Env:Java_Home = $javapath.FullName


# Unzip config demo app
Get-ChocolateyUnzip "$toolsDir\config_demo_app.zip" -Destination $fullAppPath


# Add modules folder to psprofile environment variables
$env:PSModulePath += "; $toolsDir\modules"
Import-Module medavis.confighelper -Force


# configure wrapper.conf
$wrapperConfPath = Join-Path $fullAppPath 'config_demo_app\wrapper\conf\wrapper.conf'
$javaHome = (Join-Path $javapath.FullName 'bin') -replace '\\', '/'
$javaCommand = (Join-Path $javapath.FullName  'bin\java') -replace '\\', '/'
$workingDir = (Join-Path $fullAppPath 'config_demo_app') -replace '\\', '/'

Set-PropertyFileValue -Path $wrapperConfPath -Property 'JAVA_HOME' -Value $javaHome
Set-PropertyFileValue -Path $wrapperConfPath -Property 'wrapper.java.command' -Value $javaCommand
Set-PropertyFileValue -Path $wrapperConfPath -Property 'wrapper.working.dir' -Value $workingDir


# install service
& (Join-Path $fullAppPath "config_demo_app\wrapper\bat\installService.bat")


# configure application
$applicationPropertiesFilePath = Join-Path $fullAppPath '\config_demo_app\application.properties'
Set-PropertyFileValue -Path $applicationPropertiesFilePath -Property 'server.port' -Value "`${PORT:$port}"


# set application properties
# Set environment variables so app can find properties file
$propertyFilePath = Join-Path $fullAppPath '\config_demo_app\app.config'
[System.Environment]::SetEnvironmentVariable('DEMO_CONFIG_APP', $propertyFilePath, 'machine')

# set properties in property file 
Set-PropertyFileValue -Path $propertyFilePath -Property 'PSConfLocation' -Value $PSConfLocation
Set-PropertyFileValue -Path $propertyFilePath -Property 'AreWeHavingFun?' -Value $AreWeHavingFun


# start demo application
Start-Service config_demo_app 







<#
$pp = Get-PackageParameters

if ($pp['InstallDir']) { $InstallDir = $pp['InstallDir'] } # change $installdir to $installdirc to demo debugging?
if ($pp['Port']) { $port = $pp['Port'] }
if ($pp['PSConfLocation']) { $PSConfLocation = $pp['PSConfLocation'] }
if ($pp['AreWeHavingFun']) { $AreWeHavingFun = $pp['AreWeHavingFun'] }

$validParams = @('Debug', 'Port', 'InstallDir', 'PSConfLocation','AreWeHavingFun')
foreach ($key in $pp.keys) {
    if ($validParams -notcontains $key) {
        Throw "$key is not an allowed parameter. Valid params are: `n$($validParams -join "`n") "
    }
}

if ($pp['debug']) {
    $runspace = [System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace
    Write-Host "Debug was passed in as a parameter"
    Write-Host "To enter debugging write: Enter-PSHostProcess -Id $pid"
    Write-Host "Debug-Runspace -Id $($runspace.id)"
    Wait-Debugger
}
#>