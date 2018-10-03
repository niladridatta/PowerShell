param(
    [string]$slnPath=".\src",
    [string]$projPath = "",
    [string]$branch,
    [string]$buildCounter,
    [string]$rev,
    [string]$nugetFolder,
    [string]$buildMode = "Debug",
    [Switch]$cleanNugetFolder
)
$scriptFolder=$myInvocation.MyCommand.Path | Split-Path -parent
. "$scriptFolder\VersioningFns.ps1"

Bamboo-message scriptfolder, $scriptFolder
Bamboo-message starting, $slnPath, $projPath

$nuget=(ls "C:\Nuget\Nuget.exe")

Function PublishToFolder
{
	if (!$nugetFolder) {$nugetFolder = $env:LocalNugetFeed}
	if (!$nugetFolder) {$nugetFolder = "C:\NugetFeed"}
	if ($cleanNugetFolder -and $(Test-Path $nugetFolder)) {rm -r $nugetFolder}
    if (-Not (Test-Path $nugetFolder)) {md $nugetFolder -Force }

    Bamboo-message "publishing $(ls *.nupkg) to $nugetFolder" 
    mv *.nupkg $nugetFolder -Force
}

Function NugetPack 
{
    param ([string] $path=".")
    write-host "In NugetPack: $path"
    pushd $path
    $packageVer=$(Get-Semver -path $path -branch $branch -buildCounter $buildCounter -rev $rev -nugetCompatible -recurse -reverse)
    Bamboo-message packageVer, $packageVer
    $params="pack", (ls *.csproj), "-Version", $packageVer,"-Exclude", "version.txt","-IncludeReferencedProjects", "-Symbols", "-Properties", "releaseNotes=$packageVer built from $branch @sha:$rev;Configuration=$buildMode"
    Bamboo-message "$nuget $params"
    (& $nuget $params)
    popd
}

if ($projPath -eq "") {$path = "$slnPath"} else {$path = "$projPath"}
gci *.csproj -Path $path  -Recurse |
    Select-Object Directory |
    where {test-path "$($_.Directory.FullName)\*.nuspec"} |
    ForEach-Object {
    	pushd $_.Directory
        NugetPack -path $_.Directory	
#        PublishToFolder
        popd
    	}


if($error -ne $null)
{
    write-host $error;
}
    
 $host.SetShouldExit($error.count);