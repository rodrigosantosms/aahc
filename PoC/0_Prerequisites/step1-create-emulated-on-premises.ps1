#Requires -Version 5.0
<#
.DISCLAIMER
    MIT License - Copyright (c) Microsoft Corporation. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE
.DESCRIPTION
    FileName: step1-create-emulated-on-premises.ps1
    This script creates 1 Virtual Network, 3 Subnets, 1 NSG, 1 VPN Gateway, 12 Local Network Gateways and Connections
    It can take up to 45 min to complete due to gateway creation
.NOTES
    AUTHOR(S): 
    KEYWORDS: Azure Deploy, PoC, Deployment
#>

# IMPORTANT: Change the value of the following parameters if needed:
#    RgName             <-- This is the Resource Group that will be created to host your Emualted-On-Premises resources
#    location           <-- Location for all resources
#    sharedkey          <-- Shared Key to establish VPNs between attendees and trainner environment
#    NumberOfAttendees  <-- Enter the # number of people that will deploy the POC environment
#
# Example of how to run this script:
# .\deploy-jumpboxes.ps1 -RgName "emulated-on-premises-rg" -location "WestUS2" -sharedkey "define-your-shared-key-123" -NumberOfAttendees=12

### Update the parameters below or provide the values when running the script

Param(
    
    [string] $RgName = 'emulated-on-premises-rg',
    [string] $location = 'westus2',
    [string] $sharedkey = 'define-your-shared-key-123',
    [Int] $NumberOfAttendees = 12
)

#---------------------------------------------------------------------------------------------------------------------------------------#

#Create new RG
New-AzResourceGroup -Name $RgName -Location $location

#Create Vnet
$VnetName = "emulated-on-premises-vnet"
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name "adds-svc-sn" -AddressPrefix "10.152.101.0/27"
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name "jumpbox-sn" -AddressPrefix "10.152.101.32/27"
$subnet3 = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix "10.152.101.224/27"
New-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgName -Location $location -AddressPrefix 10.152.101.0/24 -Subnet $subnet1, $subnet2, $subnet3

# Create an inbound network security group rule for port 3389, and Create a network security group
$NsgName = "jumpbox-sn-nsg"
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow_RDP_In" -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $location -Name $NsgName -SecurityRules $nsgRuleRDP

# Create Multiple Local Network Gateways (One for each attendee)
$NumberOfAttendees=$NumberOfAttendees+100
for ($i=101; $i -le $NumberOfAttendees; $i++ ){
        New-AzLocalNetworkGateway -Name "attendee-$i-lng" -ResourceGroupName $RgName -Location $location -GatewayIpAddress "$i.0.0.0" -AddressPrefix "10.$i.0.0/22"
}

# Create VPN Virtual Network Gateway (After running this command, it can take up to 45 minutes for the gateway configuration to complete)
$vngname = "on-premfirewall-vng"
$gwpip= New-AzPublicIpAddress -Name $vngname-pip -ResourceGroupName $RgName -Location $location -AllocationMethod Dynamic
$vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id
New-AzVirtualNetworkGateway -Name $vngname -ResourceGroupName $RgName -Location $location -IpConfigurations $gwipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1

# Create Multiple Connections (One for each attendee)
$vngop = Get-AzVirtualNetworkGateway -Name $vngname -ResourceGroupName $RgName
$NumberOfAttendees=$NumberOfAttendees+100
for ($i=101; $i -le $NumberOfAttendees; $i++ ){
        $lng = Get-AzLocalNetworkGateway   -Name "attendee-$i-lng" -ResourceGroupName $RgName
        New-AzVirtualNetworkGatewayConnection -Name "attendee-$i-lng" -ResourceGroupName $RgName -Location $location -VirtualNetworkGateway1 $vngop -LocalNetworkGateway2 $lng -ConnectionType IPsec -RoutingWeight 10 -SharedKey $sharedkey
}