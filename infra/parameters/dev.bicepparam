using '../main.bicep'

param location = 'eastus'
param resourceGroupName = 'rg-nrg-sef-dev-eus-001'

param virtualNetworkName = 'vnet-nrg-sef-dev-eus-001'
param managementNsgName = 'nsg-management'
param applicationNsgName = 'nsg-application'
param dataNsgName = 'nsg-data'

param vmName = 'vm-nrg-app-dev-001'
param nicName = 'nic-nrg-app-dev-001'
param vmSize = 'Standard_F1as_v7'
param adminUsername = 'azureadmin'
param adminPublicKey = readEnvironmentVariable('SSH_PUBLIC_KEY')

param logAnalyticsWorkspaceName = 'log-nrg-sef-dev-eus-001'
param alertEmail = readEnvironmentVariable('ALERT_EMAIL')
param recoveryServicesVaultName = 'rsv-nrg-sef-dev-eus-001'

param tags = {
  Project: 'SecureAzureEnterpriseFoundation'
  Environment: 'Development'
  Owner: 'PortfolioLab'
  ManagedBy: 'Bicep'
  CostCenter: 'Portfolio'
  DataClassification: 'Internal'
  Criticality: 'Medium'
}
