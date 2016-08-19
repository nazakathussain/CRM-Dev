$users = @("CRMService", "CRMSandboxService", "CRMDeploymentService", "CRMAsyncService", "CRMVSSWriterService", "CRMMonitoringService", "SP_SearchService", "SP_ProfilesAppPool", "SP_PortalAppPool","SP_Services","SP_CacheSuperUser", "SP_CacheSuperReader")

foreach ($item in $users){
New-ADUser -Name $item -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String "Lockheed.2015")|Enable-ADAccount
Enable-ADAccount -Identity $item
Add-ADGroupMember Administrators $item
}

New-ADOrganizationalUnit -Name CRM -Path "DC=CRMDev,DC=local"