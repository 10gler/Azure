param location string = resourceGroup().location
param adminUsername string = 'mgrygiel'
param adminPassword string = 'TestPa$$w0rd!'
param publicIpName string = 'stPublicIpName'
param vmName string = 'stVm1'
param nicName string = 'stVmNic1'
param vmSize string = 'Standard_B2S'
param availabilitySetName string = 'stAvSet'


var storageAccountName = 'mgrygiel-${uniqueString(resourceGroup().id)}'
var addressPrefix = '10.0.0.0/16'
var subnetName  = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'stVmNet'
var networkSecurityGroupName = 'default-NSG'


resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-07-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties:{
    platformUpdateDomainCount: 5
    platformFaultDomainCount: 2
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// resource securityRule 'Microsoft.Network/networkSecurityGroups/securityRules@2023-05-01' ={
//   name: '${networkSecurityGroupName}-AllowAnyCustom80Inbound}'
//   parent: networkSecurityGroup
//   properties:{
//     protocol: '*'
//     sourcePortRange: '*'
//     destinationPortRange: '80'
//     sourceAddressPrefix: '*'
//     destinationAddressPrefix: '*'
//     access: 'Allow'
//     priority: 1010
//     direction: 'Inbound'
//     sourcePortRanges: []
//     destinationPortRanges: []
//     sourceAddressPrefixes: []
//     destinationAddressPrefixes: []
//   }
// }

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name:networkSecurityGroupName
  location:location
  properties:{
    securityRules:[
      {
        name: 'default-allow-3389'
        properties:{
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'default-allow-80'
        properties:{
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
