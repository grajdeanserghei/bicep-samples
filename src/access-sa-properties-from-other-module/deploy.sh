az deployment sub create \
  --name sg-know-how \
  --location uksouth \
  --template-file main.bicep \
  --parameters env=dev \
    location=uksouth 
