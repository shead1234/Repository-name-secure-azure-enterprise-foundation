# Solution Architecture

## Architecture Summary

Northstar Retail Group's internal inventory application will run inside a segmented Azure virtual network. Administrative access will not require a public IP address on the workload virtual machine. Security, monitoring, governance, and recovery controls will surround the workload.

## Planned Architecture

```mermaid
flowchart TB
    Admin[Cloud Administrator]
    Azure[Azure Subscription]
    Policy[Azure Policy and RBAC]
    RG[Resource Group]

    Bastion[Azure Bastion Developer]
    VNet[Virtual Network: 10.20.0.0/16]
    Management[Management Subnet: 10.20.1.0/24]
    Application[Application Subnet: 10.20.10.0/24]
    Data[Data Subnet: 10.20.20.0/24]

    VM[Private Linux Application VM]
    Identity[System-Assigned Managed Identity]
    KeyVault[Azure Key Vault]
    Storage[Secure Storage Account]
    Logs[Log Analytics Workspace]
    Backup[Recovery Services Vault]

    Admin -->|Azure portal and CLI| Azure
    Azure --> Policy
    Azure --> RG
    Policy --> RG

    RG --> Bastion
    RG --> VNet
    VNet --> Management
    VNet --> Application
    VNet --> Data

    Bastion -->|Browser-based secure administration| VM
    Application --> VM
    VM --> Identity
    Identity -->|RBAC-authorized secret access| KeyVault
    VM --> Storage

    VM --> Logs
    KeyVault --> Logs
    Storage --> Logs
    VM --> Backup
