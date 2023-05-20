# Declare variables to use in the lab
$rgName = 'az104-04-rg1'
$location = 'westus2'
$vnetName = 'az104-04-vnet1'

# Create a new resource group
New-AzResourceGroup -ResourceGroupName $rgName -Location $location

# Create in-memory representation of the first subnet
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'subnet0' -AddressPrefix '10.40.0.0/24'

# Create in-memory representation of the second subnet
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'subnet1' -AddressPrefix '10.40.1.0/24'

# Create a new virtual network using the CIDR 10.40.0.0/20 as the address prefix and the two subnets
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix '10.40.0.0/20' -Subnet $subnet0,$subnet1

# Deploy virtual machines using the template files included in the Labs
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $HOME/az104-04-vms-loop-template.json -TemplateParameterFile $HOME/az104-04-vms-loop-parameters.json

# Create public IP addresses which will be used to associate with NICs of both VMs
$pip0 = New-AzPublicIpAddress -Name 'az104-04-pip0' -ResourceGroupName $rgName -AllocationMethod 'Static' -Location $location -Sku 'Standard' -IpAddressVersion 'IPv4'
$pip1 = New-AzPublicIpAddress -Name 'az104-04-pip1' -ResourceGroupName $rgName -AllocationMethod 'Static' -Location $location -Sku 'Standard' -IpAddressVersion 'IPv4'

# Retrieve data about both network interface cards
$nic0 = Get-AzNetworkInterface -Name 'az104-04-nic0' -ResourceGroupName $rgName
$nic1 = Get-AzNetworkInterface -Name 'az104-04-nic1' -ResourceGroupName $rgName

# Associate both public IP addresses with IP configurations for both NICs
$nic0 | Set-AzNetworkInterfaceIpConfig -Name 'ipconfig1' -PublicIpAddress $pip0 -Subnet $subnet0
$nic1 | Set-AzNetworkInterfaceIpConfig -Name 'ipconfig1' -PublicIpAddress $pip1 -Subnet $subnet1

# Write the new IP configurations to the network interfaces
$nic0 | Set-AzNetworkInterface
$nic1 | Set-AzNetworkInterface

# Still need to set assignment of ipconfig1 from Dynamic to Static in the Portal, shell commands to be added later...

# Lab instructions require you to download the RDP file for vm0, attempt to connect, and note that the attmpted failed

# Stop both lab VMs before we create network security groups
Stop-AzVM -ResourceGroupName $rgName -Name 'az104-04-vm0'
Stop-AzVM -ResourceGroupName $rgName -Name 'az104-04-vm1'

# Create a rule to allow RDP inbound and a new network security group using that rule
$rule1 = New-AzNetworkSecurityRuleConfig -Name AllowRDPInbound -Description 'Allow RDP' -Access Allow -Protocol TCP -Direction Inbound -Priority 300 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgName -Location $location -Name 'az104-04-nsg01' -SecurityRules $rule1

# Associate the NSG with nic0
$nic0 = Get-AzNetworkInterface -Name 'az104-04-nic0' -ResourceGroupName $rgName
$nic0.NetworkSecurityGroup = $nsg
$nic0 | Set-AzNetworkInterface

# Associate the NSG with nic1
$nic1 = Get-AzNetworkInterface -Name 'az104-04-nic1' -ResourceGroupName $rgName
$nic1.NetworkSecurityGroup = $nsg
$nic1 | Set-AzNetworkInterface

# Start up both VMs
Start-AzVM -ResourceGroupName $rgName -Name 'az104-04-vm0'
Start-AzVM -ResourceGroupName $rgName -Name 'az104-04-vm1'

# At this point the lab instructs you to download the RDP file for vm0 and connect, it should work now that we've configured the NSG to allow RDP

# Create a private DNS zone
$zone = New-AzPrivateDnsZone -Name contoso.org -ResourceGroupName $rgName

# Create a virtual network link for the DNS zone
$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName contoso.org -ResourceGroupName $rgName -Name "az104-04-vnet1-link" -VirtualNetworkId $vnet.id -EnableRegistration
