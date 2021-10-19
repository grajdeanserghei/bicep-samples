targetScope='subscription'

param env string

param location string

var resourceGroupName = 'rg-sg-kow-how-${env}-${location}'

resource envRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module sa 'storage-account.bicep' = {
  scope: envRG
  name: 'storage-account'
  params:{
    location: location
    env: env
  }
}

module cdn 'application.bicep' = {
  scope: envRG
  name: 'application'
  params:{
    location: location
    env: env
    storageAccountName: sa.outputs.storageAccountName
  }
}

