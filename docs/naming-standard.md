# Azure Naming and Tagging Standard

## Naming Pattern

Resources use the following structure:

`<resource-type>-<organization>-<project>-<environment>-<region>-<instance>`

## Standard Values

| Component | Value |
|---|---|
| Organization | nrg |
| Project | sef |
| Environment | dev |
| Primary region | eus |
| Instance | 001 |

## Planned Resource Names

| Resource | Planned name |
|---|---|
| Resource group | rg-nrg-sef-dev-eus-001 |
| Virtual network | vnet-nrg-sef-dev-eus-001 |
| Management subnet | snet-management |
| Application subnet | snet-application |
| Data subnet | snet-data |
| Management NSG | nsg-management |
| Application NSG | nsg-application |
| Data NSG | nsg-data |
| Log Analytics workspace | log-nrg-sef-dev-eus-001 |
| Key Vault | kv-nrg-sef-dev-unique |
| Storage account | stnrgsefdevunique |
| Virtual machine | vm-nrg-app-dev-001 |
| Recovery Services vault | rsv-nrg-sef-dev-eus-001 |

Globally unique resources such as storage accounts and Key Vault will receive a generated suffix during deployment.

## Required Tags

| Tag | Value |
|---|---|
| Project | SecureAzureEnterpriseFoundation |
| Environment | Development |
| Owner | PortfolioLab |
| ManagedBy | Bicep |
| CostCenter | Portfolio |
| DataClassification | Internal |
| Criticality | Medium |

## Naming Rules

- Use lowercase letters for Azure resource names where supported.
- Use hyphens to separate name components where supported.
- Storage account names use only lowercase letters and numbers.
- Do not place personal information, email addresses, subscription IDs, secrets, or passwords in resource names.
- Resource names must clearly identify their purpose, environment, region, and instance.
