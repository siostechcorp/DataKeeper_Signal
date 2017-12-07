# DataKeeper Signal
DataKeeper Signal is a repository that contains the SIOS iQ integration with DataKeeper Events that can be sent to SIOS iQ product for analysis and correlation.

# Instructions
DataKeeper depends on Windows Signal (https://github.com/siostechcorp/Windows_Signal) implementation which in turn relies on the Signal iQ SDK (https://github.com/siostechcorp/Signal_iQ).

# Requirements
This was designed and tested to be built on Windows Server 2012 R2 or 2016 with PowerShell v5.1 or newer installed.

Obviously the package generated using these steps is designed to be installed on a system running SIOS DataKeeper, but it will still work with appropriate event json files included. See the configuration instructions in the Windows_Signal repo for further details. 

Python 2.7.14 (or newer, x86 version) should be installed, and python.exe should be reachable via the PATH environment variable.
This can be tested by running 'python -V' from a cmd prompt. It should return something similar to "Python 2.7.14"

Certain modules required by Signal_iQ are downloaded and installed via pip during packaging. These are noted in the Signal_iQ\python\requirements.txt file.

Py2exe 0.6.9 (or newer, Win32 version) should be installed.

Git bash 2.15.1 (or newer) for Windows also needs to be installed and reachable via the PATH environment variable.
This can be tested by running 'git --version' from a cmd prompt. It should return something similar to "git version 2.15.1.windows.2".

# Steps to build re-distributable package installer
Download the latest version of this repo. You can use 'git clone --recursive <repo>' from cmd to pull it from GitHub, or you can download the zip package off the webpage. If you are maintaining a repo you can update it to the latest version by running 'git submodule update --init --recursive'.

(Optional)Extract the contents of the zip file to some location.

In PowerShell v4.0 or newer, navigate to the DataKeeper_Signal folder.

Run '.\New-DataKeeperSignalBundle.ps1'


A self-extracting exe file should be generated in the repo folder. This can be placed on any Windows Server 2012 R2 or 2016 VMware VM that is being monitored by SIOS iQ. To install DataKeeper_Signal on that VM simply double click the executable and follow the instructions. It will require the following values from the user:

SIOS iQ admin credentials

Windows (domain) admin credentials