param(
    [string]$nugetPackage_Dir,
    [string]$ArtifactoryRepo_Key,
    [string]$Push= "push"
    )
$nuget=(ls "D:\Tools\nuget\nuget.exe")
get-childitem $nugetPackage_Dir -Recurse | where {$_.Extension -eq ".nupkg"} | foreach {$path =$_.FullName; Invoke-Expression "$nuget $Push $path -Source $ArtifactoryRepo_Key  -Configfile 'D:\Tools\nuget\nuget.config'" } 


