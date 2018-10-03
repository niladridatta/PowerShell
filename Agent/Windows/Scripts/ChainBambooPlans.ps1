param(
	[string]$PlanID,
    [string]$PlanVariables,
	[bool]$OverrideVariables,
	[bool]$Verbose
)

$PlanID
$PlanVariables
$OverrideVariables
$Verbose
$isBuildSuccess = [Environment]::GetEnvironmentVariable('isBuildSuccess','User');
$("Environment Variable - Begin - isBuildSuccess : $isBuildSuccess")
$headers = @{}
$headers =  @{Authorization="Basic RTM4NDc2NzpQMTk0ODJpbmEjQCE=";Accept="application/json"}
$TaskUrl = "https://bamboo.honeywell.com/rest/api/latest/queue/"+$PlanID+"?executeAllStages=true"

if($OverrideVariables)
{
	$TaskUrl = "$TaskUrl&$PlanVariables"
}
Write-Host $TaskUrl
$rawresult = Invoke-WebRequest -usebasicparsing -Uri $TaskUrl -Method POST -Headers $headers
$result = ConvertFrom-JSON($rawresult);  
Write-Host $result.link.href
$TaskUrl = $result.link.href
$rawresult = Invoke-WebRequest -usebasicparsing -Uri $TaskUrl -Method GET -Headers $headers
$result = ConvertFrom-JSON($rawresult);
$status = $result.state
Write-Host -NoNewline "...fired the plan...status is..." + $state
While($status -eq "Unknown")
{
    $rawresult = Invoke-WebRequest -usebasicparsing -Uri $TaskUrl -Method GET -Headers $headers
    $result = ConvertFrom-JSON($rawresult);
	if($Verbose)
	{
		Write-Host $result
	}
    $status = $result.state
    $buildResultKey = $result.buildResultKey
    $name= $result.plan.name

    Write-Host ".........."
    Start-Sleep -s 30
}
if($status -eq "Failed") 
{
	[Environment]::SetEnvironmentVariable("isBuildSuccess", "$false", "User")
	Write-Host  "Build $status for the plan $name and buildkey $buildResultKey"
} 
else
{ 
	[Environment]::SetEnvironmentVariable("isBuildSuccess", "$true", "User")
	Write-Host "Build $status for the plan $name and buildkey $buildResultKey" 
}
$isBuildSuccess = [Environment]::GetEnvironmentVariable('isBuildSuccess','User');
$("Environment Variable - End - isBuildSuccess : $isBuildSuccess")
$host.SetShouldExit($error.Count);
