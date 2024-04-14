<#
SYNOPSIS
Runs from SCCM 
Installs splunkforwarder agent from a share  on systems only if soft not installed or version is different from the MSI version on share.
Script checks
forwarder is installed
if yes - compares soft and msi versions and installs if soft different from msi
if no - soft is installed
EXECUTION
Before use 
Edit: 
- Attributes in function set-splunkforwarder
  DEPLOYMENT_SERVER="<splunkDeployment>:8089"
  RECEIVING_INDEXER="<SplunkIndexer>:9997"
  SPLUNKUSERNAME="<splunkUSER>"
  SPLUNKPASSWORD "<password>"
- Varabile $PathfilesMSI = "\\<Server>\SplunkAgent\"
Add the newest  SplunkForwarder msi package to location that is defined in $PathfilesMSI. Do not change the file name
NOTES
Nadia Ramasawmy February 19 2024, March 13 2024

#>

# Edit attributes before running as described above in script synopsis
function set-splunkforwarder
{
param (
        [string[]]$MsiFile
    )
#Set directory for log location - useful for debuging installation 
if( -not (Test-path "C:\utils")) 
    {
    New-Item -path "C:\Utils" -ItemType "directory"
    }

msiexec.exe /i $msiFile AGREETOLICENSE=yes DEPLOYMENT_SERVER="<splunkdeployment>:8089" RECEIVING_INDEXER="<splunkindexer>:9997" LAUNCHSPLUNK=1 SPLUNKUSERNAME="<user>" SPLUNKPASSWORD="<password>" /quiet /l*v C:\utils\install.log
}


$PathfilesMSI = "\\<Server>\SplunkAgent\"
$ForwarderInstalledPath = "C:\Program Files\SplunkUniversalForwarder"
$file = get-childitem -Path $PathfilesMSI -File | sort-object -Property Name -Descending | select-object -First 1
$msipath = $file.FullName.ToString()

# Validate soft not installed
if (-not (Test-Path $ForwarderInstalledPath)){
    Write-output "MSi is $msiversion - new install"
set-splunkforwarder -MsiFile $msipath
}

else
{
#compare soft version w installer msi
$installedVersion = Get-WmiObject -Class Win32_Product -Filter "Name = 'UniversalForwarder'" | Select-Object -ExpandProperty Version /quiet
$installedVersion = $installedVersion.ToString()
# msi version - cheated - pulled string between first 2 dash signs - -
$pattern = '(?<=\-).+?(?=\-)'
$msiVersion = [regex]::Matches($file.Name.ToString(), $pattern).Value | Select-Object -first 1
# Uninstall Splunk if versions do not match
    if ($installedVersion -ne $msiVersion)
    {   Write-output "MSi is $msiversion  Soft upgraded from $installedVersion"
        #Stop the service
        $svc= Get-Service -Name "SplunkForwarder"
        if ($null -ne $svc){
        Stop-Service $svc -Force
            while($svc.Status -ne 'Stopped')
            {
            Write-Output "Waiting for service to stop"
	        Start-Sleep -Seconds 10
            }
        # Uninstall the version on server
        $app = Get-WmiObject -Class Win32_Product -Filter "Name = 'UniversalForwarder'"
        $app.Uninstall()
        # Install current version
        set-splunkforwarder -MsiFile $msipath
        }
    }
    else { Write-output "Nothing installed MSI $msiversion same as installed SplunkFW  $Installedversion"}
}
#Eof
