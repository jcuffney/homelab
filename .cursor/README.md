# Cursor Configuration

This directory contains Cursor IDE configuration files for this homelab project. These files customize Cursor's behavior, AI assistance, and integrations for this specific project.

## Directory Structure

```
.cursor/
├── mcp.json              # MCP (Model Context Protocol) server configuration
├── rules/                # Cursor rules and AI guidance
│   └── homelab-project.mdc  # Project-specific rules and conventions
└── README.md            # This file
```

## Configuration Files

### MCP Configuration (`mcp.json`)

The `mcp.json` file configures Model Context Protocol servers that extend Cursor's capabilities with external tools and services.

**Current Servers:**
- **Asana** - Task management and project tracking
- **GitHub** - Repository management and version control
- **AWS** - Route 53 DNS management, S3, and AWS services
- **Proxmox** - VM management and monitoring (192.168.1.10)
- **OPNsense** - DNS and firewall rule management (192.168.1.1)

**Setup:**

1. Set environment variables in your shell profile (e.g., `~/.zshenv`, `~/.bashrc`):
   ```bash
   # Asana
   export ASANA_ACCESS_TOKEN="your-token-here"
   
   # GitHub
   export GITHUB_PERSONAL_ACCESS_TOKEN="your-token-here"
   
   # AWS
   export AWS_ACCESS_KEY_ID="your-key-here"
   export AWS_SECRET_ACCESS_KEY="your-secret-here"
   export AWS_REGION="us-east-1"
   
   # Proxmox
   export PROXMOX_TOKEN_ID="your-token-id"
   export PROXMOX_TOKEN_SECRET="your-token-secret"
   
   # OPNsense
   export OPNSENSE_API_KEY="your-api-key"
   export OPNSENSE_API_SECRET="your-api-secret"
   ```

2. Restart Cursor to load the MCP configuration.

3. Enable/disable servers by editing `mcp.json`.

**Optional Servers:**

To add optional servers, add them to `mcp.json` and set the corresponding environment variables:

**Plex** - Media server management
```json
"plex": {
  "command": "uvx",
  "args": ["mcp-server-plex"],
  "env": {
    "PLEX_URL": "http://192.168.1.X:32400",
    "PLEX_TOKEN": "${PLEX_TOKEN}"
  }
}
```

**Home Assistant** - Smart home control
```json
"home-assistant": {
  "command": "uvx",
  "args": ["mcp-server-home-assistant"],
  "env": {
    "HOME_ASSISTANT_URL": "http://192.168.1.X:8123",
    "HOME_ASSISTANT_TOKEN": "${HOME_ASSISTANT_TOKEN}"
  }
}
```

**n8n** - Workflow automation
```json
"n8n": {
  "command": "npx",
  "args": ["-y", "@n8n/mcp-server"],
  "env": {
    "N8N_API_URL": "${N8N_API_URL}",
    "N8N_API_KEY": "${N8N_API_KEY}"
  }
}
```

**Kubernetes/k3s** - Cluster management
```json
"kubernetes": {
  "command": "uvx",
  "args": ["mcp-server-kubernetes"],
  "env": {
    "KUBECONFIG": "${KUBECONFIG:-~/.kube/config}"
  }
}
```

See `docs/mcp.md` for detailed setup instructions for each server.

### Rules Configuration (`rules/`)

The `rules/` directory contains Cursor rules files (`.mdc` format) that provide AI guidance and project conventions.

**Current Rules:**
- `homelab-project.mdc` - Core project rules, conventions, and infrastructure guidelines

Rules files help the AI assistant understand:
- Project structure and conventions
- Infrastructure details (Proxmox, OPNsense, networking)
- Security guidelines
- Code style and best practices
- Common tasks and workflows

**Adding New Rules:**

1. Create a new `.mdc` file in the `rules/` directory
2. Use the frontmatter format:
   ```markdown
   ---
   description: Brief description of the rule
   alwaysApply: true  # or false for conditional application
   ---
   
   # Rule Title
   
   Rule content...
   ```
3. Rules are automatically loaded by Cursor

**Rule Types:**
- **Project rules** - General project conventions and structure
- **File-specific rules** - Patterns for specific file types
- **Task-specific rules** - Guidelines for specific workflows

## Security Notes

- Configuration files use environment variables for all secrets, making them safe to commit to git
- Never commit actual API keys or tokens
- Store secrets in environment variables or a secure secret manager
- Update `.gitignore` if you need to store local overrides

## Troubleshooting

### MCP Servers
- **MCP servers not loading**: Check that environment variables are set and Cursor has been restarted
- **Connection errors**: Verify API endpoints and credentials are correct
- **Missing tools**: Ensure the MCP server package is installed (npx/uvx will auto-install on first use)

### Rules
- **Rules not applying**: Verify the `.mdc` file syntax is correct and Cursor has been restarted
- **Conflicting rules**: Check for duplicate or conflicting rule definitions

## References

- [MCP Documentation](https://modelcontextprotocol.io/)
- [Cursor MCP Setup Guide](https://docs.cursor.com/mcp)
- [Cursor Rules Documentation](https://docs.cursor.com/rules)
- Project MCP documentation: `docs/mcp.md`
- Project rules: `.cursorrules` (root-level rules file)
