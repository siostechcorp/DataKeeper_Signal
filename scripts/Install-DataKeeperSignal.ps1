# Install-DataKeeperSignal.ps1
Param(
    [String] $Path = "C:\Program Files (x86)\SIOS\DataKeeper_Signal"
)

# Use the ExtMirrBase location (if it exists) as a base location for installing dk signal
if($env:ExtMirrBase -eq $Null) {
	# DK not installed, so test default location to see if files were extracted successfully
    if(-Not (Test-Path -Path $Path)) {
        Write-Error "DataKeeper_Signal files were not found."
		Start-Sleep
        exit 1
    }
} else {
	# DK is installed, install dk signal to it's parent folder
    $path = "$env:ExtMirrBase\..\DataKeeper_Signal"
}

# get properites needed for Signal_iQ config from user
$environmentID =  Read-Host "Please enter the ENVIRONMENT ID for your iQ appliance (format: 123456789)"
$hostname = Read-Host "Please enter the HOSTNAME for your iQ appliance"
$username = Read-Host "Please enter the ADMIN USERNAME for your iQ appliance"
$password = Read-Host "Please enter the ADMIN PASSWORD for your iQ appliance"

# create new Signal_iQ config.ini file from sample
$config = Get-Content -Path "$path\dist\library.zip\SignaliQ\config.sample.ini"
$config = $config | foreach { $_.Replace("no_such_host", $hostname) }
$config = $config | foreach { $_.Replace("change_this_value", $password) }
$config = $config | foreach { $_.Replace("admin", $username) }
$config | Out-File -FilePath "$path\dist\library.zip\SignaliQ\config.ini"

# prompt user for (domain) admin credentials for creating new task
$message = "Enter administrator credentials to create and run a new Task. Domain administrator recommended."
$credential = $Host.UI.PromptForCredential("Administrator Credentials",$message,"$env:userdomain\$env:username",$env:userdomain)
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# new scheduled task properties to run the ps script every 5 minutes after boot
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "'$path\Send-Signal.ps1' -PyModule '$path\dist\report_event.exe' -EnvironmentID $environmentID"

$triggers = [System.Collections.ArrayList]@()

# this trigger repeats for 10 years because of differences between how PSv4 and later versions deal with TimeSpan.MaxValue
$triggers.Add((New-ScheduledTaskTrigger -Once -At ([System.DateTime]::Now) -RepetitionDuration (New-TimeSpan -Days 3650) -RepetitionInterval (New-TimeSpan -Minutes 5))) >$Null
$triggers.Add((New-ScheduledTaskTrigger -AtStartup)) >$Null

# create the new task and start it right now
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "DataKeeper Signal" -Description "Scan for DataKeeper Signal events every 5 minutes; starts on boot." -RunLevel Highest -User $username -Password $password | Start-ScheduledTask
