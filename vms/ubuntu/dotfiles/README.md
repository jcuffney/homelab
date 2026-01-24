# Ubuntu VM Dotfiles

This directory contains dotfiles specific to the Ubuntu VM.

## Files

- `bashrc` - Bash configuration for interactive shells with custom prompt
- `bash_aliases` - Common bash aliases
- `profile` - Profile configuration for login shells

## Usage

These dotfiles are automatically injected into the VM via Terraform. The `terraform/main.tf` reads these files and includes them in the cloud-init configuration for both root and jcuffney users.

## Custom Prompt

The `.bashrc` includes a custom prompt format:
```
user@hostname <file path> <if git directory - on branch_name>
```

The prompt automatically shows the current git branch when inside a git repository.

## Customization

To customize these dotfiles for this VM, simply edit the files in this directory. The changes will be applied the next time you run `terraform apply`.
