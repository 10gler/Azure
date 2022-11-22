param location string = resourceGroup().location
param sqlServerName string = 'tgrTmpSqlServer'
param administratorLogin string = 'stengler'
param administratorLoginPassword string = 'Qwerty12@!'

param databaseName string = 'tgrTmpSqlServer'


resource sqlsrv 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version:'12.0'
  }
}

resource db 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: databaseName
  location: location
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  parent: sqlsrv
  properties: {
    autoPauseDelay: 60
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    minCapacity: json('0.5')
    readScale: 'Disabled'
    zoneRedundant: false
  }
}

resource sqlsrvfirewall 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlsrv
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

param hostingPlanName string = 'tgrTmpFreePlan'
resource webfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
  kind: 'windows'
}
