# Quick Start Guide - Trunk-Based Deployment

## Overview

This repository uses **trunk-based deployment** where all changes go directly to `main` (or via optional PRs) and require approval before deploying.

## 🚀 Quick Workflow

```
1. Make changes → 2. Push to main → 3. Approve deployment → 4. Deploy
```

## 📋 Deployment Flow

### Direct Commit (Recommended for Trunk-Based)

```bash
# Make changes on main branch
git checkout main
git pull origin main

# Edit environment files
# Example: Edit envs/dev/dev.tfvars

# Commit and push to main
git add envs/dev/dev.tfvars
git commit -m "Update dev environment"
git push origin main

# Go to GitHub Actions → Approve deployment → Done!
```

### Environment Detection

The workflow automatically detects which environment to deploy based on the file path:

| Files Changed | Workflow Triggered | Approval Required |
|---------------|-------------------|-------------------|
| `envs/dev/**` | Deploy to Dev | ✅ Developer (can self-approve) |
| `envs/qa/**` | Deploy to QA | ✅ QA Team |
| `envs/prod/**` | Deploy to Production | ✅ SRE/Platform Team |

## 🔑 Approving Deployments

After pushing to `main`:

1. **Go to GitHub Actions tab**
2. **Find the running workflow** (Deploy to Dev/QA/Prod)
3. **Click on the workflow run**
4. **Click "Review deployments"** button (yellow banner)
5. **Select the environment** checkbox
6. **Click "Approve and deploy"**
7. **Workflow runs** Terraform plan → apply
8. **Done!** Infrastructure is deployed

## 🎯 GitHub Environments Setup

Configure in: **Repository → Settings → Environments**

### Dev Environment
- Name: `dev`
- Reviewers: Any developer (self-approval allowed)
- Branches: `main` only

### QA Environment
- Name: `qa`
- Reviewers: QA Team members
- Branches: `main` only

### Prod Environment
- Name: `prod`
- Reviewers: SRE/Platform Team
- Branches: `main` only
- Optional: Add 30-minute wait timer for safety

## 🔐 Required Secrets

Add these in: **Repository → Settings → Secrets → Actions**

| Secret Name | Description |
|-------------|-------------|
| `ARM_CLIENT_ID` | Azure Service Principal Client ID |
| `AZ_VALUE_NAME` | Azure Service Principal Secret |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |

## 💡 Tips

### ✅ Do This
- Commit directly to `main` for small changes
- Approve your own deployments in dev
- Review Terraform plan output before approving prod
- Keep commits small and focused on one environment

### ❌ Avoid This
- Don't modify multiple environments in one commit (if avoidable)
- Don't approve prod deployments without reviewing the plan
- Don't bypass environment approvals

## 🔄 Using PRs (Optional)

If you prefer code review before merging:

```bash
# Create feature branch
git checkout -b feature-name

# Make changes
# Edit files...

# Commit and push
git commit -am "Description"
git push origin feature-name

# Create PR on GitHub
# Merge after review
# Approve deployment in GitHub Actions
```

## 📊 What Happens When You Deploy?

```
Push to main (envs/prod/prod.tfvars changed)
    ↓
Workflow "Deploy to Production" triggers
    ↓
Waits for approval (SRE Team)
    ↓
✅ Approved
    ↓
Terraform Init
    ↓
Terraform Plan (review changes)
    ↓
Terraform Apply (deploy)
    ↓
✅ Done! Infrastructure updated
```

## 🆘 Troubleshooting

### Workflow not triggering?
- Check that files are under `envs/dev/`, `envs/qa/`, or `envs/prod/`
- Push to `main` branch specifically

### Can't approve deployment?
- Check you're added as a reviewer in GitHub Environment settings
- Dev allows self-approval by default

### Terraform state locked?
- Another deployment is running
- Wait for it to complete or force-unlock if stuck

### Authentication failed?
- Verify all 4 secrets are set correctly in GitHub
- Check Service Principal hasn't expired

## 📚 Full Documentation

See [README.md](README.md) for complete documentation.

---

**Last Updated**: March 7, 2026
