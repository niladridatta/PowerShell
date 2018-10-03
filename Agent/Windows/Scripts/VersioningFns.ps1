Function Get-Semver
{
    param(
        [string] $path = ".",
        [switch] $recurse,
        [string] $versionFile="version.txt",
        [string] $branch,
        [string] $buildCounter,
        [string] $rev,
        [switch] $nugetCompatible,
        [string] $stableBranchRegex="^(prod|production|master)$",
        [switch] $reverse=$False
        )

    $version = Get-Version -versionFile $versionFile -path $path -recurse:$recurse -reverse:$reverse
	$localBuild = ($branch -eq "")

    if ($localBuild)
    {
        $preRel="alpha"
    }
    elseif ($branch -match $stableBranchRegex)
    {
        $preRel = ""
    }
    else
    {
        $branchPart = $branch -replace "^(feature|bugfix|hotfix|release)/?"
        $branchPart = $branch -replace "-","" 
		#$branchPart = $branch -replace "_",""
	  if($branchPart.Length -eq 7)
	    {
 		 $len = [Math]::Min(7, $branchPart.Length)
       	    }
          else
	    {
		$len=[Math]::Min(6,$branchPart.Length)
	    }
       
        $preRel="beta-$($branchPart.Substring(0,$len))"
    }

    $packageVer=$(Build-Semver -version $version -preRel $preRel -buildCounter $buildCounter -rev $rev -nugetCompatible:$nugetCompatible)

    return $packageVer
}

Function Get-Depver
{
    param(
        [string] $path = ".",
        [switch] $recurse=$true,
        [string] $versionFile="version.txt",
        [string] $channelFile="channel.txt",
        [string] $branch,
        [string] $buildCounter,
        [string] $stableBranchRegex="^(prod|production|master|MPC-DPS|Dahua|Eagle|Eagle2.0|Eagle2.5)$",
        [switch] $reverse=$False,
        [Parameter(Mandatory=$false)][string] $debugMode=$False
        )
	$tag = "";
    $dateversion = Get-Date -Format "yyMMddHHmm" # Change 1 - Added Hour
	$version = Get-Version -versionFile $versionFile -path $path -recurse:$recurse -reverse:$reverse
    $cd = Get-CDInfo -versionFile $channelFile -path $path -recurse:$recurse -reverse:$reverse
    $channel = "";
    $mode="";
    Write-Host $channelFile
    Write-Host $versionFile
    Write-Host $path
    if($debugMode -eq $true){
        Write-Host "mode is debug!"
        $mode = "-debug"
        
    }
    if($cd.channel.Contains(";")){
		$channel = $cd.channel.Split(';')[0];
	}
	else{
		$channel = $cd.channel;
    }

    Write-Host "Channel is $Channel"
	if ($branch -notmatch $stableBranchRegex -and ![string]::IsNullOrEmpty($branch))
    {
        
			$branchPart = $branch -replace "^(feature|bugfix|hotfix|release)/?"
			$branchPart = $branch -replace "-",""
			$branchPart = $branch -replace "_",""
			$len = [Math]::Min(7, $branchPart.Length)
			$branchPart = "-$($branchPart.Substring(0,$len))"
			
		if($channel -eq $null -or $channel -eq "" -or $channel -match $stableBranchRegex) { $channel = "feature"}
		if($branch -like "*hotfix*")
		{
			$tag = "-hotfix"
		}
		else
		{
			$tag = "-alpha"
		}
    }
	
	#$depver = "$version-$($channel)$($tag)$($branchPart)-$buildCounter-$dateversion"
    $buildCounter = $buildCounter.PadLeft(6,'0')
    $depver = "$version-$($channel)$($mode)$($tag)$($branchPart)-$buildCounter"
	Write-Host "(Get-Depver:$depver)";
    return $depver
}

Function Get-CDInfo
{
    param(
            [string] $path = ".",
            [switch] $recurse=$true,
            [string] $channelFile="channel.txt",
            [switch] $reverse=$False
            )
    [hashtable]$Return = @{} 
    $channeltext = Get-Version -versionFile $channelFile -path $path -recurse:$recurse -reverse:$reverse
    $Return.project,$Return.channel = $channeltext.split(',',2)
    return $Return
}

Function Bump-Version
{
    param(
        [string]$part = "patch",
        [string]$path= ".",
        [switch]$recurse
        )
    $versionFile = Get-VersionFile -path $path -recurse:$recurse
    if ($versionFile -eq $null) {throw "Cannot find version file"}
    $version=(cat $versionFile)
    $newVersion=Incr-Version -version $version -part $part
    Set-Content $versionFile -Value $newVersion
    Bamboo-Message "Bumped from $version to $newVersion in $versionFile"
    return $newVersion
}

Function Incr-Version()
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $version ="",
        [Parameter(Mandatory=$true)]
        [string] $part
        )
    if ($version -eq "") {
        write-warning "Version not passed"
    }
    $number,$pre,$build=$version -split '[\+\-]'
    $major,$minor,$patch=$number.Split(".")

    switch -wildcard ($part)
    {
        "ma*" {$incrementMajor = $True}
        "mi*" {$incrementMinor = $True}
        "pa*" {$incrementPatch = $True}
        default {}
    }
    if ($incrementPatch) {$patch=([int]$patch) + 1}
    if ($incrementMajor)
    {
        $major=([int]$major) + 1
        $minor=0
        $patch=0
    }
    if ($incrementMinor)
    {
        $minor=([int]$minor) + 1
        $patch=0
    }
    $version=($major,$minor,$patch) -join "."

    return $version
}

Function Get-VersionFile()
{
    param(
        [string] $versionFile="version.txt",
        [Switch] $recurse,
        [string] $path="."
        )
    if (-Not $recurse) {
        if (Test-Path "$path\$versionFile") { $foundPath= "$path\$versionFile" }
    } else {
        $file = (ls $versionFile -recurse) | Sort-object FullName.Length| Select-Object -first 1
        if ($file -ne $null) {$foundPath = $file.FullName }
    }
    return $foundPath
}

Function Get-VersionFileReverse()
{
    param(
        [string] $versionFile="version.txt",
        [Switch] $recurse,
        [string] $path="."
        )
    $parentPath = pwd
    write-host "$versionFile $recurse $path $parentPath"
    if (Test-Path "$path\$versionFile") { return "$path\$versionFile" }
    if ($recurse) {
        $parentPath = pwd
        write-host $parentPath
        do
        {
            $parentPath = Split-Path -parent $parentPath
            write-host $parentPath
            if (Test-Path "$parentPath\$versionFile") { return "$parentPath\$versionFile" }
        }
        while($parentPath -contains "*\src*")
    }
}


Function Get-Version()
{
    param(
        [string] $versionFile="version.txt",
        [Switch] $recurse,
        [string] $default,
        [string] $path=".",
        [Switch] $reverse=$False
    )
    if ($reverse)
    {
        write-host "reverse $versionFile"
        $file = Get-VersionFileReverse -versionFile $versionFile -path $path -recurse:$recurse
    }
    else
    {
        write-host "$versionFile"
        $file = Get-VersionFile -versionFile $versionFile -path $path -recurse:$recurse
    }
    if ($file -eq $null) {
        return $default
    }
    return (cat $file)
}

Function Build-Semver
{
    param(
        [string] $version,
        [string] $preRel,
        [string] $rev,
        [string] $buildCounter,
        [Switch] $nugetCompatible
        )
    if ($preRel -ne "") {$version="$version-$preRel" }
    if ($nugetCompatible -and $preRel -eq "") {return $version}

    if ($rev -ne $null -and $rev.Length -gt 7) {
        $rev=$rev.Substring(0,7)
    }
    # nuget.exe has an artificial 20 char limit on pre-rel version - see
    # https://github.com/NuGet/Home/issues/1359#issuecomment-153477217
    # Also, nuget pack still does not support build metadata section (see same ticket above)
    # 0.0.1-beta-nugetveB23Rabcdef
    # a.b.c-beta-<7chars>B<4chars>R<7chars>
    # with the above, we run into 25 chars (allowing for 9999 builds)
    # The easiest compromise is to shorten the git ver... this is anyway embedded in the nugpkg description
    # and the assembly metadata
    if ($nugetCompatible)
    {
        if ($buildCounter -ne "") {$version="$($version)B$($buildCounter)R$rev" }
        $len = [Math]::Min(26, $version.Length)
        $version = $version.Substring(0,$len)
    } else
    {
        if ($buildCounter -ne "") {$version="$version+B$($buildCounter)R$rev" }
    }

    return $version
}

Function Bamboo-Message
{
    param(
        [string] $message
        )
    write-host "### '$message' ###"
}
 if($error -ne $null)
{
    write-host $error;
}
    
 $host.SetShouldExit($error.count);
