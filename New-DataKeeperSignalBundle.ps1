$PSScriptRoot
cd $PSScriptRoot

# move Windows_Signal repo contents so python scripts can find SignaliQ module
$path = ".\Signal_iQ\python\test\Windows_Signal"
if(-Not (Test-Path -Path $path)) { 
    mkdir $path
}
cd $path

&'python' .\setup.py py2exe

Expand-Archive .\dist\library.zip -DestinationPath .\dist\library -Force

$path =  ".\dist\library\SignaliQ\certs"
if(-Not (Test-Path -Path $path)) { 
    mkdir $path 
}

copy ..\..\SignaliQ\certs\* $path
Remove-Item .\dist\library.zip

Rename-Item -Path ".\dist\library" -NewName "library.zip"