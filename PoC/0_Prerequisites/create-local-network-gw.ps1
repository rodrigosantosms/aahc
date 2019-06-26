# Create Local Network Gateway and Connections
$vngop = Get-AzVirtualNetworkGateway -Name "on-premfirewall-vng"  -ResourceGroupName "emulated-on-premises-rg"
for ($i=101; $i -le 112; $i++ ){
        New-AzLocalNetworkGateway -Name "LNG-$i" -ResourceGroupName "emulated-on-premises-rg" -Location "West US 2" -GatewayIpAddress "$i.0.0.0" -AddressPrefix "10.$i.0.0/22"
        $lng = Get-AzLocalNetworkGateway   -Name "LNG-$i" -ResourceGroupName "emulated-on-premises-rg"
        New-AzVirtualNetworkGatewayConnection -Name "Conn-$i" -ResourceGroupName "emulated-on-premises-rg" -Location "West US 2" -VirtualNetworkGateway1 $vngop -LocalNetworkGateway2 $lng -ConnectionType IPsec -SharedKey "cheesebread0101$"
}