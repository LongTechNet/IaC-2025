##Written by LongTechnet
#

$ResourceGroupName = "company-hub" # Resource group name
$vnetrg = "company-hub"
$VNetName = "company.hub"         # Virtual network name
$SubnetName = "company.hub.in"  # Subnet name
$PipName = "comhub-inlb-pip"            # ILB name
$IlbName = "companyhub-inlb" 
$Location = "eastus"                 # Azure location
$VMNames = "companyhubfw1" 

$ILBIP = "10.200.0.75"                         # IP address
[int]$ListenerPort = "8008"                # AG listener port
[int]$ProbePort = "8008"                   # Probe port

$LBProbeName ="ILBPROBE_$ListenerPort"       # The Load balancer Probe Object Name              
$LBConfigRuleName = "ILBCR_$ListenerPort"    # The Load Balancer Rule Object Name

$FrontEndConfigurationName = "companyhub-inlb-fe" # Object name for the front-end configuration 
$BackEndConfigurationName = "companyhub-inlb-be"   # Object name for the back-end configuration

Get-AzResourceGroup -name $ResourceGroupName -Location $location 

$VNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg 

$Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $SubnetName 

$FEConfig = New-AzLoadBalancerFrontendIpConfig -Name $FrontEndConfigurationName -PrivateIpAddress $ILBIP -SubnetId $Subnet.id 

$BEConfig = New-AzLoadBalancerBackendAddressPoolConfig -Name $BackEndConfigurationName 

$SQLHealthProbe = New-AzLoadBalancerProbeConfig -Name $LBProbeName -Protocol tcp -Port $ProbePort -IntervalInSeconds 15 -ProbeCount 2

$ILBRule = New-AzLoadBalancerRuleConfig -Name $LBConfigRuleName -FrontendIpConfiguration $FEConfig -BackendAddressPool $BEConfig -Probe $SQLHealthProbe -Protocol "tcp" -FrontendPort $ListenerPort -BackendPort $ListenerPort -LoadDistribution Default  

$ILB= New-AzLoadBalancer -Location $Location -Name $ILBName -ResourceGroupName $ResourceGroupName -FrontendIpConfiguration $FEConfig -BackendAddressPool $BEConfig -LoadBalancingRule $ILBRule -Probe $SQLHealthProbe 
#break
$bepool = Get-AzLoadBalancerBackendAddressPoolConfig -Name $BackEndConfigurationName -LoadBalancer $ILB 

foreach($VMName in $VMNames)
    {
        $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName 
        $NICName = ($vm.NetworkProfile.NetworkInterfaces.Id.split('/') | select -last 1)
        $NIC = Get-AzNetworkInterface -name $NICName -ResourceGroupName $ResourceGroupName
        $NIC.IpConfigurations[0].LoadBalancerBackendAddressPools = $BEPool
        Set-AzNetworkInterface -NetworkInterface $NIC
        start-AzVM -ResourceGroupName $ResourceGroupName -Name $VM.Name 
    } 

