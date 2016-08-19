#Script to deploy a development enviroment for CRM. This can be with our without Sharepoint

#Stop at Error
$ErrorActionPreference = "Stop"
cls

#Blurb
Write-host -f Green " -------------------------------------------------- "
Write-host -f Green "|                                                  |"
Write-host -f Green "|       CRM Development Enviroment Auto Deploy     |"
WrIte-host -f Green "|                                                  |"
Write-host -f Green " -------------------------------------------------- "                                                 


Write-host "`n`n`nThis script will allow you to deploy a CRM Development `nEnviroment to Azure. There is a choice to include Sharepoint `nas well. You will need an Azure account to deploy into `na prompt is provided for you to enter you credentials. This only `nneeds to be done once per session.`n`nYou are able to use `$login = 0 to disable the prompt, this `nproperty is set after a sucessful login anyway.`n`n"



#Check if client is already logged in, if so skip prompt
if (Get-Variable login -Scope Global -ErrorAction SilentlyContinue){
}
else {
    Login-AzureRmAccount 
}

#Sucessful Login Flag
$login = 0

$RG = Read-Host "Please enter the name of the resource group you want to create"

#Create new resource group
New-AzureRmResourceGroup -Name $RG -Location "West Europe"

Write-Host -f Yellow "[INFRASTRUCTURE] Sucessfully created a new resource group"


$title = "Sharepoint"
$message = "Include Sharepoint"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "CRM + Sharepoint"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Only CRM"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {New-AzureRmResourceGroupDeployment -Name $RG -ResourceGroupName $RG -TemplateFile "https://s3-eu-west-1.amazonaws.com/crmdev-lm/CRM.json"}
        1 {New-AzureRmResourceGroupDeployment -Name $RG -ResourceGroupName $RG -TemplateFile "https://s3-eu-west-1.amazonaws.com/crmdev-lm/CRM_Share.json"}
    }


Write-Host -f Yellow "[INFRASTRUCTURE] Sucessfully Deployed VM's"

#Arrays for script files. Add script files to array matching the VM
$DC = @("DC-Build.ps1", "CreateUsers.ps1")
$CRM = @("SQL-Share.ps1") 
#$CRM = @("CRMInstall.ps1") 

#Script to run on the DC
foreach ($item in $DC){
Write-Host -f Cyan "[SOFTWARE] Starting script: $item"
$SettingsString = '{"fileUris":["https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/'+ $item + '"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -File C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\Downloads\\0\\' + $item+ '"}'
Set-AzureRmVMExtension -ResourceGroupName "$RG" -Location "West Europe" -VMName "DC01" -Name "MyCustomScriptExtension" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion "1.8" -SettingString $SettingsString
    
    if($item -eq "DC-Build.ps1") {
        Sleep 300}
    else {
    }

Remove-AzureRmVMExtension -ResourceGroupName "$RG" -VMName "DC01" -Name "MyCustomScriptExtension" -Force
}


#Add DC DNS
Write-Host -f Cyan "[SOFTWARE] Adding Host File Entry"
$SettingsString = '{"fileUris":["https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/DCRoute.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -File C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\Downloads\\0\\DCRoute.ps1"}'
Set-AzureRmVMExtension -ResourceGroupName "$RG" -Location "West Europe" -VMName "CRM01" -Name "MyCustomScriptExtension" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion "1.8" -SettingString $SettingsString
Remove-AzureRmVMExtension -ResourceGroupName "$RG" -VMName "CRM01" -Name "MyCustomScriptExtension" -Force


Write-Host -f Cyan "[SOFTWARE] Starting JSONJoinDomain Extension"

#JsonADDomainExtension
$options = '{ 
   "Name": "CRMDev.local", 
   "User": "CRMDev.local\\Sysadmin", 
   "Restart": "true", 
   "Options": "3" 
        }'
$pwd = '{ "Password": "Lockheed.2015" }'

Set-AzureRmVMExtension -ResourceGroupName $RG -ExtensionType "JsonADDomainExtension" `
    -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" `
    -VMName CRM01 -Location "West Europe" -SettingString $options `
    -ProtectedSettingString $pwd

#Remove-AzureRmVMExtension -ResourceGroupName "$RG" -VMName "CRM01" -Name "joindomain" -Force

#Scripts to run

foreach($item in $CRM){
Write-Host -f Cyan "[SOFTWARE] Starting Script: $item"
$SettingsString = '{"fileUris":["https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/'+ $item + '"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -File C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\Downloads\\0\\' + $item+ '"}'
Set-AzureRmVMExtension -ResourceGroupName "$RG" -Location "West Europe" -VMName "CRM01" -Name "MyCustomScriptExtension" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion "1.8" -SettingString $SettingsString
Remove-AzureRmVMExtension -ResourceGroupName "$RG" -VMName "CRM01" -Name "MyCustomScriptExtension" -Force
Write-Host -f Cyan "RDP into the CRM server and execute the CRM install script which can be found on the Desktop"
}

#Install Sharepoint if needed

if ($result -eq 0){
Write-Host -f Red "BEFORE CONTIUING ENSURE THE CRM SCRIPT HAS BEEN STARTED"
Pause
Write-Host -f Cyan "[SOFTWARE] Adding Host File Entry"
$SettingsString = '{"fileUris":["https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/DCRoute.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -File C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\Downloads\\0\\DCRoute.ps1"}'
Set-AzureRmVMExtension -ResourceGroupName "$RG" -Location "West Europe" -VMName "SHA01" -Name "MyCustomScriptExtension" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion "1.8" -SettingString $SettingsString
Remove-AzureRmVMExtension -ResourceGroupName "$RG" -VMName "SHA01" -Name "MyCustomScriptExtension" -Force


Write-Host -f Cyan "[SOFTWARE] Starting JSONJoinDomain Extension"

#JsonADDomainExtension
$options = '{ 
   "Name": "CRMDev.local", 
   "User": "CRMDev.local\\Sysadmin", 
   "Restart": "true", 
   "Options": "3" 
        }'
$pwd = '{ "Password": "Lockheed.2015" }'

Set-AzureRmVMExtension -ResourceGroupName $RG -ExtensionType "JsonADDomainExtension" `
    -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" `
    -VMName SHA01 -Location "West Europe" -SettingString $options `
    -ProtectedSettingString $pwd

Write-Host -f Cyan "[SOFTWARE] Installing Sharepoint"
$SettingsString = '{"fileUris":["https://s3-eu-west-1.amazonaws.com/crmdev-lm/Scripts/SQL-Share.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -File C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\Downloads\\0\\SQL-Share.ps1"}'
Set-AzureRmVMExtension -ResourceGroupName "$RG" -Location "West Europe" -VMName "SHA01" -Name "MyCustomScriptExtension" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion "1.8" -SettingString $SettingsString 
}

Write-host -f Green "`n`nINSTALL COMPLETED"