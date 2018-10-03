param(
    [string]$Bamboo_Dir,
    [string]$buildMode = "-Prop Configuration=Release -IncludeReferencedProjects",
    [string]$pack= "pack",
	[string]$nugetPackage_Dir
	
    )
$nuget=(ls "D:\Tools\nuget\nuget.exe")
#$symbols = gci *.symbols.nuspec -File -Recurse
# Creating Nuget Packages
Write-Host $Bamboo_Dir
get-childitem $Bamboo_Dir -Recurse | where {$_.Extension -eq ".nuspec"} | foreach {$path =$_.FullName.Replace('.nuspec','.csproj') ; Write-Host $path; Invoke-Expression "$nuget $pack $path $buildMode -OutputDirectory $nugetPackage_Dir"  }
# Nuget PackagesCreated