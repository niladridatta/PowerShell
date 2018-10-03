$nuget=(ls "C:\Nuget\Nuget.exe")
$symbols = gci *.symbols.nupkg -File -Recurse
foreach ($symbol in $symbols)
{
 if(!($symbol).FullName.contains("src\packages"))
 {
    $params= "push", (ls $symbol), "-Verbosity", "detailed"
    write-host "$nuget $params"
    (& $nuget $params)
 }
}
if($error -ne $null)
{
    write-host $error;
}
    
 $host.SetShouldExit($error.count);
