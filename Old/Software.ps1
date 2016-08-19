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
	
	#SQL TCP/IP Enable
	Import-Module sqlps
	$smo = 'Microsoft.SqlServer.Management.Smo.'  
	$wmi = new-object ($smo + 'Wmi.ManagedComputer').  

	#List the object properties, including the instance names.  
	$Wmi  

	#Enable the TCP protocol on the default instance.  
	$uri = "ManagedComputer[@Name='CRM01']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
	$Tcp = $wmi.GetSmoObject($uri)  
	$Tcp.IsEnabled = $true  
	$Tcp.Alter()  
	$Tcp  
	
	#SQL requires restart post config
	Restart-Service MSSQLSERVER -Force

    #Make Directory
    mkdir "C:\CRM"
    cd "C:\CRM"

	#Download Install Package
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/CRM2016-Server-ENU-amd64.exe" -Destination "C:\CRM\CRM2016-Server-ENU-amd64.exe"
	Start-BitsTransfer -Source "https://s3-eu-west-1.amazonaws.com/crmdev-lm/config.xml" -Destination "C:\CRM\CRMSetupconfig.xml"
	
	#Extract Files
	.\CRM2016-Server-ENU-amd64.exe /extract:C:\CRM /quiet /log:C:\log\install.txt
	
	#Run CRM Installer
	cd C:\CRM
	.\SetupServer.exe /Q /config c:\CRM\CRMSetupconfig.xml
	} 

elseif ($hostname -eq "SHA01"){

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