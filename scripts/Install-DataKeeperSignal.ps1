# Install-DataKeeperSignal.ps1
Param(
    [String] $Path = "C:\Program Files (x86)\SIOS\DataKeeper_Signal"
)

if($env:ExtMirrBase -eq $Null) {
    if(-Not (Test-Path -Path $Path)) {
        Write-Error "DataKeeper_Signal files not found" 
        exit 1
    }
} else {
    $path = "$env:ExtMirrBase\..\DataKeeper_Signal"
}

# get properites needed for Signal_iQ config from user
$hostname = Read-Host "Please enter the hostname for your iQ environment"
$password = Read-Host "Please enter the password for your iQ environment"
$username = Read-Host "Please enter the admin username for your iQ environment"
$environmentID =  Read-Host "Please enter your iQ environment ID (format: 123456789)"

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
$path = "C:\Program Files (x86)\SIOS\DataKeeper_Signal"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "'$path\Send-Signal.ps1' -PyModule '$path\dist\report_event.exe' -EnvironmentID $environmentID"
$triggers = [System.Collections.ArrayList]@()
# trigger repeats for 10 years because of differences between how PSv4 and later versions deal with TimeSpan.MaxValue
$triggers.Add((New-ScheduledTaskTrigger -Once -At ([System.DateTime]::Now) -RepetitionDuration (New-TimeSpan -Days 3650) -RepetitionInterval (New-TimeSpan -Minutes 5))) >$Null
$triggers.Add((New-ScheduledTaskTrigger -AtStartup)) >$Null

# create the new task and start it right now
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "DataKeeper Signal" -Description "Scan for DataKeeper Signal events every 5 minutes; starts on boot." -RunLevel Highest -User $username -Password $password | Start-ScheduledTask
