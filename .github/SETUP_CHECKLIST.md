# Repository Setup Checklist

## ✅ Completed Setup

### 1. Rename Template ✅
- ✅ Updated `finpilot` to `cloak-of-dakotaraptor` in:
  - ✅ Containerfile (line 4)
  - ✅ Justfile (line 1)
  - ✅ README.md (title and all references)
  - ✅ artifacthub-repo.yml (line 5)
  - ✅ custom/ujust/README.md (line 175)
  - ✅ .github/workflows/clean.yml (line 23)

### 2. Documentation ✅
- ✅ Updated README.md with:
  - ✅ "What Makes cloak-of-dakotaraptor Different?" section
  - ✅ Clear GitHub Actions enablement instructions
  - ✅ Comprehensive cosign setup guide
  - ✅ Repository-specific deployment instructions
  - ✅ All references updated to joshyorko/cloak-of-dakotaraptor

### 3. Validation ✅
- ✅ All shell scripts pass shellcheck
- ✅ All YAML files are valid
- ✅ GitHub workflows properly configured:
  - ✅ build.yml - Builds on push to main and PRs
  - ✅ clean.yml - Cleans old images weekly
  - ✅ renovate.yml - Auto-updates dependencies every 6 hours
  - ✅ validate-*.yml - PR validation workflows

## 🔧 Required Next Steps

### 1. Enable GitHub Actions ⚠️ REQUIRED

**This is the most critical next step!**

1. Go to the **"Actions"** tab in your repository on GitHub
2. Click **"I understand my workflows, go ahead and enable them"**

Your first build will start automatically after enabling. Without this, the OS cannot be built!

### 2. Wait for First Build

After enabling Actions:
1. Monitor the first build in the Actions tab
2. The build will create the `:stable` tag
3. Build typically takes 10-15 minutes

### 3. Deploy Your OS

Once the first build completes successfully:
```bash
sudo bootc switch --transport registry ghcr.io/joshyorko/cloak-of-dakotaraptor:stable
sudo systemctl reboot
```

## 🔒 Optional: Production Features

### Enable Image Signing (Recommended)

Image signing provides cryptographic verification and is recommended for production use.

#### Generate Keys
```bash
cosign generate-key-pair
```

This creates:
- `cosign.key` (private key) - **Never commit this**
- `cosign.pub` (public key) - Commit to repository

#### Add to GitHub
1. Copy entire contents of `cosign.key`
2. Go to Settings → Secrets and variables → Actions
3. Create new secret named `SIGNING_SECRET`
4. Paste the contents of `cosign.key`

#### Update Repository
1. Replace contents of `cosign.pub` with your public key
2. Edit `.github/workflows/build.yml` and uncomment signing steps (if present)
3. Commit and push

### Enable SBOM (Requires Signing First)

1. Complete image signing setup above
2. Edit `.github/workflows/build.yml`
3. Uncomment SBOM generation steps
4. Commit and push

## 📋 Bootstrap Status Summary

**Repository Name:** cloak-of-dakotaraptor  
**Owner:** joshyorko  
**Base Image:** ghcr.io/ublue-os/silverblue-main:latest  
**Desktop:** GNOME  

**Bootstrap Status:** ✅ Complete (pending GitHub Actions enablement)  
**Workflows:** ✅ Configured  
**Documentation:** ✅ Updated  
**Ready to Build:** ✅ Yes (after enabling Actions)

