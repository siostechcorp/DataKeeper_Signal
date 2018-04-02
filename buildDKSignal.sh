#!/bin/sh
git clone git@github.com:siostechcorp/Signal_iQ.git
git clone git@github.com:siostechcorp/Windows_Signal.git
PowerShell -Command ".\New-DataKeeperSignalBundle.ps1"
