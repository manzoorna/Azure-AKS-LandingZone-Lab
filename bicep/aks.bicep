@description('Azure Region')
param location string

@description('AKS Cluster Name')
param clusterName string

@description('AKS Subnet Resource ID')
param subnetId string

@description('Log Analytics Workspace Resource ID')
param workspaceId string

@description('Number of AKS Nodes')
param nodeCount int = 1

@description('AKS Node VM Size')
param vmSize string = 'Standard_B2s'

resource aks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location

  identity: {
    type: 'SystemAssigned'
  }

  sku: {
    name: 'Base'
    tier: 'Free'
  }

  properties: {

    kubernetesVersion: ''

    dnsPrefix: clusterName

    enableRBAC: true

    apiServerAccessProfile: {
      enablePrivateCluster: true
    }

    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'

      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.10'
    }

    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
    }

    agentPoolProfiles: [
      {
        name: 'system'
        mode: 'System'
        count: nodeCount
        vmSize: vmSize

        osType: 'Linux'
        osDiskSizeGB: 30

        type: 'VirtualMachineScaleSets'

        vnetSubnetID: subnetId
      }
    ]
  }
}
