targetScope = 'resourceGroup'

param location string
param tags object
param logAnalyticsWorkspaceName string
param storageAccountName string
param keyVaultName string

@secure()
param alertEmail string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource storageBlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-storage-blob-to-law'
  scope: blobService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Capacity'
        enabled: true
      }
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-keyvault-to-law'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource securityActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-nrg-sef-dev-001'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'nrgsefalert'
    enabled: true
    emailReceivers: [
      {
        name: 'portfolio-owner'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource keyVaultFailedRequestsAlert 'Microsoft.Insights/scheduledQueryRules@2026-03-01' = {
  name: 'alert-keyvault-failed-requests'
  location: location
  tags: tags
  properties: {
    displayName: 'Key Vault failed requests'
    description: 'Detects failed Key Vault requests and notifies the security action group.'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    scopes: [
      logAnalyticsWorkspace.id
    ]
    autoMitigate: true
    checkWorkspaceAlertsStorageConfigured: false
    skipQueryValidation: false
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          query: $'''
AZKVAuditLogs
| where _ResourceId =~ '${keyVault.id}'
| where HttpStatusCode >= 300
| where not(OperationName == "Authentication" and HttpStatusCode == 401)
'''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        securityActionGroup.id
      ]
    }
  }
}

output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output actionGroupName string = securityActionGroup.name
output keyVaultAlertName string = keyVaultFailedRequestsAlert.name
