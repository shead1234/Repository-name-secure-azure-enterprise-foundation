targetScope = 'subscription'

@description('Azure region for the project resource group.')
param location string

@description('Name of the project resource group.')
param resourceGroupName string

@description('Required governance and ownership tags.')
param tags object

resource projectResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output deployedResourceGroupName string = projectResourceGroup.name
output deployedResourceGroupLocation string = projectResourceGroup.location
