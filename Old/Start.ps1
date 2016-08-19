mkdir "C:\Scripts"
Invoke-Webrequest "https://s3-eu-west-1.amazonaws.com/crmdev-lm/JoinDomain.ps1" -Outfile "C:\Scripts\JoinDomain.ps1"
Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
Set-ItemProperty -Path . -Name joinDomain -Value "powershell.exe C:\scripts\JoinDomain.ps1"
Restart-Computer	