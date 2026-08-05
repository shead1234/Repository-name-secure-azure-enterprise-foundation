targetScope = 'resourceGroup'

param policyDefinitionId string

resource requireEnvironmentTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'pa-require-environment-tag'
  properties: {
    displayName: 'Require Environment tag'
    description: 'Enforces the Environment tag on taggable resources in the project resource group.'
    enforcementMode: 'Default'
    policyDefinitionId: policyDefinitionId
    nonComplianceMessages: [
      {
        message: 'Deployment denied: resources must include the Environment tag.'
      }
    ]
  }
}

output policyAssignmentName string = requireEnvironmentTagAssignment.name
