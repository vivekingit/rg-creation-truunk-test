# Application-X Infrastructure Repository
## Trunk-Based Deployment with Environment-Specific Terraform

This repository implements a **trunk-based branching strategy** for managing infrastructure as code (IaC) across multiple environments using Terraform and GitHub Actions.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Environments](#environments)
- [Workflow Design](#workflow-design)
- [Approval Gates](#approval-gates)
- [One PR = One Environment Rule](#one-pr--one-environment-rule)
- [Getting Started](#getting-started)
- [Making Changes](#making-changes)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This repository manages Azure Resource Groups and associated resources for Application-X across three environments:
- **Dev**: Development environment for rapid iteration
- **QA**: Quality assurance environment for testing
- **Production**: Production environment with enhanced security (includes NSG)

### Key Features
✅ Single source of truth (main branch only)  
✅ Direct commits to main or optional PRs for code review  
✅ Environment-specific approval gates for all deployments  
✅ Automatic environment detection based on changed paths  
✅ Self-approval allowed for development  
✅ Full audit trail of all infrastructure changes    

---

## 📁 Repository Structure

```
rg-creation-truunk-test/
├── .github/
│   ├── workflows/
│   │   ├── pr-validation.yml      # Optional: Enforces single environment per PR
│   │   ├── deploy-dev.yml         # Dev deployment with approval
│   │   ├── deploy-qa.yml          # QA deployment with approval
│   │   └── deploy-prod.yml        # Production deployment with approval
│   └── CODEOWNERS                 # Optional: For PR-based code review
├── envs/
│   ├── dev/
│   │   ├── backend.tf             # Dev state file configuration
│   │   ├── main.tf                # Dev infrastructure definition
│   │   └── dev.tfvars             # Dev-specific variables
│   ├── qa/
│   │   ├── backend.tf             # QA state file configuration
│   │   ├── main.tf                # QA infrastructure definition
│   │   └── qa.tfvars              # QA-specific variables
│   └── prod/
│       ├── backend.tf             # Production state file configuration
│       ├── main.tf                # Production infrastructure with NSG
│       └── prod.tfvars            # Production-specific variables
└── README.md
```

---

## 🌍 Environments

### Development (Dev)
- **Resource Group**: `rg-application-dev`
- **Deployment**: Automatic on merge to main
- **Approvals**: None required
- **Use Case**: Rapid development and testing

### Quality Assurance (QA)
- **Resource Group**: `rg-application-qa`
- **Deployment**: Requires QA team approval after merge
- **Approvals**: QA team must approve
- **Use Case**: Pre-production testing and validation

### Production (Prod)
- **Resource Group**: `rg-application-production`
- **Deployment**: Requires SRE/Platform team approval after merge
- **Approvals**: SRE team must approve (optional wait timer)
- **Additional Resources**: Network Security Group (NSG) for enhanced security
- **Use Case**: Live production workloads

---

## 🔄 Workflow Design

### Trunk-Based Deployment Strategy

This repository uses a **pure trunk-based approach** where all changes are committed directly to `main` (or merged via optional PRs for code review).

### Workflow Steps:

1. **Make Changes**:
   - Engineer makes changes directly to an environment folder (e.g., `envs/prod/`)
   - Changes are committed and pushed to `main` branch
   - _(Optional: Use PRs for code review before merging to main)_

2. **Automatic Environment Detection**:
   - GitHub Actions detects which environment folder was modified
   - Based on the path (`envs/dev/**`, `envs/qa/**`, or `envs/prod/**`), the appropriate workflow triggers

3. **Approval Gate**:
   - Workflow waits for manual approval from designated approvers
   - **Dev**: Requires developer approval (can self-approve)
   - **QA**: Requires QA team approval
   - **Prod**: Requires SRE/Platform team approval

4. **Plan & Apply**:
   - Once approved, Terraform plan executes
   - If plan is successful, Terraform apply runs automatically
   - Infrastructure changes are deployed
   - Output is logged for audit trail

5. **Audit Trail**:
   - All deployments tracked in GitHub Actions logs
   - Main branch history shows all infrastructure changes
   - Environment-specific state files maintain deployment history

---

## 🚦 Approval Gates

### GitHub Environment Configuration

You need to configure GitHub Environments in your repository settings:

1. **Navigate to**: Repository → Settings → Environments

2. **Create three environments**:
   - `dev`
   - `qa`
   - `prod`

3. **Configure environment protection rules**:

#### Dev Environment
```
Name: dev
Deployment branches: main
Required reviewers: 1 (can be self-approved)
Wait timer: 0 minutes
```

#### QA Environment
```
Name: qa
Deployment branches: main
Required reviewers: @qa-team
Wait timer: 0 minutes (optional)
Prevent self-review: Enabled (optional)
```

#### Production Environment
```
Name: prod
Deployment branches: main
Required reviewers: @sre-team, @platform-team
Wait timer: 0-30 minutes (optional - adds safety buffer)
Prevent self-review: Enabled (recommended)
```

---

## ⚠️ One PR = One Environment Rule (Optional)

**Note**: PRs are optional in this trunk-based strategy. You can commit directly to `main`. However, if you choose to use PRs for code review, follow this rule:

### The Problem
If a single PR modifies multiple environments (e.g., both `envs/dev/` and `envs/prod/`), merging will trigger multiple workflows simultaneously, which can lead to:
- Unintended deployments
- Resource conflicts
- Loss of deployment control

### The Solution
The `pr-validation.yml` workflow automatically validates that each PR touches only ONE environment (if you're using PRs).

**Validation Logic**:
```bash
- Scans all changed files in the PR
- Identifies which environment folders are modified
- If more than one environment is detected → PR fails ❌
- If only one environment is detected → PR passes ✅
```

**Example**:
```
✅ ALLOWED: PR changes only envs/dev/main.tf
✅ ALLOWED: PR changes envs/prod/main.tf and envs/prod/prod.tfvars
❌ BLOCKED: PR changes envs/dev/main.tf AND envs/prod/main.tf
```

**If your PR is blocked**: Split your changes into separate PRs for each environment.

---

## 🚀 Getting Started

### Prerequisites
- Azure subscription
- Azure Service Principal with Contributor access
- GitHub repository with Actions enabled
- Terraform 1.6.0 or higher

### Step 1: Configure Azure Backend Storage

Your Terraform state is stored in:
- **Resource Group**: `rg-terraform-state`
- **Storage Account**: `vpterraformstateacc`
- **Container**: `tfstate`

If you need to create a new backend storage:

```bash
# Create resource group for Terraform state
az group create --name rg-terraform-state --location eastus

# Create storage account
az storage account create \
  --name vpterraformstateacc \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

# Create blob container
az storage container create \
  --name tfstate \
  --account-name vpterraformstateacc
```

The backend configuration is already set in each environment's `backend.tf` file.

### Step 2: Configure GitHub Secrets

Add the following secrets to your GitHub repository:
- `ARM_CLIENT_ID`: Azure Service Principal Application ID
- `AZ_VALUE_NAME`: Azure Service Principal Secret
- `ARM_SUBSCRIPTION_ID`: Azure Subscription ID
- `ARM_TENANT_ID`: Azure Tenant ID

**Path**: Repository → Settings → Secrets and variables → Actions → New repository secret

See [SECRETS-CONFIGURATION.md](SECRETS-CONFIGURATION.md) for detailed setup instructions.

### Step 3: Configure GitHub Environments

Follow the [Approval Gates](#approval-gates) section above to configure environments.

### Step 4: Update CODEOWNERS (Optional)

**Note**: CODEOWNERS is only relevant if you're using Pull Requests for code review. In pure trunk-based deployment, approvals are controlled via GitHub Environments (Step 3).

If using PRs, edit `.github/CODEOWNERS` and replace placeholder team names with your actual GitHub teams or usernames.

Example:
```
# Before
/envs/prod/ @sre-team @platform-team

# After
/envs/prod/ @myorg/sre-team @myorg/platform-team
```

### Step 5: Enable Branch Protection (Optional)

**Note**: Branch protection is optional in trunk-based deployment. If you want to enforce PR-based code review before committing to `main`:

1. Go to Repository → Settings → Branches
2. Add branch protection rule for `main`:
   - Require pull request reviews before merging
   - Require review from Code Owners (if using CODEOWNERS)
   - Require status checks to pass (pr-validation workflow)
   - Require branches to be up to date before merging

**For pure trunk-based**: Skip this step and allow direct commits to `main`. Approvals are handled at deployment time via GitHub Environments.

---

## ✏️ Making Changes

### Option 1: Direct Commit to Main (Trunk-Based)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd rg-creation-truunk-test
   ```

2. **Make changes directly on main**:
   ```bash
   git checkout main
   # Edit envs/prod/prod.tfvars
   # Add or modify tags
   ```

3. **Commit and push to main**:
   ```bash
   git add envs/prod/prod.tfvars
   git commit -m "Update production resource group tags"
   git push origin main
   ```

4. **Approve and Deploy**:
   - Go to GitHub → Actions
   - Find the triggered "Deploy to Production" workflow
   - Click "Review deployments"
   - Select the `prod` environment
   - Click "Approve and deploy"
   - Workflow runs Terraform plan then apply

### Option 2: Using Pull Requests (Optional Code Review)

1. **Create a feature branch**:
   ```bash
   git checkout -b update-prod-tags
   ```

2. **Make changes**:
   ```bash
   # Edit envs/prod/prod.tfvars
   ```

3. **Commit and push**:
   ```bash
   git add envs/prod/prod.tfvars
   git commit -m "Update production resource group tags"
   git push origin update-prod-tags
   ```

4. **Open a Pull Request**:
   - Create PR against `main` on GitHub
   - Request reviews from team members (optional)
   - PR validation ensures only one environment is modified

5. **Merge PR**:
   - Once reviewed (if applicable), merge to `main`
   - Workflow triggers automatically

6. **Approve Deployment**:
   - Go to GitHub → Actions
   - Approve the deployment request
   - Infrastructure changes are applied

---

## 🔒 Security Considerations

### Production Security
- Production includes a Network Security Group (NSG) with strict inbound rules
- Only specific IP ranges are allowed (configure in `prod.tfvars`)
- All other traffic is denied by default

### Access Control
- CODEOWNERS enforces mandatory reviews for production changes
- GitHub Environments provide approval gates
- Service Principal has least-privilege access
- Terraform state is stored securely in Azure Storage

### Audit Trail
- All changes are tracked in `main` branch history
- GitHub Actions logs provide deployment audit trail
- Terraform state includes resource history
- PR comments contain plan output for review

---

## 🔧 Troubleshooting

### PR Validation Fails
**Error**: "This PR modifies multiple environments"

**Solution**: Split your PR into separate PRs for each environment.

### Terraform Plan Fails
**Error**: "Backend initialization failed"

**Solution**: 
1. Verify Azure Storage Account exists
2. Check `backend.tf` storage account name is correct
3. Verify Service Principal has access to storage account

### Deployment Stuck on Approval
**Error**: Workflow waiting for environment approval

**Solution**: 
1. Check GitHub → Actions → Select the workflow run
2. Review the approval request
3. Designated approvers must manually approve

### State Lock Error
**Error**: "Error acquiring the state lock"

**Solution**:
1. Check if another deployment is running
2. If stuck, manually release the lock:
   ```bash
   terraform force-unlock <LOCK_ID>
   ```

### NSG Rules Not Applied
**Error**: NSG exists but rules are not working

**Solution**:
1. Verify `allowed_ip_ranges` in `prod.tfvars` are correct
2. Check NSG is associated with a subnet or network interface
3. Review Azure Portal → NSG → Effective security rules

---

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub CODEOWNERS Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)

---

## 🤝 Contributing

1. Always work on feature branches
2. One PR = One environment
3. Include descriptive commit messages
4. Add reviewers based on CODEOWNERS
5. Review Terraform plans carefully before approving

---

## 📝 License

This repository is for internal use only.

---

## 👥 Support

For questions or issues:
- **Development**: Contact @dev-team
- **QA**: Contact @qa-team
- **Production**: Contact @sre-team
- **CI/CD**: Contact @platform-team

---

**Last Updated**: March 2026  
**Maintained By**: Platform Engineering Team
