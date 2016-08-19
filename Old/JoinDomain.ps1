#Join Domain
start-transcript C:\temp\output.txt -force
$script = 'Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.0.0.4	crmdev.local"
$secpasswd = ConvertTo-SecureString "Lockheed.2015" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("Sysadmin", $secpasswd)
Add-Computer -DomainName CRMDEV.local -Credential $mycreds -Force 
Shutdown /r /t 0'

$secpasswd = ConvertTo-SecureString "Lockheed.2015" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("Sysadmin", $secpasswd)

$script | Out-file C:\Scripts\Domain.ps1 -force
Start-Process powershell.exe -Credential $mycreds --ArgumentList "-file C:\Scripts\Domain.ps1"

Stop-Transcript
