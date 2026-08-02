# Project Charter

## Project Title

Secure Azure Enterprise Foundation: Governed Infrastructure Deployment with Bicep and CI/CD

## Fictional Organization

Northstar Retail Group

## Business Scenario

Northstar Retail Group is migrating an internal inventory and order-management application to Microsoft Azure. The organization needs a standardized and repeatable cloud environment that protects administrative access, separates workloads, limits unnecessary permissions, centralizes monitoring, and supports recovery.

## Project Objective

Design, deploy, secure, monitor, and test an Azure application environment using infrastructure as code and documented security controls.

## Primary Region

East US

## Environment

Development / Portfolio Lab

## Business Requirements

1. Infrastructure must be deployable repeatedly through Bicep.
2. Resources must follow a consistent naming and tagging standard.
3. Network traffic must be separated across management, application, and data subnets.
4. RDP and SSH must not be exposed directly to the public internet.
5. Storage public access must be restricted.
6. Secrets must be stored in Azure Key Vault.
7. Applications must use managed identities instead of hard-coded credentials.
8. Administrative access must follow least privilege using Azure RBAC.
9. Resource activity and security logs must be centrally collected.
10. Governance controls must detect or deny noncompliant resources.
11. Important resources must have backup and recovery protection.
12. Costs must be monitored and kept within the student subscription budget.

## Acceptance Criteria

- Bicep deployment completes successfully.
- Re-running the deployment does not create unnecessary duplicate resources.
- Required tags appear on deployed resources.
- An unapproved region deployment is denied.
- Public storage access is disabled.
- No public inbound RDP or SSH rule exists.
- A managed identity retrieves an authorized secret without embedded credentials.
- Unauthorized access attempts are denied.
- Logs arrive in Log Analytics.
- Monitoring alerts can be triggered and verified.
- A backup or recovery test completes successfully.
- The environment can be removed through a documented cleanup process.

## Portfolio Skills Demonstrated

- Azure administration
- Azure networking
- Microsoft Entra ID and Azure RBAC
- Infrastructure as code with Bicep
- Azure Policy and governance
- Storage and secrets security
- Managed identities
- Azure Monitor and Log Analytics
- Backup and recovery
- Git and CI/CD
- Security testing and technical documentation
