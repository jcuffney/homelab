# MCP Servers

This document tracks MCP (Model Context Protocol) servers that are useful for managing and working with this homelab infrastructure project.

## Task & Project Management

- [x] **Asana** - Task management and project tracking
  - Useful for: Tracking infrastructure changes, VM deployments, network configuration tasks
  - Integration: Link tasks to GitHub PRs/issues, document infrastructure changes

## Version Control & Code

- [x] **GitHub** - Repository management and version control
  - Useful for: Managing Terraform configs, documentation, dotfiles, scripts
  - Integration: Link to Asana tasks, track infrastructure changes via commits

## Infrastructure as Code

- [ ] **Terraform Cloud/Enterprise** - Terraform state management and remote execution
  - Useful for: Remote state management, team collaboration, state locking
  - Alternative: Use local state with S3 backend (via AWS MCP)

## Cloud Services & DNS

- [ ] **AWS** - AWS services management via official AWS MCP Server
  - **Official AWS MCP Server:** [AWS MCP Server](https://awslabs.github.io/mcp/) - Managed remote MCP server from AWS
  - **Documentation:** [AWS MCP User Guide](https://docs.aws.amazon.com/aws-mcp/latest/userguide/what-is-mcp-server.html)
  - **Key Capabilities:**
    - **Route 53 DNS management** - Create, update, delete DNS records for `cuffney.com` domain
    - **S3 management** - Store Terraform state in S3, manage buckets and objects
    - **Real-time AWS knowledge** - Search AWS documentation, API references, and best practices
    - **Authenticated API calls** - Make AWS API calls using IAM roles and policies
    - **Multi-step workflows** - Execute AWS workflows using pre-built Agent SOPs
    - **Troubleshooting** - Analyze CloudWatch logs and CloudTrail events
    - **Infrastructure provisioning** - Provision VPCs, databases, compute instances
    - **Cost management** - Billing analysis and alerts
  - **Useful for:** 
    - Managing DNS records (cuffney.com) via Route 53
    - Storing Terraform state in S3 backend
    - DNS-01 challenge for Let's Encrypt certificates
    - AWS infrastructure management and troubleshooting
  - **Authentication:** Uses standard AWS IAM controls (IAM roles, access keys)
  - **Audit Logging:** All actions logged through CloudTrail
  - **Setup:** Requires AWS credentials (access key/secret or IAM role) with appropriate permissions

## Infrastructure Management

- [ ] **Proxmox** - Proxmox VE API access via MCP
  - **Available MCP Servers:**
    - [UBOS Proxmox Manager](https://ubos.tech/mcp/proxmox-mcp-server/) - Python-based with Proxmoxer, secure token auth
    - [gilby125/mcp-proxmox](https://github.com/gilby125/mcp-proxmox) - Node.js with configurable permissions
    - [husniadil/proxmox-mcp-server](https://github.com/husniadil/proxmox-mcp-server) - SSH-based LXC container management
    - [kspr9/mcp-proxmox-extended](https://github.com/kspr9/mcp-proxmox-extended) - Extended VM/CT control operations
  - **Useful for:** Querying VM status, storage info, cluster health, VM lifecycle management (start/stop/reboot)
  - **Integration:** Works with Proxmox API at `https://192.168.1.10:8006/api2/json`
  - **Authentication:** API tokens (recommended) or username/password
  - **Setup:** Requires Proxmox API credentials (host, token ID, token secret)

- [ ] **OPNsense** - Router/firewall management via MCP
  - **Available MCP Servers:**
    - [floriangrousset/opnsense-mcp-server](https://github.com/floriangrousset/opnsense-mcp-server) - Python-based, full API integration
    - [OPNSenseMCP](https://dxt.services/mcp/OPNSenseMCP/) - TypeScript implementation with Infrastructure as Code focus
  - **Useful for:** DNS override management, firewall rule management, VLAN configuration, ARP table management, WireGuard VPN management, HAProxy configuration
  - **Integration:** Works with OPNsense API at `https://192.168.1.1/api/`
  - **Authentication:** API key/secret pairs (created via OPNsense user manager)
  - **Features:** Full OPNsense API integration, Infrastructure as Code, configuration backup/restore, state management with rollback
  - **Setup:** Requires OPNsense API key/secret with appropriate ACL permissions

## Monitoring & Observability

- [ ] **Prometheus** - Metrics collection and querying
  - Useful for: VM metrics, network stats, service health monitoring
  - Integration: Query metrics for infrastructure health checks

- [ ] **Grafana** - Visualization and dashboards
  - Useful for: Creating infrastructure dashboards, visualizing metrics
  - Integration: Query Prometheus data, create homelab status dashboards

## Container Management

- [ ] **Docker** - Container management and image operations
  - Useful for: Managing containers on VMs, checking container status
  - Integration: Query running containers, manage docker-compose services

## Container Orchestration

- [ ] **Kubernetes / k3s** - Kubernetes cluster management via MCP
  - **Note:** k3s is fully Kubernetes-compatible, so any Kubernetes MCP server works with k3s
  - **Available MCP Servers:**
    - [Stacklok MKP](https://docs.stacklok.com/toolhive/guides-mcp/k8s) - Native Go implementation with direct Kubernetes API integration
      - Built-in rate limiting, supports all resource types including CRDs
      - Network isolation capabilities
    - [Red Hat Kubernetes MCP Server](https://github.com/containers/kubernetes-mcp-server) - Open-source with 1k+ stars
      - Supports Kubernetes and OpenShift
      - Full CRUD operations on generic Kubernetes resources
    - [Docker Kubernetes MCP Server](https://hub.docker.com/mcp/server/kubernetes/overview) - Containerized with 22+ tools
      - Easy deployment via Docker
      - Comprehensive kubectl command support
    - [Azure mcp-kubernetes](https://pkg.go.dev/github.com/Azure/mcp-kubernetes) - Azure's Kubernetes MCP implementation
  - **Key Capabilities:**
    - **Cluster analysis** - Identify problematic pods (CrashLoopBackOff, ImagePullBackOff, OOMKilled)
    - **Resource management** - List, get, apply, delete Kubernetes resources
    - **Pod operations** - Execute commands, retrieve logs and events, monitor resources
    - **CRUD operations** - Full create, read, update, delete for all resource types including CRDs
    - **Remediation planning** - Intelligent troubleshooting and diagnostics
    - **Approval-based workflows** - Secure infrastructure changes with user approval
  - **Useful for:**
    - Managing k3s clusters running on VMs
    - Deploying and managing applications
    - Troubleshooting pod issues
    - Monitoring cluster health
    - Managing namespaces, deployments, services, ingress
  - **Security Features:**
    - Configurable access modes: read-only, non-destructive, or full control
    - Support for least-privilege ServiceAccounts and RBAC
    - Network isolation to restrict access to cluster endpoints only
  - **Deployment Options:**
    - **Local (stdio)** - Single admin access with local kubeconfig
    - **In-cluster (Streamable HTTP or SSE)** - Team-based access
    - **Docker/Container** - Run as containerized service with kubeconfig mounting
  - **Setup:** Requires kubeconfig file (mount `.kube` directory or specific kubeconfig)
  - **Default Mode:** Read-only (write operations require `--read-write=true` configuration)

## Documentation & Knowledge

- [ ] **Obsidian** - Knowledge base and documentation
  - Useful for: Maintaining homelab documentation, linking related concepts
  - Integration: Link to GitHub repos, Asana tasks, infrastructure diagrams

- [ ] **Notion** - Documentation and wiki
  - Useful for: Comprehensive homelab documentation, runbooks
  - Integration: Embed diagrams, link to GitHub, track changes

## Security & Secrets

- [ ] **1Password** - Password and secret management
  - Useful for: Managing Proxmox credentials, API tokens, SSH keys
  - Integration: Retrieve secrets for Terraform, API calls

- [ ] **Vault (HashiCorp)** - Secret management (if running in homelab)
  - Useful for: Centralized secret management for infrastructure
  - Integration: Terraform provider, API token management

## Network & DNS

- [ ] **Cloudflare** - DNS and CDN (if using Cloudflare instead of Route 53)
  - Useful for: DNS record management, SSL/TLS certificates
  - Alternative: AWS Route 53 MCP

## Development Tools

- [ ] **Slack** - Team communication (if working with others)
  - Useful for: Infrastructure alerts, deployment notifications
  - Integration: GitHub webhooks, monitoring alerts

## Recommended Priority

### High Priority (Core Workflow)
1. **Asana** - Task management
2. **GitHub** - Version control
3. **AWS** - Route 53 DNS management (for cuffney.com domain)

### Medium Priority (Infrastructure Management)
4. **Proxmox MCP** - Direct VM management and monitoring (highly recommended for homelab)
5. **OPNsense MCP** - DNS and firewall rule management (highly recommended for homelab)
6. **Kubernetes/k3s MCP** - If running k3s clusters on VMs (highly recommended if using k3s)
7. **Terraform Cloud** - If using remote state
8. **Docker** - Container management on VMs
9. **1Password** - Secret management

### Low Priority (Nice to Have)
7. **Prometheus/Grafana** - If running monitoring stack
8. **Obsidian/Notion** - Enhanced documentation
9. **Slack** - If using for notifications

## Notes

- **Proxmox and OPNsense MCPs are available!** Multiple implementations exist - choose based on your preferred language (Python vs Node.js) and feature needs
- **Proxmox MCP** enables natural language VM management (e.g., "show me all running VMs", "start the ubuntu-vm")
- **OPNsense MCP** enables natural language firewall/DNS management (e.g., "add a DNS override for rivendell", "show me firewall rules")
- **Kubernetes/k3s MCP** enables natural language cluster management (e.g., "list all pods", "show me pods with errors", "deploy nginx to production namespace")
- **k3s compatibility:** k3s is fully Kubernetes-compatible, so any Kubernetes MCP server works seamlessly with k3s clusters
- Focus on MCPs that integrate with your existing workflow (Asana + GitHub)
- Consider MCPs that help with infrastructure automation (Terraform, AWS, Docker)
- Security-focused MCPs (1Password, Vault) are valuable for managing credentials securely
- Both Proxmox and OPNsense MCPs require API credentials - store securely (1Password MCP can help retrieve them)

## Setup Guides

### Proxmox MCP Setup
1. Create API token in Proxmox: Datacenter → Permissions → API Tokens
2. Grant appropriate permissions (e.g., `VM.Audit`, `VM.Monitor`, `VM.PowerMgmt`)
3. Install chosen MCP server (Python or Node.js)
4. Configure with Proxmox host (`192.168.1.10`), token ID, and token secret
5. Test connection and verify VM querying works

### OPNsense MCP Setup
1. Create API key in OPNsense: System → Access → Users → [User] → API Keys
2. Download key file (single-use credential)
3. Configure appropriate ACL permissions for DNS, Firewall, etc.
4. Install chosen MCP server (Python or TypeScript)
5. Configure with OPNsense host (`192.168.1.1`), API key, and secret
6. Test connection and verify DNS/firewall querying works

### AWS MCP Setup
1. **Choose authentication method:**
   - **IAM User with Access Keys** (recommended for local development)
     - Create IAM user in AWS Console
     - Generate access key/secret key pair
     - Attach policies: `AmazonRoute53FullAccess`, `AmazonS3FullAccess` (or more restrictive as needed)
   - **IAM Role** (for EC2/ECS deployments)
     - Create IAM role with appropriate policies
     - Attach role to instance/service
2. **Install AWS MCP Server:**
   - Follow [AWS MCP Server documentation](https://docs.aws.amazon.com/aws-mcp/latest/userguide/what-is-mcp-server.html)
   - Or use the managed remote server option
3. **Configure credentials:**
   - Set AWS credentials via environment variables, AWS credentials file, or IAM role
   - Configure MCP server with AWS region (e.g., `us-east-1`)
4. **Test connection:**
   - Query Route 53 hosted zones for `cuffney.com`
   - List S3 buckets (if using for Terraform state)
   - Verify DNS record management works
5. **Use cases for homelab:**
   - Manage Route 53 DNS records (e.g., `*.cuffney.com` → public IP)
   - Store Terraform state in S3 bucket
   - DNS-01 challenge automation for Let's Encrypt certificates
   - Query AWS documentation and best practices

### Kubernetes/k3s MCP Setup
1. **Prerequisites:**
   - k3s or Kubernetes cluster running (on VM or bare metal)
   - `kubectl` configured and working with your cluster
   - kubeconfig file accessible (typically `~/.kube/config`)
2. **Choose MCP server implementation:**
   - **Stacklok MKP** (recommended) - Go-based, native Kubernetes API
   - **Red Hat Kubernetes MCP** - Python-based, well-maintained
   - **Docker Kubernetes MCP** - Easy containerized deployment
3. **Configure access:**
   - **Local deployment:** Mount kubeconfig file or `.kube` directory
   - **In-cluster deployment:** Deploy as pod with ServiceAccount and RBAC
   - **Docker deployment:** Mount kubeconfig as volume
4. **Set access mode:**
   - **Read-only (default):** Safe for querying and monitoring
   - **Non-destructive:** Can read and create, but not modify/delete
   - **Full control:** Requires `--read-write=true` flag
5. **Configure RBAC (if deploying in-cluster):**
   - Create ServiceAccount with appropriate permissions
   - Grant minimal required permissions (e.g., `get`, `list` for read-only)
   - Use ClusterRole/ClusterRoleBinding or Role/RoleBinding as needed
6. **Test connection:**
   - Query cluster nodes: "list all nodes in the cluster"
   - List pods: "show me all pods in default namespace"
   - Check pod status: "find pods with CrashLoopBackOff status"
7. **Use cases for homelab:**
   - Manage k3s clusters running on VMs
   - Deploy applications via natural language
   - Troubleshoot pod issues automatically
   - Monitor cluster health and resource usage
   - Manage ingress, services, and deployments
   - Query logs and events for debugging