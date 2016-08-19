if (Get-Variable login -Scope Global -ErrorAction SilentlyContinue){
    return
}
else {
    Add-AzureRmAccount
    $login = 0
}

$possible = @("DC1", "DC2", "DC3", "DC4")
$avaliable = @()
foreach ($item in $possible){

    Get-AzureRmResourceGroup -Name $item -ev notPresent -ea 0

        if ($notPresent) {
            $avaliable += "$item"
        }
        else{
        # ResourceGroup exist

        Remove-AzureRmResourceGroup -Name $item -Force
        }
    }
New-AzureRmResourceGroup -Name ExampleResourceGroup -Location "West Europe"
New-AzureRmResourceGroupDeployment -Name $avaliable[0] -ResourceGroupName $avaliable[0] -TemplateFile "https://s3-eu-west-1.amazonaws.com/crmdev-lm/2+Server+Setup.json"
