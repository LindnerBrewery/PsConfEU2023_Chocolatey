
$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$filePath = Get-Item $toolsDir\*.exe

$packageArgs = @{
    packageName    = '7zip'
    fileType       = 'exe'
    file           = $filePath
    silentArgs     = '/S'
    validExitCodes = @(0)
}
Install-ChocolateyInstallPackage @packageArgs