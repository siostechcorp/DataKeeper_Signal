[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=<repopath>\DataKeeper_Signal.exe
FriendlyName=DataKeeper_Signal
AppLaunched=PowerShell -Command ".\Expand-DataKeeperSignal;.\Install-DataKeeperSignal"
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="DataKeeper_Signal.zip"
FILE1="Expand-DataKeeperSignal.ps1"
[SourceFiles]
SourceFiles0=<repopath>\
[SourceFiles0]
%FILE0%=
%FILE1%=