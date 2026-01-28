# MCP Servers

This document tracks MCP (Model Context Protocol) servers that are useful for managing and working with this homelab infrastructure project.

## Project MCP Configuration

The project MCP configuration is located at `.cursor/mcp.json`. This file contains the active MCP server configurations for Cursor IDE.

- **Configuration file**: `.cursor/mcp.json` - Active MCP servers (uses environment variables for secrets)
- **Setup guide**: `.cursor/README.md` - Instructions for configuring MCP servers

To set up MCP servers:
1. Configure environment variables (see `.cursor/README.md`)
2. Edit `.cursor/mcp.json` to enable/disable servers
3. Restart Cursor to load the configuration

The current configuration includes: Asana and GitHub MCP servers.

## Task & Project Management

- [x] **Asana** - Task management and project tracking
  - Useful for: Tracking infrastructure changes, VM deployments, network configuration tasks
  - Integration: Link tasks to GitHub PRs/issues, document infrastructure changes

## Version Control & Code

- [x] **GitHub** - Repository management and version control
  - Useful for: Managing Terraform configs, documentation, dotfiles, scripts
  - Integration: Link to Asana tasks, track infrastructure changes via commits
