$RGName = "TgrTmp"
$LoadBalancerName = "TgrPublicLoadBalancer"
$BackendPoolName = "webBackendPool"
$NicNames = @("TgrVMnic1", "TgrVMnic2")

$ErrorActionPreference = "Stop"

New-AzResourceGroupDeployment `
    -ResourceGroupName $RGName `
    -TemplateFile .\azuredeploy.loadbalancer.json

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $RGName -Name $LoadBalancerName
$backendPool = $loadBalancer | Get-AzLoadBalancerBackendAddressPoolConfig -Name $BackendPoolName

# Detach Basic public IPs in a separate NIC update. Azure rejects a NIC update
# that combines a Basic public IP with a Standard Load Balancer backend pool.
foreach ($nicName in $NicNames) {
    $nic = Get-AzNetworkInterface -ResourceGroupName $RGName -Name $nicName

    foreach ($ipConfig in $nic.IpConfigurations) {
        $ipConfig.PublicIpAddress = $null
    }

    $nic | Set-AzNetworkInterface | Out-Null

    $detachedNic = Get-AzNetworkInterface -ResourceGroupName $RGName -Name $nicName
    $stillHasPublicIp = @($detachedNic.IpConfigurations | Where-Object { $null -ne $_.PublicIpAddress }).Count -gt 0
    if ($stillHasPublicIp) {
        throw "Could not detach the Basic public IP from NIC '$nicName'. Check the NIC configuration before retrying."
    }
}

# Add the NICs to the Standard Load Balancer only after the Basic IPs are detached.
foreach ($nicName in $NicNames) {
    $nic = Get-AzNetworkInterface -ResourceGroupName $RGName -Name $nicName

    foreach ($ipConfig in $nic.IpConfigurations) {
        $pools = @($ipConfig.LoadBalancerBackendAddressPools | Where-Object { $_.Id -ne $backendPool.Id })
        $ipConfig.LoadBalancerBackendAddressPools = $pools + $backendPool
    }

    $nic | Set-AzNetworkInterface | Out-Null

    $updatedNic = Get-AzNetworkInterface -ResourceGroupName $RGName -Name $nicName
    $isAttached = @($updatedNic.IpConfigurations | Where-Object {
        @($_.LoadBalancerBackendAddressPools | Where-Object { $_.Id -eq $backendPool.Id }).Count -gt 0
    }).Count -gt 0
    if (-not $isAttached) {
        throw "NIC '$nicName' was not attached to backend pool '$BackendPoolName'."
    }
}

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $RGName -Name $LoadBalancerName
$loadBalancerPublicIp = Get-AzPublicIpAddress -ResourceGroupName $RGName -Name "TgrLoadBalancerPublicIp"
Write-Host "Load balancer backend NICs: $($NicNames -join ', ')"
Write-Host "Load balancer public IP: $($loadBalancerPublicIp.IpAddress)"
