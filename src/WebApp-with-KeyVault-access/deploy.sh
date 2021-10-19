az deployment sub create \
  --name sgtest-dev \
  --location uksouth \
  --template-file main.bicep \
  --parameters env=dev \
    location=uksouth \
    sqlServerName=sql-sgtestow-shared-nonprod \
    sharedResourceGroupName=rg-sgtestow-shared-nonprod-francecentral \
    keyVaultName=kv-sgtestow-shared-nonprod
