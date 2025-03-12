#Written by LongTechnet
#
#1  User

$Username = "LocalUser1"
#2  Password
$password = "asdfjkl;12345"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$SecureString = $pass
# Users you password securly
$MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SecureString 

#login end

##VM1
$AzureRGName = "company-hub"
$vmname1 = "companyhubfw1"
$IPAddress1 = "10.210.0.69"
$IPAddress2 = "10.210.0.39"
$AvailabilitySetName = ("company-hub-avset")
$NetworkName = "company.hub"
$VnetAddressPrefix = "10.210.0.0/24"
$VmSize = "Standard_Ds3_V2"
$AzureRegion = "eastus"
$nicname1 = "$vmname1-1"
$nicname2 = "$vmname1-2"



#create Resource group
$ResourceGroupName = Get-AZResourceGroup -Name $AzureRGName -Location $AzureRegion
$Vnet = get-AZVirtualNetwork -Name $NetworkName -ResourceGroupName $AzureRGName

#new nic 
$nic1 = New-AZNetworkInterface -Name $nicname1 -ResourceGroupName $AzureRGName -Location $AzureRegion -SubnetId $vnet.Subnets[0].Id -PrivateIpAddress $IPAddress1 
$nic2 = New-AZNetworkInterface -Name $nicname2 -ResourceGroupName $AzureRGName -Location $AzureRegion -SubnetId $vnet.Subnets[1].Id -PrivateIpAddress $IPAddress2 

#new avset
$AVSet = New-AZAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $AzureRGName -Location $AzureRegion -Sku Aligned -PlatformUpdateDomainCount 3 -PlatformFaultDomainCount 3 
#config
$vmconfig = New-AZVMConfig -VMName $vmname1 -VMSize $VmSize -AvailabilitySetId $AVSet.id
#attach nics
$vm = Add-AZVMNetworkInterface -VM $vmconfig -Id $nic1.Id -Primary 
$vm = Add-AZVMNetworkInterface -VM $vmconfig -Id $nic2.Id 


#image
Set-AZVMSourceImage -VM $vm -PublisherName "paloaltonetworks" -Offer "vmseries-flex" -Skus "byol" -Version "latest" 
#plan agreement
Set-AzVMPlan -VM $vm -Name 'byol' -Publisher 'paloaltonetworks' -Product 'vmseries-flex' #Product research id
set-AzMarketplaceTerms -Name 'byol' -Publisher 'paloaltonetworks' -Product 'vmseries-flex' -Accept -Confirm 
#set OS and Disk
Set-AZVMOperatingSystem -VM $vm -Linux -ComputerName $vmname1 -Credential $MySecureCreds  
$osDiskName = $vmname1 + "-OS"
$vm = Set-AZVMOSDisk -VM $vm -Name $osdiskname -CreateOption FromImage -DiskSizeInGB 128 -StorageAccountType Standard_LRS -Verbose
#logs
#$VM = Set-AzVMBootDiagnostic -Disable 
#vm creation
New-AZVm -ResourceGroupName $AzureRGName -Location $AzureRegion -VM $vm -tag $tag -Verbose #-Asjob


