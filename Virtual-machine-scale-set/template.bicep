
param location string = resourceGroup().location

 var vssName = 'tgrVmss'


resource symbolicname 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: vssName
  location: location
  properties: {
    orchestrationMode: 'Uniform'
      mode: 'Manual'
      extensionProfile: {
        osProfile: {
          adminPassword: 'Szymon.Tengler'
          adminUsername: 'stengler'
        }
      }
  }
}
