	#CRM Deployment Script - Part 2
	#use hostname to determine software/config to be used.
$hostname = hostname
if ($hostname -eq "CRM01"){	
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