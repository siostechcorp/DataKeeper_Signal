#	Copyright (c) 2018 SIOS Technology Corp.
#	Install-DataKeeperSignal.ps1
#
##############################################################################################

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True, Position=0)]
	[String] $Path = $Null,

	[Parameter(Mandatory=$False, Position=1)]
	[String] $EnvironmentID = $Null,

	[Parameter(Mandatory=$False, Position=2)]
	[String] $Hostname = $Null,

	[Parameter(Mandatory=$False, Position=3)]
	[String] $Username = $Null,

	[Parameter(Mandatory=$False, Position=4)]
	[String] $Password = $Null,

	[Parameter(Mandatory=$False, Position=5)]
	[String] $AdminUsername = $Null,

	[Parameter(Mandatory=$False, Position=6)]
	[String] $AdminPassword = $Null
)

# start logging
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -Path "$env:temp\Install-DataKeeperSignal.log" -append

# Create install directory if it doesn't exist
if($Path -eq $Null) {
	if($env:ExtMirrBase -eq $Null) {
		$Path = "C:\Program Files (x86)\SIOS\DataKeeper_Signal"
	} else {
		$Path = $env:ExtMirrBase + "\\..\\DataKeeper_Signal"
	}
} else {
	if(-Not (Test-Path -Path $Path)) {
		New-Item -Path $Path -ItemType Directory
	}
}

# get properites needed for Signal_iQ config from user if not passed in
if( -Not $EnvironmentID ) {
	$EnvironmentID =  Read-Host "Please enter the ENVIRONMENT ID for your iQ appliance (format: 123456789)"
}
if( -Not $Hostname ) {
	$Hostname = Read-Host "Please enter the Hostname for your iQ appliance"
}
if( -Not $Username ) {
	$Username = Read-Host "Please enter the ADMIN Username for your iQ appliance"
}
if( -Not $Password ) {
	$Password = Read-Host "Please enter the ADMIN Password for your iQ appliance"
}

# create new Signal_iQ config.ini file from sample
$config = Get-Content -Path "$path\dist\library.zip\SignaliQ\config.sample.ini"
$config = $config | foreach { $_.Replace("no_such_host", $Hostname) }
$config = $config | foreach { $_.Replace("change_this_value", $Password) }
$config = $config | foreach { $_.Replace("admin", $Username) }
$config | Out-File -FilePath "$path\dist\library.zip\SignaliQ\config.ini"

# prompt user for (domain) admin credentials for creating new task
if( -Not $AdminUsername -OR -Not $AdminPassword ) {
	$message = "Enter administrator credentials to create and run a new Task. Domain administrator recommended."
	$credential = $Host.UI.PromptForCredential("Administrator Credentials",$message,"$env:userdomain\$env:Username",$env:userdomain)
	$AdminUsername = $credential.Username
	$AdminPassword = $credential.GetNetworkCredential().Password
}

# create a new sceduled task if it does not already exist
if( -Not (Get-ScheduledTask "DataKeeper Signal") ) {
	# new scheduled task properties to run the ps script every 5 minutes after boot
	$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "'$path\Send-Signal.ps1' -PyModule '$path\dist\report_event.exe' -EnvironmentID $EnvironmentID"

	$triggers = [System.Collections.ArrayList]@()

	# this trigger repeats for 10 years because of differences between how PSv4 and later versions deal with TimeSpan.MaxValue
	$triggers.Add((New-ScheduledTaskTrigger -Once:$False -At ([System.DateTime]::Now) -RepetitionDuration (New-TimeSpan -Days 3650) -RepetitionInterval (New-TimeSpan -Minutes 5))) >$Null
	$triggers.Add((New-ScheduledTaskTrigger -AtStartup)) >$Null

	# create the new task and start it right now
	Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "DataKeeper Signal" -Description "Scan for DataKeeper Signal events every 5 minutes; starts on boot." -RunLevel Highest -User $AdminUsername -Password $AdminPassword | Start-ScheduledTask
	if( -Not $? ) {
		Write-Verbose "Failed to create scheduled task with user: '$AdminUsername' and pass: '$AdminPassword'"
		# stop logging
		Stop-Transcript
		exit 1
	}
}

# stop logging
Stop-Transcript
exit 0