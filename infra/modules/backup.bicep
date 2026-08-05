targetScope = 'resourceGroup'

param location string
param tags object
param recoveryServicesVaultName string

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2026-05-01' = {
  name: recoveryServicesVaultName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    redundancySettings: {
      standardTierStorageRedundancy: 'LocallyRedundant'
      crossRegionRestore: 'Disabled'
    }
    securitySettings: {
      softDeleteSettings: {
        softDeleteState: 'AlwaysON'
        enhancedSecurityState: 'AlwaysON'
        softDeleteRetentionPeriodInDays: 14
      }
    }
    restoreSettings: {
      crossSubscriptionRestoreSettings: {
        crossSubscriptionRestoreState: 'Disabled'
      }
    }
  }
}

output recoveryServicesVaultName string = recoveryServicesVault.name
output recoveryServicesVaultId string = recoveryServicesVault.id
