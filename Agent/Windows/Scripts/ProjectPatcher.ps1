param (
	[Parameter(Mandatory=$true)]
	[string]$action,
		[Parameter(Mandatory=$true)]
	[string]$branch,
		[Parameter(Mandatory=$true)]
	[string]$buildCounter,
		[Parameter(Mandatory=$true)]
	[string]$rev,
	[string]$path="."
)

Function patchProject
{
	param(
		[string]$csprojPath,
		[string]$semVer,
		[string]$ver
		)
		
		Write-Host $("Starting process of generating new version number for the $csprojPath - $semVer - $ver ")
		#$version =  "1.1." + $buildCounter
		#$version =  (Get-Date).Year.ToString() + "." + (Get-Date).Month.toString()  + "." + (Get-Date).Day.ToString() + "." + $buildCounter
		
		$filePath = $csprojPath
		$filePath
		$xml=New-Object XML
		$xml.Load($filePath)
		$versionNode = $xml.Project.PropertyGroup.Version
		
		#$versionNode
		if ($versionNode -eq $null) {
			$versionNode = $xml.CreateElement("Version")
			$xml.Project.PropertyGroup.AppendChild($versionNode)
			#Write-Host "Version XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.Version = [string]($ver)

		$assemblyVersionNode = $xml.Project.PropertyGroup.AssemblyVersion
		if ($assemblyVersionNode -eq $null) {
			$assemblyVersionNode = $xml.CreateElement("AssemblyVersion")
			$xml.Project.PropertyGroup.AppendChild($assemblyVersionNode)
			#Write-Host "AssemblyVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.AssemblyVersion = [string]($ver)


		$fileVersionnNode = $xml.Project.PropertyGroup.FileVersion
		if ($fileVersionnNode -eq $null) {
			$fileVersionnNode = $xml.CreateElement("FileVersion")
			$xml.Project.PropertyGroup.AppendChild($fileVersionnNode)
			#Write-Host "FileVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.FileVersion = [string]($ver)


		$packageReleaseNotesNode = $xml.Project.PropertyGroup.PackageReleaseNotes
		if ($packageReleaseNotesNode -eq $null) {
			$packageReleaseNotesNode = $xml.CreateElement("PackageReleaseNotes")
			$xml.Project.PropertyGroup.AppendChild($packageReleaseNotesNode)
			#Write-Host "FileVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.PackageReleaseNotes = $semVer
	
		$xml.Save($filePath)

		#Write-Host "Updated csproj $csprojPath and set to version $semVer - $ver"


}

$scriptFolder=$myInvocation.MyCommand.Path | Split-Path -parent
. "$scriptFolder\VersioningFns.ps1"
$scriptFolder
$branch
$projVer = (Get-Version)
$projSemVer = (Get-Semver -branch $branch -rev $rev -buildCounter $buildCounter -nugetCompatible)
$projVer
$projSemVer

pushd $path


if ($action -eq "patch")
{
	$projectList = gci -Recurse *.csproj 
	#Write-Host "Start Patch"
	foreach ($project in $projectList){
			  patchProject -csprojPath $project.FullName -semVer $projSemVer -ver $projVer
			  #patchProject -csprojPath $project.FullName

	}
	#Write-Host "Patch Complete"
}

popd

if($error -ne $null)
{
	write-host $error;
}

$host.SetShouldExit($error.count);
exit 0
 