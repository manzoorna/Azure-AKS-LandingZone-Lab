targetScope='resourceGroup'

param location string = resourceGroup().location

param clusterName string

@secure()
param adminPassword string

param allowedSshIp string

module network './network.bicep' = {
  name:'network'

  params:{
    location:location
  }
}

module loganalytics './loganalytics.bicep' = {
  name:'loganalytics'

  params:{
    location:location
  }
}

module acr './acr.bicep' = {
  name:'acr'

  params:{
    location:location
  }
}

module jumpbox './jumpbox.bicep' = {
  name:'jumpbox'

  params:{
    location:location
    managementSubnetId:network.outputs.managementSubnetId
    adminPassword:adminPassword
    allowedSshIp:allowedSshIp
  }
}

module aks './aks.bicep' = {
  name:'aks'

  params:{
    location:location
    clusterName:clusterName
    subnetId:network.outputs.aksSubnetId
    workspaceId:loganalytics.outputs.workspaceId
      }
}
