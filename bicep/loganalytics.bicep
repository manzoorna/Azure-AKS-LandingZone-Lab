param location string

@description('Log Analytics Workspace Name')
param workspaceName string = 'law-${uniqueString(resourceGroup().id)}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location

  sku: {
    name: 'PerGB2018'
  }

  properties: {
    retentionInDays: 30
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
