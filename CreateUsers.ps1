$users = @("CRMService", "CRMSandboxService", "CRMDeploymentService", "CRMAsyncService", "CRMVSSWriterService", "CRMMonitoringService", "SP_SearchService", "SP_ProfilesAppPool", "SP_PortalAppPool","SP_Services","SP_CacheSuperUser", "SP_CacheSuperReader")

foreach ($user in $users){
New-ADUser -Name $user -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String "Lockheed.2015")|Enable-ADAccount
Enable-ADAccount -Identity $user
Add-ADGroupMember Administrators $user
}

New-ADOrganizationalUnit -Name CRM -Path "DC=CRMDev,DC=local"