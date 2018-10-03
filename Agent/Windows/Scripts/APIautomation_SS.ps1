$SMTPServer = "smtp.honeywell.com"
$From = "ValueNetFunctionalAutomation@Honeywell.com"
$To="harish.kumar2@Honeywell.com","vikas.wanchoo@honeywell.com","Niladri.Datta@harman.com","vinay.h@honeywell.com"
$SMTPPort = "25"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
try{
    $status = 0
    "generate report"
    $nunitCommandLine = "C:\Program Files (x86)\NUnit.org\nunit-console\nunit3-console.exe"

	                    
    $fullpath = join-path -path $scriptPath -childpath \Titan\bin\Debug\Titan.AN360.dll
    $params= $fullpath,"--where", '"cat == PI3Demo"'
     $params
    (& $nunitCommandLine $params)
   #,"--where", '"cat == Accounts or  cat == Countries or cat == Delete or cat == Get or cat == KeyFobs or cat == Panels or cat ==KeyPads or cat ==SupervisionTypes or cat ==States or cat ==Post or cat ==Put or cat ==Sensors or cat ==Users  "'

}
catch 
{
    
    $status = -1
    $message= Write-Error ("Failed to Execute Tests." + $_)
}

if($status -eq -1){

    "Sending error mail..."
    $Subject = "Error in Executing NunitTests"
    $Body = "Hi Team `n `n There is an unexpected error while running Nunit Tests.`n Please check and rerun again `n `n Thanks `n Team QA"
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort  
}
else{
 
    "Sending success mail..."
    $Subject = "Automation Test Results for REST API"
    $folderName = $("Titan_$(Get-Date -UFormat "%d-%m-%Y")")
	
	$scriptPath
	#return
	
    $TestResultsFolder = join-path -path $scriptPath -childpath \Titan\TestResults\$folderName
    $files = get-childitem -filter "*.html" -path $TestResultsFolder | sort LastWriteTime -Descending |select name
    $Attachment = $(".\Titan\TestResults\$folderName\$($files[0].Name)")
    $Body = "Hi Team `n `n Please find attached is the detailed html report. `n `n Thanks `n DevOps Team "
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachments $Attachment 
}