using '../main.bicep'

param location = 'eastus'

param resourceGroupName = 'rg-nrg-sef-dev-eus-001'

param tags = {
  Project: 'SecureAzureEnterpriseFoundation'
  Environment: 'Development'
  Owner: 'PortfolioLab'
  ManagedBy: 'Bicep'
  CostCenter: 'Portfolio'
  DataClassification: 'Internal'
  Criticality: 'Medium'
}
