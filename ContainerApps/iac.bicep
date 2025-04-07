param location string = resourceGroup().location
param containerAppName string = 'tgrazurecontainerdemo'
param containerImage string = '10gler/testrepo:v1.0'
param environmentName string = 'tgrazurecontainerdemo-env'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: environmentName
  location: location
  properties:{
     daprAIInstrumentationKey: ''
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          name: 'aspnetcore-container'
          image: containerImage
          resources: {
            cpu: 2
            memory: '4.0Gi'
          }
        }
      ]
    }
  }
}

output containerAppUrl string = 'https://${containerApp.name}.${location}.azurecontainerapps.io'
