targetScope = 'resourceGroup'

param environmentTagPolicyDefinitionId string
param allowedLocationsPolicyDefinitionId string
param allowedLocations array

resource requireEnvironmentTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'pa-require-environment-tag'
  properties: {
    displayName: 'Require Environment tag'
    description: 'Enforces the Environment tag on taggable resources in the project resource group.'
    enforcementMode: 'Default'
    policyDefinitionId: environmentTagPolicyDefinitionId
    nonComplianceMessages: [
      {
        message: 'Deployment denied: resources must include the Environment tag.'
      }
    ]
  }
}

resource allowedLocationsAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'pa-allowed-locations'
  properties: {
    displayName: 'Restrict resources to approved Azure regions'
    description: 'Denies resource deployments outside the approved Azure regions.'
    enforcementMode: 'Default'
    policyDefinitionId: allowedLocationsPolicyDefinitionId
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
    nonComplianceMessages: [
      {
        message: 'Deployment denied: the selected Azure region is not approved.'
      }
    ]
  }
}

output policyAssignmentName string = requireEnvironmentTagAssignment.name
output allowedLocationsPolicyAssignmentName string = allowedLocationsAssignment.name
