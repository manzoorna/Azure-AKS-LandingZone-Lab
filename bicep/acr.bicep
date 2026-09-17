param location string

param acrName string = 'akslab${uniqueString(resourceGroup().id)}'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {

  name: acrName

  location: location

  sku: {
    name: 'Basic'
  }

  properties: {
    adminUserEnabled: true
  }

}

output acrId string = acr.id

output loginServer string = acr.properties.loginServer
