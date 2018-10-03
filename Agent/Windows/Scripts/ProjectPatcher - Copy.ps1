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
pushd $path
Function patchProject
{
	param(
		[string]$csprojPath, 
		[string]$tag,
		[string]$buildCounter
	)
	Write-Host "Starting process of generating new version number for the csproj"
	
		$version =  (Get-Date).Year.ToString() + "." + (Get-Date).Month.toString()  + "." + (Get-Date).Day.ToString() + "." + $buildCounter
		"printing version:"
		$version
		$filePath = $csprojPath
		$filePath
		$xml=New-Object XML
		$xml.Load($filePath)
		$versionNode = $xml.Project.PropertyGroup.Version
		$versionNode
		if ($versionNode -eq $null) {
			$versionNode = $xml.CreateElement("Version")
			$xml.Project.PropertyGroup.AppendChild($versionNode)
			Write-Host "Version XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.Version = [string]($version)

		$assemblyVersionNode = $xml.Project.PropertyGroup.AssemblyVersion
		if ($assemblyVersionNode -eq $null) {
			$assemblyVersionNode = $xml.CreateElement("AssemblyVersion")
			$xml.Project.PropertyGroup.AppendChild($assemblyVersionNode)
			Write-Host "AssemblyVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.AssemblyVersion = [string]($version)


		$fileVersionnNode = $xml.Project.PropertyGroup.FileVersion
		if ($fileVersionnNode -eq $null) {
			$fileVersionnNode = $xml.CreateElement("FileVersion")
			$xml.Project.PropertyGroup.AppendChild($fileVersionnNode)
			Write-Host "FileVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.FileVersion = [string]($version)


		$packageReleaseNotesNode = $xml.Project.PropertyGroup.PackageReleaseNotes
		if ($packageReleaseNotesNode -eq $null) {
			$packageReleaseNotesNode = $xml.CreateElement("PackageReleaseNotes")
			$xml.Project.PropertyGroup.AppendChild($packageReleaseNotesNode)
			Write-Host "FileVersion XML tag added to the csproj"
		}
		$xml.Project.PropertyGroup.PackageReleaseNotes = $tag
	
		$xml.Save($filePath)

		Write-Host "Updated csproj "$csprojPath" and set to version "$myBuildNumber


}

if ($action -eq "patch")
{
	$projectList = gci -Recurse *.csproj 
	Write-Host "Start Patch"
	foreach ($project in $projectList){
			  patchProject -csprojPath $project.FullName -buildCounter $buildCounter -tag $("$branch+$rev") 

	}
	Write-Host "Patch Complete"
				


}
popd

if($error -ne $null)
{
	write-host $error;
}

$host.SetShouldExit($error.count);
exit 0
 