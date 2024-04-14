# set-splunkUforwarder
Upgrade universal forwarder - script to run with SCCM
##SYNOPSIS
Runs from SCCM 
Installs splunkforwarder agent from a share  on systems only if soft not installed or version is different from the MSI version on share.
Script checks
forwarder is installed
if yes - compares soft and msi versions and installs if soft different from msi
if no - soft is installed
##EXECUTION
Before use 
Edit: 
- Attributes in function set-splunkforwarder
  DEPLOYMENT_SERVER="<splunkDeployment>:8089"
  RECEIVING_INDEXER="<SplunkIndexer>:9997"
  SPLUNKUSERNAME="<splunkUSER>"
  SPLUNKPASSWORD "<EnterPassword>"
- Varabile $PathfilesMSI = "\\<Server>\SplunkAgent\"
Add the newest  SplunkForwarder msi package to location that is defined in $PathfilesMSI. Do not change the file name
##NOTES
Nadia Ramasawmy February 19 2024, March 13 2024
