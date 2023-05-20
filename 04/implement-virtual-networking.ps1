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
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix '10.40.0.0/20' -Subnet $subnet0,$subnet1

# Deploy virtual machines using the template files included in the Labs
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $HOME/az104-04-vms-loop-template.json -TemplateParameterFile $HOME/az104-04-vms-loop-parameters.json

# Create public IP addresses which will be used to associate with NICs of both VMs
$pip0 = New-AzPublicIpAddress -Name 'az104-04-pip0' -ResourceGroupName $rgName -AllocationMethod Static -Location $location -Sku 'Standard' -IpAddressVersion 'IPv4'
$pip1 = New-AzPublicIpAddress -Name 'az104-04-pip1' -ResourceGroupName $rgName -AllocationMethod Static -Location $location -Sku 'Standard' -IpAddressVersion 'IPv4'

# Retrieve data about both network interface cards
$nic0 = Get-AzNetworkInterface -Name 'az104-04-nic0' -ResourceGroupName $rgName 
$nic1 = Get-AzNetworkInterface -Name 'az104-04-nic1' -ResourceGroupName $rgName

# Associate both public IP addresses with IP configurations for both NICs
$nic0 | Set-AzNetworkInterfaceIpConfig -Name ipconfig1 -PublicIpAddress $pip0 -Subnet $subnet0
$nic1 | Set-AzNetworkInterfaceIpConfig -Name ipconfig1 -PublicIpAddress $pip1 -Subnet $subnet1

# Write the new IP configurations to the network interfaces
$nic0 | Set-AzNetworkInterface
$nic1 | Set-AzNetworkInterface
