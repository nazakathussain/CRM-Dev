Login-AzureRmAccount
#Declare Array for Machine Names
$machines=@("DC01","SQL01","CRM01","SHA01")

#Retrieve IP Data for 4 machines
$ips = @()

foreach ($item in $machines)
    {
        $ips += Get-AzureRmPublicIpAddress -ResourceGroupName "RM-CRM-Dev" -Name $item | Select -ExpandProperty IpAddress
    }

