az deployment sub create \
  --name sgtest-dev \
  --location uksouth \
  --template-file main.bicep \
  --parameters env=dev \
    location=uksouth \
    sharedResourceGroupName=rg-sgtestow-shared-nonprod-francecentral \
    keyVaultName=kv-sgtestow-shared-nonprod
