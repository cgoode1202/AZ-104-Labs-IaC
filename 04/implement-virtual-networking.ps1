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
