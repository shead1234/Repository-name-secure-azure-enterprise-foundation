targetScope = 'subscription'

param location string
param allowedLocations array
param resourceGroupName string
param tags object

param virtualNetworkName string
param managementNsgName string
param applicationNsgName string
param dataNsgName string

param vmName string
param nicName string
param vmSize string
param adminUsername string

@secure()
param adminPublicKey string

param logAnalyticsWorkspaceName string
param recoveryServicesVaultName string

@secure()
param alertEmail string

@description('Name of the monthly project budget.')
param budgetName string

@description('Monthly budget amount in USD.')
@minValue(1)
param budgetAmount int = 20

@description('First day of the budget period.')
param budgetStartDate string

@description('End date of the budget period.')
param budgetEndDate string

resource projectResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module governance 'modules/governance.bicep' = {
  name: 'governanceDeployment'
  params: {
    resourceGroupName: resourceGroupName
    allowedLocations: allowedLocations
  }
  dependsOn: [
    projectResourceGroup
  ]
}

module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  scope: projectResourceGroup
  params: {
    location: location
    tags: tags
    virtualNetworkName: virtualNetworkName
    managementNsgName: managementNsgName
    applicationNsgName: applicationNsgName
    dataNsgName: dataNsgName
  }
}

module compute 'modules/compute.bicep' = {
  name: 'computeDeployment'
  scope: projectResourceGroup
  params: {
    location: location
    tags: tags
    vmName: vmName
    nicName: nicName
    vmSize: vmSize
    adminUsername: adminUsername
    adminPublicKey: adminPublicKey
    applicationSubnetId: network.outputs.applicationSubnetId
  }
}

module services 'modules/services.bicep' = {
  name: 'servicesDeployment'
  scope: projectResourceGroup
  params: {
    location: location
    tags: tags
    applicationSubnetId: network.outputs.applicationSubnetId
    vmPrincipalId: compute.outputs.managedIdentityPrincipalId
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringDeployment'
  scope: projectResourceGroup
  params: {
    location: location
    tags: tags
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: services.outputs.storageAccountName
    keyVaultName: services.outputs.keyVaultName
    alertEmail: alertEmail
  }
}

module backup 'modules/backup.bicep' = {
  name: 'backupDeployment'
  scope: projectResourceGroup
  params: {
    location: location
    tags: tags
    recoveryServicesVaultName: recoveryServicesVaultName
  }
}

module costManagement './modules/cost-management.bicep' = {
  name: 'deploy-cost-management'
  params: {
    budgetName: budgetName
    budgetAmount: budgetAmount
    budgetStartDate: budgetStartDate
    budgetEndDate: budgetEndDate
    contactEmail: alertEmail
    resourceGroupName: resourceGroupName
  }
}

output deployedResourceGroupName string = projectResourceGroup.name
output deployedVirtualNetworkName string = network.outputs.virtualNetworkName

output deployedVirtualMachineName string = compute.outputs.virtualMachineName
output virtualMachinePrivateIp string = compute.outputs.privateIpAddress

output deployedStorageAccountName string = services.outputs.storageAccountName
output deployedKeyVaultName string = services.outputs.keyVaultName
output deployedBlobContainerName string = services.outputs.blobContainerName

output deployedLogAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsWorkspaceName
output deployedLogAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
output deployedActionGroupName string = monitoring.outputs.actionGroupName
output deployedKeyVaultAlertName string = monitoring.outputs.keyVaultAlertName

output deployedPolicyDefinitionName string = governance.outputs.policyDefinitionName
output deployedPolicyAssignmentName string = governance.outputs.policyAssignmentName
output deployedAllowedLocationsPolicyAssignmentName string = governance.outputs.allowedLocationsPolicyAssignmentName

output deployedRecoveryServicesVaultName string = backup.outputs.recoveryServicesVaultName
output deployedRecoveryServicesVaultId string = backup.outputs.recoveryServicesVaultId

output costBudgetName string = costManagement.outputs.budgetName
output costBudgetResourceId string = costManagement.outputs.budgetResourceId
