# Security Validation Report

## Secure Azure Enterprise Foundation

**Validation date:** August 5, 2026
**Environment:** Development
**Region:** East US
**Deployment method:** Azure Bicep

## Executive Summary

The Secure Azure Enterprise Foundation was deployed and validated through configuration reviews, negative security tests, end-to-end identity testing, centralized log verification, live alert testing, and a controlled backup restore drill.

All temporary validation resources were removed after testing. The production virtual machine remains deallocated to minimize cost.

## Validation Results

| Control | Result | Evidence |
|---|---|---|
| Bicep compilation | PASS | Final Bicep build completed successfully |
| Repeat deployment | PASS | Identical Bicep configuration redeployed successfully |
| Final What-If safety review | PASS | No Create or Delete operations detected |
| Monthly budget | PASS | $20 monthly budget deployed |
| Budget notifications | PASS | 80% actual-cost and 100% forecasted-cost alerts enabled |
| Required Environment tag | PASS | Untagged resource denied by Azure Policy |
| Compliant tagged resource | PASS | Tagged resource deployed and removed successfully |
| Allowed Azure locations | PASS | West US 2 denied; East US allowed |
| VM public exposure | PASS | No VM public IP or public IP resource |
| Subnet segmentation | PASS | Management, application, and data subnets use separate NSGs |
| Broad inbound internet access | PASS | No broad inbound Allow rules detected |
| Storage HTTPS enforcement | PASS | HTTPS-only and TLS 1.2 enabled |
| Storage anonymous access | PASS | Anonymous blob access disabled |
| Storage Shared Key access | PASS | Shared Key authorization disabled |
| Storage firewall | PASS | Default Deny with no public IP rules |
| Storage network path | PASS | Access restricted to application subnet through service endpoint |
| Key Vault authorization | PASS | Azure RBAC enabled |
| Key Vault recovery protection | PASS | Soft delete and purge protection enabled |
| Key Vault firewall | PASS | Default Deny with application-subnet access only |
| Managed identity RBAC | PASS | Storage Blob Data Contributor and Key Vault Secrets User assigned |
| Passwordless Key Vault access | PASS | VM managed identity received HTTP 200 |
| Passwordless Storage write | PASS | Temporary blob created with OAuth |
| Passwordless Storage read | PASS | Downloaded data matched uploaded data |
| Passwordless Storage cleanup | PASS | Temporary blob deleted successfully |
| Unauthorized public access | PASS | Key Vault returned 401 and Storage returned 403 |
| Key Vault diagnostic logging | PASS | Authorized VM SecretList event recorded |
| Storage diagnostic logging | PASS | OAuth PutBlob, GetBlob, and DeleteBlob events recorded |
| Action group | PASS | Enabled email receiver using Common Alert Schema |
| Scheduled-query alert | PASS | Enabled Sev2 Key Vault failed-request alert |
| Alert query interpolation | PASS | Deployed query contains the actual Key Vault resource ID |
| Live alert trigger | PASS | Failed Key Vault request generated |
| Live alert evaluation | PASS | Alert instance entered Fired state |
| Alert action execution | PASS | Action was not suppressed and email notification was delivered |
| VM backup protection | PASS | Protection state Healthy and latest backup Completed |
| Recovery points | PASS | Two recovery points available |
| Live restore drill | PASS | OS disk restored from the latest recovery point |
| Restored disk integrity | PASS | Healthy 30 GB Linux OS disk created as an unattached copy |
| Restore cleanup | PASS | Temporary restore resource group and resources deleted |
| Cost control after testing | PASS | Production VM confirmed deallocated |

## Key Technical Evidence

### Managed Identity

The application VM accessed Azure Key Vault and Azure Blob Storage without passwords, Storage account keys, connection strings, or SAS tokens.

The VM used:

- **Key Vault Secrets User** at the Key Vault scope
- **Storage Blob Data Contributor** at the Storage account scope

### Network Security

The VM has only a private IP address and is located in the application subnet.

Storage and Key Vault use:

- Default firewall action of `Deny`
- No allowed public IP ranges
- An approved application-subnet rule
- Azure service endpoints
- Microsoft Entra authorization

### Monitoring and Detection

Diagnostic settings send Key Vault and Storage logs to Log Analytics.

A scheduled-query alert detects failed Key Vault requests:

- Severity: `Sev2`
- Evaluation frequency: 15 minutes
- Query window: 15 minutes
- Threshold: greater than zero
- Notification: Azure Monitor action group email

The live validation produced a matching event and an Azure alert with:

- Monitor condition: `Fired`
- Alert state: `New`
- Severity: `Sev2`
- Action suppressed: `False`

### Backup and Recovery

Azure Backup successfully restored the latest VM recovery point into an isolated temporary resource group.

The restored OS disk:

- Provisioning state: `Succeeded`
- Disk state: `Unattached`
- OS: Linux
- Size: 30 GB
- Creation method: Restore

The restore-test resource group was deleted after validation.

## What-If Notes

The final Azure What-If operation reported:

- Ignore: 1
- Modify: 13
- NoChange: 8
- Unsupported: 2
- Create: 0
- Delete: 0

The remaining Modify and Unsupported classifications are known Azure What-If limitations involving provider-added defaults, array comparisons, generated VM resources, and managed-identity-dependent role-assignment names.

No resources would be newly created or deleted.

## Final Status

**Overall validation result: PASS**

The environment demonstrates secure Infrastructure as Code, Azure governance, segmented networking, least-privilege identity, protected PaaS services, centralized monitoring, automated alerting, cost governance, backup protection, and tested disaster recovery.
