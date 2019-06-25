#Customize the variables below

#ResourceGroup name and location
$prefix = "poc-" #not in use yet, might be necessary for multi user deployment
$rg = "emulated-on-premises-rg"
$stgaccountname = "pocazwu2infnpsa0001"
$location = "WestUS2"
$VMSize = "Standard_D2s_v3"

#Subscription Details
#Login-AZAccount
Select-AZSubscription -SubscriptionId "467935cd-d314-4b45-8a8b-8ef1d22878b6"


#---------------------------------------------------------------------------------------------------------------------------------------#

#User credentials for JumpBox and Server VMs
$adminUserName = "localadmin"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"

#Create new RG
New-AzResourceGroup -Name $rg -Location $location

#Create new Storage Account
New-AzStorageAccount -ResourceGroupName $rg -AccountName $stgaccountname -Location $location -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot -EnableHttpsTrafficOnly $true -AssignIdentity

#Create Vnet
$VnetName = "EMULATED-ONPREM-NETWORK"
New-AzVirtualNetwork -ResourceGroupName $rg -Location $location -Name $VnetName -AddressPrefix 10.152.0.0/22

#Configure subnets
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $VnetName
Add-AzVirtualNetworkSubnetConfig -Name Jumpbox-sn -VirtualNetwork $vnet -AddressPrefix "10.152.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name Services-sn -VirtualNetwork $vnet -AddressPrefix "10.152.2.0/24"
Add-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet -AddressPrefix "10.152.3.224/27"
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow_RDP_In"  -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create a network security group
$NsgName = "Jumpbox-NSG"
New-AzNetworkSecurityGroup -ResourceGroupName $rg -Location $location -Name $NsgName -SecurityRules $nsgRuleRDP

#Create jumpbox
$vmname = "john-jumpbox"
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $VnetName
$JumpBoxSubnetId = $vnet.Subnets[1].Id

# Create a virtual network card and associate with jumpbox public IP address
$JumpBoxNic = New-AzNetworkInterface -Name "$vmname-NIC1" -ResourceGroupName $rg -Location $location -SubnetId $JumpBoxSubnetId -PublicIpAddressId $JumpBoxpip.Id -NetworkSecurityGroupId $nsg.Id
$JumpBoxConfig = New-AzVMConfig -VMName $vmname -VMSize $VMSize | Set-AzVMOperatingSystem -Windows -ComputerName $vmname -Credential $adminCred | Set-AzVMSourceImage -PublisherName "MicrosoftVisualStudio" -Offer "VisualStudio" -Skus "VS-2017-Comm-Latest-Win10-N" -Version latest | Add-AzVMNetworkInterface -Id $JumpBoxNic.Id
New-AzVM -ResourceGroupName $rg -Location $location -VM $JumpBoxConfig