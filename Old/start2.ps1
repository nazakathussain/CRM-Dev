
#Declare Credential
$username = "nazakat"
$password = "Lockheed.2015"
$credentials = New-Object System.Management.Automation.PSCredential($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))

#Download Task Script
mkdir C:\Temp
Invoke-WebRequest "https://s3-eu-west-1.amazonaws.com/crmdev-lm/DC-Build.ps1" -OutFile "C:\Temp\DC-Build.ps1"

#Execute Task
Start-Process powershell -Credential $credentials -NoNewWindow -ArgumentList "C:\Temp\DC-Build.ps1"

