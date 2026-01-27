# Ubuntu VM Template

> Declarative Ubuntu VM template with zsh, shared dotfiles, and S3 backend support

## Quick Start

### Prerequisites

- Terraform >= 1.0
- Proxmox API access
- AWS credentials (if using S3 backend)
- SSH key for VM provisioning

### 1. Create VM

```bash
cd terraform

# Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Proxmox credentials

# Initialize Terraform (configure S3 backend if using)
terraform init

# Create the VM
terraform apply
```

### 2. Destroy VM

```bash
cd terraform
terraform destroy
```

### 3. Fork VM Template

To create a new VM from this template:

1. **Copy the ubuntu directory:**
   ```bash
   cd ../..
   cp -r vms/ubuntu vms/my-new-vm
   ```

2. **Update VM-specific files:**
   - Edit `vms/my-new-vm/cloud-init.yaml` - Change hostname
   - Edit `vms/my-new-vm/terraform/variables.tf` - Update default `vm_id` and `vm_name`
   - Edit `vms/my-new-vm/terraform/main.tf` - Update S3 backend key path if using S3

3. **Configure and deploy:**
   ```bash
   cd vms/my-new-vm/terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars
   terraform init
   terraform apply
   ```

## S3 Backend Setup (Optional but Recommended)

For shared state across multiple machines or CI/CD:

### 1. Create S3 Bucket and DynamoDB Table

```bash
# Create S3 bucket
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Configure AWS Credentials

Set environment variables (or use AWS CLI default profile):

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
# Optional for temporary credentials:
export AWS_SESSION_TOKEN="your-session-token"
```

### 3. Enable S3 Backend in Terraform

**Option A: Edit main.tf directly**

Uncomment and configure the S3 backend block in `terraform/main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "vms/ubuntu/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

**Option B: Use -backend-config flags**

Keep backend commented in main.tf, then:

```bash
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-state-lock"
```

## Features

- **ZSH shell** with starship prompt
- **Shared dotfiles** from `../../dotfiles/` (applied to all VMs)
- **jcuffney user** with sudo NOPASSWD and docker group
- **SSH key access** configured automatically
- **Docker and docker-compose** pre-installed
- **S3 backend** support for shared state

## Configuration

### Required

- Proxmox authentication (token or password) in `terraform.tfvars`
- Proxmox template name (set `vm_template` variable)

### Optional

- S3 backend configuration (see S3 Backend Setup above)
- SSH key path override (`ssh_private_key_path` variable, default: `~/.ssh/id_ed25519`)

## VM Access

After creation, SSH into the VM:

```bash
# Get VM IP from Terraform output
terraform output vm_ip_address

# SSH as jcuffney user
ssh jcuffney@<vm-ip>
```

## Troubleshooting

**VM not accessible via SSH:**
- Wait a few minutes for cloud-init to complete
- Check Proxmox console for boot errors
- Verify SSH key is correct in `cloud-init.yaml`

**Bootstrap script fails:**
- Check VM logs: `journalctl -u cloud-init`
- Verify dotfiles exist in `../../dotfiles/`
- Manually run: `ssh root@<vm-ip> /tmp/bootstrap.sh`

**S3 backend errors:**
- Verify AWS credentials are set
- Check bucket and DynamoDB table exist
- Ensure IAM permissions allow read/write access
