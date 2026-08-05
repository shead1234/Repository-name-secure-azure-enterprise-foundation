targetScope = 'resourceGroup'

param location string
param tags object

param virtualNetworkName string
param managementNsgName string
param applicationNsgName string
param dataNsgName string

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: managementNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Deny-Public-Management-Ports'
        properties: {
          priority: 100
          access: 'Deny'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource applicationNsg 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: applicationNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-Management-To-Application'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '10.20.1.0/24'
          destinationAddressPrefix: '10.20.10.0/24'
        }
      }
      {
        name: 'Deny-Other-VNet-Inbound'
        properties: {
          priority: 200
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource dataNsg 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: dataNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-Application-To-Data'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.20.10.0/24'
          destinationAddressPrefix: '10.20.20.0/24'
        }
      }
      {
        name: 'Deny-Other-VNet-Inbound'
        properties: {
          priority: 200
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-management'
        properties: {
          addressPrefix: '10.20.1.0/24'
          networkSecurityGroup: {
            id: managementNsg.id
          }
        }
      }
      {
        name: 'snet-application'
        properties: {
          addressPrefix: '10.20.10.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          networkSecurityGroup: {
            id: applicationNsg.id
          }
        }
      }
      {
        name: 'snet-data'
        properties: {
          addressPrefix: '10.20.20.0/24'
          networkSecurityGroup: {
            id: dataNsg.id
          }
        }
      }
    ]
  }
}


output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output applicationSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  virtualNetwork.name,
  'snet-application'
)
