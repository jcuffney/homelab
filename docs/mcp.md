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

The current configuration includes: Asana, GitHub, AWS, Proxmox, and OPNsense MCP servers. Additional servers can be added by editing `mcp.json` - see `.cursor/README.md` for configuration examples.

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

## AI & LLM Services

- [ ] **OpenWebUI** - Web UI for LLMs with native MCP support
  - **Native MCP Support:** OpenWebUI has built-in MCP support starting in version 0.6.31
  - **Documentation:** [OpenWebUI MCP Support](https://docs.openwebui.com/features/mcp)
  - **Key Features:**
    - **MCP Client** - Connect to external MCP servers via streamable HTTP interface
    - **mcpo Proxy** - MCP-to-OpenAPI proxy server for cloud deployments
    - **Authentication Options** - None, Bearer token, or OAuth 2.1
    - **Tool Integration** - Use MCP tools directly in OpenWebUI chat interface
  - **Useful for:**
    - Connecting OpenWebUI to other MCP servers (Proxmox, OPNsense, AWS, etc.)
    - Using infrastructure management tools from within OpenWebUI
    - Extending OpenWebUI capabilities with external tools
  - **Setup:**
    1. Go to **⚙️ Admin Settings → External Tools**
    2. Click **+ (Add Server)**
    3. Set **Type** to **MCP (Streamable HTTP)**
    4. Enter Server URL and authentication details
    5. Save and restart if prompted
  - **Integration:** Works with Ollama running on GPU VM (port 11434)
  - **Note:** Set `WEBUI_SECRET_KEY` environment variable for OAuth-connected MCP tools

- [ ] **Ollama** - Local LLM runtime (already running on GPU VM)
  - **Current Setup:** Running on GPU VM via Docker, exposes API on port 11434
  - **MCP Integration:** Ollama can work with MCP servers through OpenWebUI or direct MCP clients
  - **Useful for:**
    - Running local LLM models with GPU acceleration
    - Providing LLM API for OpenWebUI and other services
    - Integrating with MCP servers for enhanced AI capabilities
  - **Integration:** 
    - OpenWebUI connects to Ollama API
    - MCP servers can be accessed through OpenWebUI
    - Can use MCP clients with Ollama for direct integration
  - **Note:** Ollama itself doesn't have an MCP server, but works with MCP through clients like OpenWebUI

## Media Services

- [ ] **Plex** - Media server with MCP support (already running on GPU VM)
  - **Current Setup:** Running on GPU VM via Docker, exposes web UI on port 32400
  - **Available MCP Servers:**
    - [UBOS Plex MCP Server](https://ubos.tech/mcp/plex-mcp-server/overview/) - Comprehensive Plex integration
    - [vyb1ng/plex-mcp](https://github.com/vyb1ng/plex-mcp) - Python-based implementation
    - [jmagar/plex-mcp](https://github.com/jmagar/plex-mcp) - Alternative implementation
    - [vladimir-tutin/plex-mcp-server](https://github.com/vladimir-tutin/plex-mcp-server) - Additional option
  - **Key Capabilities:**
    - **Intelligent Media Search** - Natural language queries to find content by title, actor, genre, or plot
    - **Library Browsing** - Search movies, TV shows, episodes, and music across Plex libraries
    - **Playlist Management** - Create and curate playlists with AI assistance
    - **Playback Control** - Control Plex playback and manage clients
    - **Personalized Recommendations** - Analyze viewing history for tailored suggestions
    - **Server Information** - Retrieve server info and monitor active sessions
    - **Recently Added** - Get recently added items from libraries
  - **Useful for:**
    - Finding media content via natural language ("find action movies from the 90s")
    - Managing playlists and collections
    - Controlling playback from AI assistants
    - Getting personalized recommendations
    - Monitoring Plex server status and active sessions
  - **Authentication:** Requires Plex API token (obtained from Plex account settings)
  - **Setup:** Configure with Plex server URL and API token
  - **Integration:** Works with OpenWebUI, Claude Desktop, and other MCP clients

## Smart Home & IoT

- [ ] **Home Assistant** - Smart home automation with native MCP support
  - **Planned Setup:** Running as LXC container (per docs/README.md)
  - **Native MCP Integrations:** Home Assistant has built-in MCP support (two complementary integrations)
  - **Documentation:** 
    - [MCP Client Integration](https://www.home-assistant.io/integrations/mcp/) - Use external MCP servers in Home Assistant
    - [MCP Server Integration](https://www.home-assistant.io/integrations/mcp_server/) - Expose Home Assistant as MCP server
  - **MCP Server Integration (Home Assistant → AI Clients):**
    - **Purpose:** Exposes Home Assistant as an MCP server to AI applications
    - **Capabilities:**
      - Control Home Assistant devices from Claude Desktop, Cursor, gemini-cli
      - Access through Home Assistant Assist API
      - Granular entity exposure controls (configure which devices clients can access)
      - Manage smart home devices via natural language
    - **Useful for:** "turn on the living room lights", "set thermostat to 72", "show me all sensors"
  - **MCP Client Integration (External MCP Servers → Home Assistant):**
    - **Purpose:** Allows Home Assistant to use external MCP servers as tools
    - **Capabilities:**
      - Connect third-party MCP servers (memory, web search, etc.)
      - Enhance Home Assistant's conversation agents
      - Provide additional tools for LLM-based voice assistants
      - Integration with conversation agents (Anthropic, Google Generative AI, Ollama)
    - **Useful for:** Adding web search, memory, or other capabilities to Home Assistant assistants
  - **Community MCP Server:**
    - [allenporter/mcp-server-home-assistant](https://github.com/allenporter/mcp-server-home-assistant) - Community implementation (archived)
    - [ha-mcp](https://github.com/homeassistant-ai/ha-mcp) - Home Assistant AI MCP server
  - **REST API:**
    - Home Assistant REST API available on port 8123
    - Bearer token authentication via `Authorization` header
    - JSON request/response format
    - Can be used for automation and control
  - **Configuration:**
    - Both integrations configured via Settings → Devices & Services
    - Client integration requires SSE server URL
    - Server integration controls device exposure to MCP clients
  - **Useful for:**
    - Controlling smart home devices from AI assistants
    - Integrating Home Assistant with other MCP servers (Proxmox, OPNsense, etc.)
    - Creating AI-powered home automation workflows
    - Voice control via Home Assistant's conversation agents
  - **Integration:** Can work with n8n MCP for automated home automation workflows

## Workflow Automation

- [ ] **n8n** - Workflow automation with MCP server support
  - **n8n MCP Server:** [n8n MCP Server](https://model-context-protocol.com/servers/n8n-api-ai-workflow-automation-server)
  - **Documentation:** [n8n MCP Access Guide](https://docs.n8n.io/advanced-ai/accessing-n8n-mcp-server/)
  - **Key Capabilities:**
    - **Workflow Management** - List, create, update, delete n8n workflows via natural language
    - **Workflow Execution** - Activate, deactivate, and execute workflows
    - **Status Monitoring** - Monitor workflow execution status and statistics
    - **Workflow Search** - Search within workflows marked as available for MCP
    - **Metadata Access** - Retrieve workflow metadata and trigger information
    - **MCP Client Tool Node** - Consume tools from external MCP servers within n8n workflows
  - **Useful for:**
    - Managing n8n workflows via AI assistant
    - Automating homelab tasks (VM management, DNS updates, etc.)
    - Integrating n8n with other MCP servers (Proxmox, OPNsense, AWS)
    - Creating AI-powered automation workflows
  - **Authentication:**
    - **OAuth2** - For enterprise deployments
    - **Access Token** - API key-based authentication
  - **Setup:**
    1. Install n8n (Node.js 18+ required)
    2. Configure API access in n8n settings
    3. Set environment variables: `N8N_API_URL` and `N8N_API_KEY`
    4. Enable workflows for MCP access (individual workflow setting)
    5. Install n8n MCP server and configure connection
  - **Integration:** 
    - Can trigger workflows from AI assistants
    - Can consume MCP tools from other servers within workflows
    - Works with Proxmox, OPNsense, AWS, and other MCP servers
  - **Note:** Workflow authoring remains in n8n UI, not in AI clients. Each workflow must be individually enabled for MCP access.

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
6. **Home Assistant MCP** - Smart home control and automation (highly recommended if using Home Assistant)
7. **OpenWebUI MCP Integration** - Connect OpenWebUI to other MCP servers (highly recommended if using OpenWebUI)
8. **n8n MCP** - Workflow automation and management (highly recommended if using n8n)
9. **Plex MCP** - Media server management (highly recommended if using Plex)
10. **Kubernetes/k3s MCP** - If running k3s clusters on VMs (highly recommended if using k3s)
11. **Terraform Cloud** - If using remote state
12. **Docker** - Container management on VMs
13. **1Password** - Secret management

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
- **OpenWebUI MCP Integration:** OpenWebUI can connect to multiple MCP servers, allowing you to use infrastructure tools (Proxmox, OPNsense, AWS) directly from the OpenWebUI chat interface
- **n8n MCP:** n8n provides both an MCP server (for AI assistants to manage workflows) and MCP client capabilities (to use other MCP servers within workflows), creating powerful automation possibilities
- **Ollama Integration:** Ollama (running on GPU VM) works with MCP through OpenWebUI or direct MCP clients, enabling local LLM models to use infrastructure management tools
- **Home Assistant MCP:** Home Assistant has native dual MCP support - it can act as both an MCP server (exposing devices to AI) and an MCP client (using external MCP tools), enabling powerful smart home automation
- **Plex MCP:** Plex MCP servers enable natural language media search and control, making it easy to find and manage your media library through AI assistants
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
   - **Package name**: `awslabs.aws-api-mcp-server`
   - **Installation**: Use `uvx awslabs.aws-api-mcp-server@latest` (requires Python 3.10+ and `uv` package manager)
   - **Alternative**: Follow [AWS MCP Server documentation](https://docs.aws.amazon.com/aws-mcp/latest/userguide/what-is-mcp-server.html)
   - Or use the managed remote server option
3. **Configure credentials:**
   - Set AWS credentials via environment variables, `~/.aws/credentials` file (recommended), or IAM role
   - Configure MCP server with AWS region (e.g., `us-east-1`)
   - The server will automatically use `~/.aws/credentials` if environment variables are not set
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

### OpenWebUI MCP Setup
1. **Prerequisites:**
   - OpenWebUI installed and running (version 0.6.31+)
   - Access to Admin Settings
2. **Connect to MCP Servers:**
   - Navigate to **⚙️ Admin Settings → External Tools**
   - Click **+ (Add Server)**
   - Set **Type** to **MCP (Streamable HTTP)** (not OpenAPI)
   - Enter MCP server URL (e.g., `http://localhost:8000` for local servers)
   - Configure authentication:
     - **None** - For local/internal network servers
     - **Bearer** - For servers requiring API tokens
     - **OAuth 2.1** - For enterprise deployments
   - Save and restart if prompted
3. **For Docker deployments:**
   - Use `http://host.docker.internal:<port>` to connect to host machine MCP servers
4. **Set environment variable (for OAuth):**
   - Set `WEBUI_SECRET_KEY` for OAuth-connected MCP tools to persist correctly
5. **Use cases:**
   - Connect OpenWebUI to Proxmox MCP for VM management
   - Connect to OPNsense MCP for DNS/firewall management
   - Connect to AWS MCP for Route 53 DNS management
   - Use infrastructure tools directly from OpenWebUI chat interface
6. **mcpo Proxy (optional):**
   - For cloud deployments, use mcpo to convert MCP servers to OpenAPI
   - Run: `uvx mcpo --port 8000 -- your_mcp_server_command`
   - mcpo wraps MCP tools with secure HTTP endpoints

### n8n MCP Setup
1. **Prerequisites:**
   - n8n installed and running (Node.js 18+)
   - API access enabled in n8n settings
2. **Configure n8n API:**
   - Generate API key in n8n: Settings → API
   - Note the API URL (e.g., `http://localhost:5678` or your n8n instance URL)
3. **Install n8n MCP Server:**
   - Install via npm or your preferred package manager
   - Set environment variables:
     - `N8N_API_URL` - Your n8n instance URL
     - `N8N_API_KEY` - Your n8n API key
4. **Enable workflows for MCP:**
   - In n8n UI, open each workflow you want to expose
   - Enable "Available for MCP" option (individual workflow setting)
   - Only enabled workflows are accessible via MCP
5. **Configure MCP client connection:**
   - Connect AI assistant (Claude Desktop, Cursor, etc.) to n8n MCP server
   - Test connection: "list all n8n workflows"
6. **Use MCP Client Tool Node in workflows:**
   - Add "MCP Client Tool" node to n8n workflows
   - Connect to external MCP servers (Proxmox, OPNsense, AWS, etc.)
   - Use MCP tools within n8n workflows for automation
7. **Use cases for homelab:**
   - Automate VM provisioning via Proxmox MCP
   - Automate DNS updates via OPNsense or AWS MCP
   - Create workflows that respond to infrastructure events
   - Integrate multiple MCP servers in single workflows
   - AI-powered automation triggered by natural language

### Plex MCP Setup
1. **Prerequisites:**
   - Plex Media Server running (already on GPU VM, port 32400)
   - Plex account with server access
2. **Get Plex API Token:**
   - Log into Plex web interface
   - Go to Settings → Network → Show Advanced
   - Or use: `https://plex.tv/api/v2/pins` to generate token
   - Token is required for API authentication
3. **Choose MCP Server Implementation:**
   - **UBOS Plex MCP Server** (recommended) - Comprehensive features
   - **vyb1ng/plex-mcp** - Python-based, well-maintained
   - **jmagar/plex-mcp** - Alternative option
4. **Install and Configure:**
   - Install chosen MCP server
   - Configure with:
     - Plex server URL (e.g., `http://192.168.1.X:32400` or `http://plex.cuffney.com:32400`)
     - Plex API token
     - Optional: Library filters, result limits
5. **Test connection:**
   - Query libraries: "list all Plex libraries"
   - Search content: "find action movies from the 90s"
   - Check server status: "show me Plex server information"
6. **Use cases for homelab:**
   - Natural language media search ("find sci-fi movies with space battles")
   - Create playlists via AI assistant
   - Control playback from OpenWebUI or other MCP clients
   - Get personalized recommendations based on viewing history
   - Monitor active Plex sessions and server status

### Home Assistant MCP Setup
1. **Prerequisites:**
   - Home Assistant installed and running (planned as LXC container)
   - Home Assistant accessible (typically port 8123)
   - Long-lived access token generated
2. **Generate Access Token:**
   - In Home Assistant: Profile → Long-Lived Access Tokens
   - Create new token
   - Copy token (shown only once)
3. **Configure MCP Server Integration (Expose Home Assistant to AI):**
   - Navigate to: Settings → Devices & Services → Add Integration
   - Search for "Model Context Protocol Server"
   - Configure which entities to expose to MCP clients
   - Set access controls (read-only vs full control)
   - Save configuration
4. **Configure MCP Client Integration (Use External MCP Servers in Home Assistant):**
   - Navigate to: Settings → Devices & Services → Add Integration
   - Search for "Model Context Protocol"
   - Enter SSE Server URL for external MCP server
   - Configure OAuth if required
   - Connect to MCP servers (memory, web search, etc.)
5. **Connect AI Assistant to Home Assistant MCP:**
   - Configure Claude Desktop, Cursor, or other MCP client
   - Connect to Home Assistant MCP server endpoint
   - Test: "list all Home Assistant devices", "turn on living room lights"
6. **Alternative: Community MCP Server:**
   - Use [ha-mcp](https://github.com/homeassistant-ai/ha-mcp) for additional features
   - Or [allenporter/mcp-server-home-assistant](https://github.com/allenporter/mcp-server-home-assistant) (archived)
7. **Use cases for homelab:**
   - Control smart home devices from AI assistants ("turn on the lights", "set temperature to 72")
   - Integrate Home Assistant with n8n workflows via MCP
   - Use Home Assistant data in OpenWebUI conversations
   - Create AI-powered automation rules
   - Voice control via Home Assistant conversation agents with MCP tools
   - Connect Home Assistant to other MCP servers (Proxmox, OPNsense) for unified control