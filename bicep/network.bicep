param location string

@description('Virtual Network Name')
param vnetName string = 'vnet-aks'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {

  name: vnetName

  location: location

  properties: {

    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

  }

}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {

  parent: vnet

  name: 'aks-subnet'

  properties: {
    addressPrefix: '10.0.1.0/24'
  }

}

resource managementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {

  parent: vnet

  name: 'management-subnet'

  properties: {
    addressPrefix: '10.0.2.0/24'
  }

}

output aksSubnetId string = aksSubnet.id

output managementSubnetId string = managementSubnet.id

output vnetId string = vnet.id

output vnetName string = vnet.name
