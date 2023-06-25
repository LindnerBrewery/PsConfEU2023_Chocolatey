
# register chocolatey nuget feed as package source
$registerPackageSourceSplat = @{
    Name = 'Chocolatey'
    Location = "https://community.chocolatey.org/api/v2/"
    ProviderName = 'NuGet'
    Trusted = $true
    Force = $true
}
Register-PackageSource @registerPackageSourceSplat

# create new dir
mkdir $pwd\choco

# save package to folder
$savePackageSplat = @{
    Name = 'chocolatey'
    Source = 'chocolatey'
    Path = "$pwd\choco"
}
Save-Package @savePackageSplat

# unzip package
$chocoNupkg = Get-Item $pwd\choco\chocolatey.*.nupkg 

$expandArchiveSplat = @{
    DestinationPath = "$pwd\choco\chocolatey"
    Force = $true
    Path = $chocoNupkg
}
Expand-Archive @expandArchiveSplat



# Optional core and compatibility extension
find-package chocolatey-core.extension -Source chocolatey | Save-Package -Path $pwd\choco2 # chocolatey-compatibility.extension will also be downloaded as it's a dependency
