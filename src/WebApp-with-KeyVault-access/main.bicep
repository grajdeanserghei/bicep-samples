targetScope='subscription'

param env string

param location string

param sqlServerName string

param sharedResourceGroupName string

param keyVaultName string

// Web App params
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@minValue(1)
param skuCapacity int = 1

var resourceGroupName = 'rg-sgtestow-${env}-${location}'

resource envRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module application 'application.bicep' = {
  scope: envRG
  name: 'applicationResources'
  params:{
    location: location
    env: env
    tenantId: subscription().tenantId
    sharedResourceGroupName: sharedResourceGroupName
    sqlServerName: sqlServerName
    databaseName: 'test-db'
    //dbLogin: kv.getSecret('sgtestow-app-sqlLogin-${env}')
    //dbPassword: kv.getSecret('sgtestow-app-sqlPassword-${env}')
    skuName: skuName
    skuCapacity: skuCapacity
  }
}

output webSiteName string = application.outputs.webSiteName
output webSiteDefaultHostName string = application.outputs.webSiteDefaultHostName
