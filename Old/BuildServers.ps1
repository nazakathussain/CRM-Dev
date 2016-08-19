Login-AzureRmAccount
$machines=@("DC01","SQL01","CRM01","SHA01")
$locName = "West Europe"
$rgName = "RM-CRM-Dev"
New-AzureRmResourceGroup -Name $rgName -Location $locName
$stName = "rmcrmev2343"
$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $stName -Type "Standard_LRS" -Location $locName
$subnetName = "Internal"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$vnetName = "RM-CRM-Dev"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet
$i= 0
foreach ($item in $machines){
$ipName = $machines[$i]
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nicName = $machines[$i]
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id
$cred = Get-Credential -Message "Type the name and password of the local administrator account."
$vmName = $machines[$i]
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_A0"
$compName = $machines[$i]
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $compName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -VM 
$vm -Id $nic.Id
$blobPath = "vhds/WindowsVMosDisk$i.vhd"
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + $blobPath
$diskName = "windowsvmosdisk$i"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm
$i++
}

