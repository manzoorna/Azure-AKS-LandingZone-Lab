param location string
param managementSubnetId string

@secure()
param adminPassword string

param adminUsername string = 'azureuser'
param vmName string = 'jumpbox'
param allowedSshIp string

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: '${vmName}-pip'
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${vmName}-nsg'
  location: location

  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: allowedSshIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: '${vmName}-nic'
  location: location

  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }

    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          subnet: {
            id: managementSubnetId
          }

          publicIPAddress: {
            id: publicIP.id
          }

          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location

  properties: {

    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output jumpboxIp string = publicIP.properties.ipAddress
