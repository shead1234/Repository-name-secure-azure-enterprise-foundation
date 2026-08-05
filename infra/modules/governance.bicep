targetScope = 'subscription'

param resourceGroupName string

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

module environmentTagAssignment 'governance-assignment.bicep' = {
  name: 'environmentTagPolicyAssignment'
  scope: resourceGroup(resourceGroupName)
  params: {
    policyDefinitionId: requireEnvironmentTagPolicy.id
  }
}

output policyDefinitionName string = requireEnvironmentTagPolicy.name
output policyAssignmentName string = environmentTagAssignment.outputs.policyAssignmentName
