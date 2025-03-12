#Written by LongTechnet
#
#create virtual network
$rg1 = "company-hub"
$loc = 'eastus'

#VNET1
$vnetname1 = 'company.hub'
$subnetname1 = "$VNETName1.in"
$subnetname2 = "$VNETName1.out"
$subnetname3 = "$VNETName1.mgmt" #"GatewaySubnet"

#subnets you want to deploy with address space
[array] $subnets = @()
$subnets += New-Object -TypeName psobject -Property @{"Name"="$subnetname1"; "AddressPrefix"="10.200.0.64/27"} #update name and address space
$subnets += New-Object -TypeName psobject -Property @{"Name"="$subnetname2"; "AddressPrefix"="10.200.0.32/27"}
$subnets += New-Object -TypeName psobject -Property @{"Name"="$subnetname3"; "AddressPrefix"="10.200.0.0/27"}

New-AzVirtualNetwork -ResourceGroupName $rg1 -Location $loc -Name $vnetname1 -AddressPrefix "10.200.0.0/24" -Subnet $subnets 
