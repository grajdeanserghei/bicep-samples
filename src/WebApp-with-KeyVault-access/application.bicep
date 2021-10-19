// Simple example to deploy Azure infrastructure for app + data + managed identity + monitoring

param env string

param sqlServerName string

param databaseName string

param sharedResourceGroupName string

@secure()
param dbLogin string = 'sss'

@secure()
param dbPassword string = 'sss'

param tenantId string

var keyVaultName = 'kv-sgowtest-2'

// Region for all resources
param location string = resourceGroup().location

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
var appInsightsName = 'appi-sgtestow-${env}-${location}-001'

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

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties:{
    sku:{
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enabledForTemplateDeployment: true
    accessPolicies:[
    ]
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${kv.name}/add'
  properties: {
      accessPolicies: [
          {
              tenantId: tenantId
              objectId: webSite.identity.principalId
              permissions: {
                keys: [
                  'get'
                ]
                secrets: [
                  'list'
                  'get'
                ]
              }
          }
      ]
  }
}



resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${webSite.name}/connectionstrings'
  properties: {
    DefaultConnection: {
      value: '@Microsoft.KeyVault(SecretUri=${keyVaultName}.vault.azure.net/secrets/aiConnectionString)'
      type: 'SQLAzure'
    }
  }
}

// Managed Identity resources
/*
resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}*/

/*
resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleDefinitionId, resourceGroup().id)

  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: msi.properties.principalId
  }
}*/

// Monitor
resource appInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: appInsightsName
  location: location
  tags: {
    'hidden-link:${webSite.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}


output webSiteName string = webSiteName
output webSiteDefaultHostName string = webSite.properties.defaultHostName
