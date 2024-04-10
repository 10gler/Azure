param redisCacheName string = 'tgrredistoremove'
param location string = resourceGroup().location
param hostingPlanName string = 'tgrHostinPlanToRemobve'
param websiteName string = 'tgrWebSiteNameToRemove'

resource redisCache 'Microsoft.Cache/Redis@2020-06-01' = {
  name: redisCacheName
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0 
    }
  }
}

resource webfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  kind: 'windows'
}

resource site 'Microsoft.Web/sites@2022-03-01' = {
  name: websiteName
  location: location
  properties: {
    serverFarmId: webfarm.id
  }
}
