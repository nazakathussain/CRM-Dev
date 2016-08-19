#Install DC services 

Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools

#Promote to DC and Reboot
$domainName = "CRMDev.local"

$dsrmPassword = (ConvertTo-SecureString -AsPlainText -Force -String "Lockheed.2015")

Install-ADDSForest -CreateDnsDelegation:$false -DomainName $domainName -DomainNetbiosName $netbiosName -SafeModeAdministratorPassword $dsrmPassword -Confirm:$false