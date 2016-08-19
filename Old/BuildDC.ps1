#Setup subscription connection

cd "C:\Users\nazakat.hussain\Documents\Powershell Scripts\CRMShare"
$subscr="Free Trial"
$staccount="ntportalvhdswp97s2hw50hc"
New-AzureStorageAccount â€“StorageAccountName $staccount -Location "West Europe"
Select-AzureSubscription -SubscriptionName $subscr â€“Current
Set-AzureSubscription -SubscriptionName $subscr -CurrentStorageAccountName $staccount
Set-AzureVNetConfig NetworkConfig.XML
Write-Verbose "New Storage created or error for existing storage area displayed"


#Image name 
$image = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20151120-en.us-127GB.vhd"
$vmname="DC01"
$vmsize="Basic_A3"
$vm1=New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $image

Write-Verbose "Image seclect and VM configuration created"

#Credentials
$vm1 | Add-AzureProvisioningConfig -Windows -AdminUsername "Nazakat" -Password "Egress.2015"

Write-Verbose "Credentials for New VM Set"


$disksize=40
$disklabel="OS"
$lun=1
$hcaching="None"

#Drive to create
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $disksize -DiskLabel $disklabel -LUN $lun -HostCaching $hcaching

Write-Verbose "Data disk created and added to VM Configuration"

#New Service
New-AzureService -ServiceName "CRMShare-Dev" -Location "West Europe"

Write-Verbose "New Service created"

#Provision
New-AzureVM -ServiceName "CRMShare-Dev" -VMs $vm1 -VNetName "CRMShare-Dev"
Get-AzureVM -ServiceName "CRMShare-Dev" -Name "DC01" |  Set-AzureSubnet –SubnetNames Subnet-1| Set-AzureStaticVNetIP -IPAddress "10.0.0.4" | Update-AzureVM

#Status Check
$status = Get-AzureVM -ServiceName "CRMShare-Dev" -Name "DC01" | Select -ExpandProperty Status
while ($status -ne "ReadyRole"){
sleep 10
Write-Host -ForegroundColor Green "Waiting for Azure VM to provision"
$status = Get-AzureVM -ServiceName "CRMShare-Dev" -Name "DC01" | Select -ExpandProperty Status
}

#Set and Get IP of server

$remoteIP = Get-AzureVM  -ServiceName "CRMShare-Dev"  | Select -ExpandProperty IPAddress
$remotePort=  Get-AzureVM -ServiceName "CRMShare-Dev" -Name "DC01" | Get-AzureEndpoint -Name "PowerShell" | Select -ExpandProperty Port


#Import Self Signed SSL certificate

$url = "https://CRMShare-Dev.cloudapp.net:$remoteport"
.\ImportCert.ps1 $url

#Remote into server to install DC and promote to DC

Invoke-Command -ComputerName  CRMShare-Dev.cloudapp.net -Port $remotePort -Credential Nazakat -UseSSL -ScriptBlock {"Install-windowsfeature -name AD-Domain-Services IncludeManagementTools"}
Invoke-Command -ComputerName  CRMShare-Dev.cloudapp.net -Port $remotePort -Credential Nazakat -UseSSL -ScriptBlock {
$domainName = "CRMShare.local"
$domainAdminCredential = Get-Credential
$dsrmPassword = (ConvertTo-SecureString -AsPlainText -Force -String "YourDSRMPassword!!")
Install-ADDSForest -CreateDnsDelegation:$false -DomainName $domainName -DomainNetbiosName $netbiosName -SafeModeAdministratorPassword $dsrmPassword}

#Create SQL VM

$vm2 = New-AzureVMConfig -Name "SQL01" -InstanceSize "Basic_A3" -ImageName $image
$vm2 | Add-AzureProvisioningConfig -Windows -AdminUsername "Nazakat" -Password "Egress.2015"
$vm2 | Add-AzureDataDisk -CreateNew -DiskSizeInGB "200" -DiskLabel "SQLData" -lun 1 -HostCaching "None"
New-AzureVM -ServiceName "CRMShare-Dev" -VMs $vm2


.\ImportCert.ps1 "https://crmshare-dev.cloudapp.net:49884"
Invoke-Command -Computer crmshare-dev.cloudapp.net -Port 49884 -Credential Nazakat -UseSSL -ScriptBlock {Add-Computer}

#Create CRM Server
#Create Sharepoint Ser