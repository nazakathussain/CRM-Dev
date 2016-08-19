#Script to install Software post infrastructure deployment.
#use hostname to determine software/config to be used.
$hostname = hostname

if ($hostname -eq "CRM01"){
	
	#download file
	mkdir C:\Temp	
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/SQLServer2016-x64-ENU.iso" -Destination "C:\Temp\SQLServer2016-x64-ENU.iso"

	#Download config file
	Invoke-WebRequest "https://s3-eu-west-1.amazonaws.com/crmdev-lm/ConfigurationFile.ini" -Outfile C:\Temp\ConfigurationFile.ini

	#Mount Image
	$mountVolume = Mount-DiskImage C:\Temp\SQLServer2016-x64-ENU.iso -PassThru
	$driveLetter = ($mountVolume | Get-Volume).DriveLetter	
	
	#Run SQL Installer
	cd "$driveLetter`:"
	.\Setup.exe /ConfigurationFile="C:\Temp\ConfigurationFile.INI"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/SQL-PreReqs/ReportViewer.msi" -Destination "C:\Temp\ReportViewer.msi"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/SQL-PreReqs/SQLSysClrTypes.msi" -Destination "C:\Temp\SQLSysClrTypes.msi"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/SQL-PreReqs/sqlncli.msi" -Destination "C:\Temp\sqlncli.msi"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/SQL-PreReqs/SharedManagementObjects.msi" -Destination "C:\Temp\SharedManagementObjects.msi"
	Start-BitsTransfer -Source "https://crmdev-lm.s3.amazonaws.com/SQL-PreReqs/dw20sharedamd64.msi" -Destination "C:\Temp\dw20sharedamd64.msi"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/CRMInstall.ps1" -Destination "C:\Users\Public\Desktop\CRMInstall.ps1"
	Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
	shutdown /r /t 15
	
	} 

elseif ($hostname -eq "SHA01"){
	Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.0.0.5	CRM01"
	#download software
	mkdir "C:\Sharepoint"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/sharepoint.iso" -Destination "C:\Sharepoint\sharepoint.iso"

	#Mount Image
	$mountVolume = Mount-DiskImage C:\Sharepoint\sharepoint.iso -PassThru
	$driveLetter = ($mountVolume | Get-Volume).DriveLetter	
	
	#Run SQL Installer
	cd "$driveLetter`:AutoSPInstaller"	
	cd AutoSPInstaller	
	.\AutoSPInstallerLaunch.bat
	}