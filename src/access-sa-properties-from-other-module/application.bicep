// Simple example to deploy Azure infrastructure for app + data + managed identity + monitoring

param env string

// Region for all resources
param location string = resourceGroup().location

param storageAccountName string

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

// Variables
var hostingPlanName = 'plan-sgtestow-${env}-${location}-001'
var webSiteName = 'app-sgtestow-site-${env}-${location}-001'

// Web App resources
resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
}

resource webSite 'Microsoft.Web/sites@2020-12-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig:{
      netFrameworkVersion: 'v5.0'
    }
  }
  identity: {
    type:'SystemAssigned'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
}

resource webSiteConnectionConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${webSite.name}/web'
  properties: {
    storageAccountKey: storageAccount.listKeys().keys[0].value
  }
}


output webSiteName string = webSiteName
output webSiteDefaultHostName string = webSite.properties.defaultHostName
