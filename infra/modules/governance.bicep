targetScope = 'subscription'

param resourceGroupName string
param allowedLocations array

var allowedLocationsPolicyDefinitionId = tenantResourceId(
  'Microsoft.Authorization/policyDefinitions',
  'e56962a6-4747-49cd-b67b-bf8b01975c4c'
)

resource requireEnvironmentTagPolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'deny-missing-environment-tag'
  properties: {
    displayName: 'Deny resources missing the Environment tag'
    description: 'Blocks new or updated taggable resources that do not contain the required Environment tag.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
      version: '1.0.0'
      project: 'Secure Azure Enterprise Foundation'
    }
    policyRule: {
      if: {
        field: 'tags[Environment]'
        exists: 'false'
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

module governanceAssignments 'governance-assignment.bicep' = {
  name: 'governancePolicyAssignments'
  scope: resourceGroup(resourceGroupName)
  params: {
    environmentTagPolicyDefinitionId: requireEnvironmentTagPolicy.id
    allowedLocationsPolicyDefinitionId: allowedLocationsPolicyDefinitionId
    allowedLocations: allowedLocations
  }
}

output policyDefinitionName string = requireEnvironmentTagPolicy.name
output policyAssignmentName string = governanceAssignments.outputs.policyAssignmentName
output allowedLocationsPolicyAssignmentName string = governanceAssignments.outputs.allowedLocationsPolicyAssignmentName
