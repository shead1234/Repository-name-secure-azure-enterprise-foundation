# Screenshot Evidence Log

| ID | File | Evidence demonstrated | Sensitive information check |
|---|---|---|---|
| 01 | 01-bicep-resource-group-deployment.png | Successful subscription-scope Bicep deployment of the standardized resource group | No subscription ID or account information visible |
| 02 | 02-resource-group-tags.png | Seven governance, ownership, classification, and cost-management tags applied to the resource group | Account and subscription information excluded |
| 03 | 03-resource-group-budget.png | Monthly resource-group budget with 50%, 80%, and 100% cost alerts | Alert-recipient email excluded |

## Evidence Handling Rules

- Screenshots must show the control or deployment result being tested.
- Email addresses, subscription IDs, tenant IDs, secrets, and billing information must not appear.
- Public screenshots are stored in evidence/screenshots.
- Screenshots are reviewed before being committed to Git.
