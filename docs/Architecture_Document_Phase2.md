# Architecture Document (Phase 2 Update)

## 1. Machine Roles & IP / Service Table

| Machine | Owner | Primary Role | IP Address | Services & Ports |
| :--- | :--- | :--- | :--- | :--- |
| **Mac 1** | Friend (Akhil) | Primary DNS Server & Client | `10.16.13.239` | `dnsmasq` (UDP/TCP 53) |
| **Mac 2** | Akshith | Active Edge Proxy & Load Balancer | `10.16.13.1` | `nginx` (TCP 443, 8443, 80) |
| **Mac 3** | Mohit | Backend A + Backup DNS Server | `10.16.13.37` | Express (3001), `dnsmasq` (53), `pf` Firewall |
| **Mac 4** | Jayadeep | Backend B + Standby Edge Proxy | `10.16.13.71` | Express (3002), Standby `nginx` (443), `pf` Firewall |

---

## 2. Updated Phase 2 Network Topology Diagram

```mermaid
flowchart TB
    subgraph LAN ["Team Nucleus Hardened Private LAN (10.16.13.0/24)"]
        direction TB

        subgraph DNS_Layer ["DNS High-Availability Layer"]
            PrimaryDNS["Primary DNS (Mac 1)<br>dnsmasq: 10.16.13.239:53<br>(TTL: 30s)"]
            BackupDNS["Backup DNS (Mac 3)<br>dnsmasq: 10.16.13.37:53<br>(Failover Target)"]
        end

        subgraph Edge_Layer ["Edge Reverse Proxy & Migration Layer"]
            ActiveEdge["Active Edge Proxy (Mac 2)<br>Nginx: 10.16.13.1:443<br>HA Upstream + TLS"]
            StandbyEdge["Standby Edge Proxy (Mac 4)<br>Nginx: 10.16.13.71:443<br>(DNS Cutover Ready)"]
        end

        subgraph Backend_Layer ["Isolated Backend Application Layer"]
            FirewallA["macOS PF Firewall<br>Port 3001 Allowed only from 10.16.13.1"]
            BackendA["Backend Server A (Mac 3)<br>Express.js: Port 3001"]
            
            FirewallB["macOS PF Firewall<br>Port 3002 Allowed only from 10.16.13.1"]
            BackendB["Backend Server B (Mac 4)<br>Express.js: Port 3002"]
        end

        Client["Client (Mac 1 / Any Team Mac)"]

        %% Flow arrows
        Client -.->|1. Query app.team1.test| PrimaryDNS
        PrimaryDNS -.->|Fails -> Failover| BackupDNS
        BackupDNS -.->|Returns 10.16.13.1| Client

        Client ==>|2. HTTPS 443| ActiveEdge
        ActiveEdge -.->|Edge Cutover Migration| StandbyEdge

        ActiveEdge -->|3a. Forward via Firewall| FirewallA --> BackendA
        ActiveEdge -->|3b. Forward via Firewall| FirewallB --> BackendB

        Client x-..-x|BLOCKED direct access by PF| FirewallA
        Client x-..-x|BLOCKED direct access by PF| FirewallB
    end
```

---

## 3. High-Availability & Resilience Sequence Flow

```mermaid
sequenceDiagram
    autonumber
    participant Client
    participant PrimaryDNS as Mac 1 (Primary DNS)
    participant BackupDNS as Mac 3 (Backup DNS)
    participant Nginx as Mac 2 (Edge Nginx)
    participant BackendA as Mac 3 (Backend A)
    participant BackendB as Mac 4 (Backend B)

    Note over Client, BackupDNS: Extension A: DNS Failover
    Client->>PrimaryDNS: Query app.team1.test (Primary DNS down)
    PrimaryDNS--xClient: No Response / Timed out
    Client->>BackupDNS: Query app.team1.test (Backup DNS)
    BackupDNS-->>Client: 10.16.13.1 (TTL=30s)

    Note over Client, Nginx: Extension D: Upstream Auto Failover
    Client->>Nginx: HTTPS GET /api/status
    Nginx->>BackendA: Forward to Backend A (Port 3001 is STOPPED)
    BackendA--xNginx: Connection Refused
    Note over Nginx: Detects failure (max_fails=1)<br/>Immediately retries next upstream
    Nginx->>BackendB: Forward to Backend B (Port 3002)
    BackendB-->>Nginx: 200 OK {"backend":"B"} (X-Backend: B)
    Nginx-->>Client: 200 OK (Zero user-visible error!)
```
