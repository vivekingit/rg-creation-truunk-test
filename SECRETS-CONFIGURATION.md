# GitHub Repository Secrets Configuration

This document lists all the secrets that need to be configured in GitHub for the CI/CD pipelines to work.

## Required Repository Secrets

Navigate to: **Repository → Settings → Secrets and variables → Actions → New repository secret**

Configure the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `ARM_CLIENT_ID` | `96088169-3a97-46f9-b09e-25dc0cdb385c` | Azure Service Principal Application (Client) ID |
| `AZ_VALUE_NAME` | `[Your Secret Value]` | Azure Service Principal Secret Value (Secret ID: 69df57cf-eb7b-4be3-8563-3413ea2e4648) |
| `ARM_SUBSCRIPTION_ID` | `a8faee53-a2b8-4b08-8d44-821fc4f2da68` | Azure Subscription ID |
| `ARM_TENANT_ID` | `895250e2-5aac-4154-afb6-564433d19265` | Azure Directory (Tenant) ID |

## Azure Service Principal Details

For reference, here are the complete Service Principal details:

- **Application (Client) ID**: `96088169-3a97-46f9-b09e-25dc0cdb385c`
- **Directory (Tenant) ID**: `895250e2-5aac-4154-afb6-564433d19265`
- **Secret ID**: `69df57cf-eb7b-4be3-8563-3413ea2e4648`
- **Object ID**: `0495ea96-3b22-4559-b50c-7d0a074392c4`
- **Subscription ID**: `a8faee53-a2b8-4b08-8d44-821fc4f2da68` (from storage account)

## How to Add Secrets

### Via GitHub UI:
1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name (e.g., `ARM_CLIENT_ID`)
5. Enter the secret value
6. Click **Add secret**
7. Repeat for all four secrets

### Via GitHub CLI:
```bash
gh secret set ARM_CLIENT_ID --body "96088169-3a97-46f9-b09e-25dc0cdb385c"
gh secret set AZ_VALUE_NAME --body "YOUR_SECRET_VALUE_HERE"
gh secret set ARM_SUBSCRIPTION_ID --body "a8faee53-a2b8-4b08-8d44-821fc4f2da68"
gh secret set ARM_TENANT_ID --body "895250e2-5aac-4154-afb6-564433d19265"
```

## Service Principal Permissions

Ensure the Service Principal has the following permissions:

1. **Contributor** role on the subscription or resource groups
2. **Storage Blob Data Contributor** role on the Terraform state storage account:
   - Storage Account: `vpterraformstateacc`
   - Resource Group: `rg-terraform-state`

### Verify Permissions:
```bash
# Check role assignments
az role assignment list \
  --assignee 96088169-3a97-46f9-b09e-25dc0cdb385c \
  --output table

# Assign Contributor role (if needed)
az role assignment create \
  --assignee 96088169-3a97-46f9-b09e-25dc0cdb385c \
  --role Contributor \
  --scope /subscriptions/a8faee53-a2b8-4b08-8d44-821fc4f2da68

# Assign Storage Blob Data Contributor (if needed)
az role assignment create \
  --assignee 96088169-3a97-46f9-b09e-25dc0cdb385c \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/a8faee53-a2b8-4b08-8d44-821fc4f2da68/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/vpterraformstateacc
```

## Testing the Configuration

After adding the secrets, you can test by:

1. Creating a test branch
2. Making a small change to `envs/dev/dev.tfvars`
3. Opening a PR
4. Verifying the Terraform plan runs successfully

## Security Notes

- Never commit these values to version control
- Rotate secrets regularly
- Use separate Service Principals for different environments (recommended for production)
- Enable audit logging for all secret access
- Review Service Principal permissions quarterly

## Troubleshooting

### Error: "Authentication failed"
- Verify all four secrets are set correctly in GitHub
- Ensure the secret value for `AZ_VALUE_NAME` is correct
- Check that the Service Principal is not expired

### Error: "Access to storage account denied"
- Verify the Service Principal has Storage Blob Data Contributor role
- Check that the storage account allows the Service Principal's tenant

### Error: "Insufficient permissions"
- Verify the Service Principal has Contributor role on the subscription
- Check resource-level permissions if using resource-scoped Service Principal
