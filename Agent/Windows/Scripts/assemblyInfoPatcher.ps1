param (
    [Parameter(Mandatory=$true)]
    [string] $action,
    [string]$branch,
    [string]$buildCounter,
    [string]$rev,
    [string]$path="."
)

$scriptFolder=$myInvocation.MyCommand.Path | Split-Path -parent
. "$scriptFolder\VersioningFns.ps1"

pushd $path
Function PatchFile()
{
    param(
        [string] $file,
        [string]$assemblyversion,
        [string]$assemblyfileversion,
        [string]$assemblyInformationalVersion,
        [string]$branch,
        [string]$rev
        )

    $content = Get-Content $file | foreach-object {
         $_ -replace '^\[assembly: AssemblyVersion\("1.0.0.0"\)\]', "[assembly: AssemblyVersion(`"$assemblyVersion`")]" `
                 -replace '^\[assembly: AssemblyInformationalVersion\("1.0.0.0"\)\]', "[assembly: AssemblyInformationalVersion(`"$assemblyInformationalVersion`")]" `
                -replace '^\[assembly: AssemblyFileVersion\("1.0.0.0"\)\]', "[assembly: AssemblyFileVersion(`"$assemblyFileVersion`")]" `
                -replace '^\[assembly: AssemblyDescription\("([^"]*)"\)]',"[assembly: AssemblyDescription(`"`$1 Ver-$assemblyInformationalVersion built from $branch @sha:$rev`")]" 

    }
    write-host "##bamboo[message text=`'Patched file: $file`' {$assemblyVersion, $assemblyFileVersion, $assemblyInformationalVersion}]"
    Set-Content $file $content -Encoding UTF8
}

if ($action -eq "patch")
{
    gci *.csproj  -Recurse |
        where {(test-path "$($_.Directory)\version.txt") -And (test-path "$($_.Directory)\Properties\AssemblyInfo.cs") } |
        foreach-object {
            $projVer = (Get-Version -path $($_.Directory))
            $projSemVer = (Get-Semver -path $($_.Directory) -branch $branch -rev $rev -buildCounter $buildCounter -nugetCompatible)
            $assemblyversion = $projVer
            $assemblyfileversion = $assemblyversion
            $assemblyInformationalVersion = $projSemVer
            write-host "##bamboo[message text=`'Before Patched file: $file`' {$assemblyVersion, $assemblyFileVersion, $assemblyInformationalVersion}]"
            PatchFile -file "$($_.Directory)\Properties\AssemblyInfo.cs" `
                            -assemblyversion $assemblyversion `
                            -assemblyfileversion $assemblyfileversion `
                            -assemblyInformationalVersion $assemblyInformationalVersion `
                            -branch $branch `
                            -rev $rev

        }

    $slnVer = (Get-Version)
    $slnSemVer = (Get-Semver -branch $branch -rev $rev -buildCounter $buildCounter)
    $assemblyversion = $slnVer
    $assemblyFileVersion = $assemblyVersion
    $assemblyInformationalVersion = $slnSemVer
    gci *.csproj  -Recurse |
        where {(-Not (test-path "$($_.Directory)\version.txt")) -And (test-path "$($_.Directory)\Properties\AssemblyInfo.cs")} |
        foreach-object {
            PatchFile -file "$($_.Directory)\Properties\AssemblyInfo.cs" `
                            -assemblyversion $assemblyversion `
                            -assemblyfileversion $assemblyfileversion `
                            -assemblyInformationalVersion $assemblyInformationalVersion `
                            -branch $branch `
                            -rev $rev

        }
}


if ($action -eq "revert") 
{
    $files=(ls -Name -Recurse -Filter AssemblyInfo.* )
    write-host $files
    foreach ($file in $files) {
        $content = Get-Content $file | foreach-object {
            $_ -replace '^\[assembly: AssemblyVersion[^\]]*\]', "[assembly: AssemblyVersion(`"1.0.0.0`")]" `
                     -replace '^\[assembly: AssemblyInformationalVersion[^\]]*\]', "[assembly: AssemblyInformationalVersion(`"1.0.0.0`")]" `
                    -replace '^\[assembly: AssemblyFileVersion[^\]]*\]', "[assembly: AssemblyFileVersion(`"1.0.0.0`")]" `
                    -replace '^\[assembly: AssemblyDescription\("(.*) Ver-[^"]*"\)]',"[assembly: AssemblyDescription(`"`$1`")]" 
                    }
        write-host "##bamboo[message text=`'Reverted file: $file)`']"
        Set-Content $file $content -Encoding UTF8
    }
}

popd

if($error -ne $null)
{
    write-host $error;
}
    
 $host.SetShouldExit($error.count);