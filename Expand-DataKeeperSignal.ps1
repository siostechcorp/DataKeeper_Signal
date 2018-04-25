# Expand-DataKeeperSignal.ps1
Param(
	[string] $Path = "C:\Program Files (x86)\SIOS"
)

# Find DataKeeper install location
if ( Test-Path $env:ExtMirrBase ){
	$Path = $env:ExtMirrBase+"\..\"
} else {
	mkdir $Path
}

# Location for Signal components
$Path += "\DataKeeper_Signal"

# Extract contents of zip to new path, PowerShell version 3+ compliant
Add-Type -A System.IO.Compression.FileSystem
Try {
	[IO.Compression.ZipFile]::ExtractToDirectory("DataKeeper_Signal.zip", "$Path")
} Catch {
	Write-Host "Overwriting existing files..."
}

# Move to install location in prep for running install script. Only doing this 
# here because of iexpress' AppLaunched character length limit.  
cd -d "$Path"