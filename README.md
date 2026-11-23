# Private Network Service Platform (Phase 1 & Phase 2)

This repository contains the configuration, source code, evidence, and architectural documentation for the Computer Networks Course Project (**Team Nucleus / Team 1**).

---

## Network IP & Service Inventory (Phase 2)

| Machine | Team Member | Current Subnet IP | Phase 1 & 2 Network Roles | Active Services & Ports |
| :--- | :--- | :--- | :--- | :--- |
| **Mac 1** | Akhil | `10.7.31.13` | Primary DNS Server & Client Resolver | `dnsmasq` (Port 53, 30s TTL) |
| **Mac 2** | Akshith | `10.7.11.175` | Active Edge Reverse Proxy & Load Balancer | `nginx` (Ports 443, 8443, 80) with HA Failover |
| **Mac 3** | Mohit | `10.7.11.88` | Backend A + Backup DNS + Security Isolation | Express (Port 3001), `dnsmasq` (Port 53), `pf` Firewall |
| **Mac 4** | Jayadeep | `10.7.9.64` | Backend B + Standby Edge Proxy + Isolation | Express (Port 3002), Standby `nginx` (Port 443), `pf` Firewall |

---

## Deliverables Included

1. **Architecture Documents**:
   - Phase 1 Architecture: [`docs/Architecture_Document.md`](docs/Architecture_Document.md)
   - Phase 2 Hardened Architecture & Topology: [`docs/Architecture_Document_Phase2.md`](docs/Architecture_Document_Phase2.md)
   - Phase 2 Final Report: [`docs/Phase2_Final_Report.md`](docs/Phase2_Final_Report.md)
   - Evaluation Layer-by-Layer Troubleshooting Guide: [`docs/Troubleshooting_Guide_Layer_by_Layer.md`](docs/Troubleshooting_Guide_Layer_by_Layer.md)

2. **Configuration Bundle**:
   - **DNS**: `dns/dnsmasq.conf` (Primary), `dns/backup_dnsmasq.conf` (Backup), `dns/dnsmasq_ttl.conf` (30s TTL)
   - **Reverse Proxy**: `nginx/nginx.conf` (Active HA), `nginx/standby_nginx.conf` (Standby Edge)
   - **Service Isolation (Firewall)**: `firewall/pf_backend_isolation.conf`, `enable_firewall.sh`, `disable_firewall.sh`
   - **Certificates**: `certs/` (local CA generated via mkcert)

3. **Backend Source Code**: 
   - Backend A: `backend-a/serverA.js` (Mohit - Port 3001)
   - Backend B: `backend-b/serverB.js` (Jayadeep - Port 3002)

4. **Evidence Folder (`evidence/`)**:
   - `01-lan/` to `08-failures/`: Complete Phase 1 evidence (Ping mesh, DNS, Backends, TLS, Caching, Wireshark, Failures)
   - `09-dns-failover/`: Extension A (macOS Dual DNS, Backup dnsmasq running, transparent failover)
   - `10-dns-ttl/`: Extension B (30s TTL countdown, DNS cache flushing)
   - `11-firewall-isolation/`: Extension C (PF packet filter rules, direct access blocked, edge access allowed)
   - `12-ha-failover/`: Extension D (Nginx automatic upstream retry, zero 502 errors when Backend A crashes, auto-recovery)
   - `13-edge-migration/`: Extension E (Standby Nginx activation, DNS cutover to Standby Edge)

5. **Automation & Testing Scripts (`scripts/` & `nginx/`)**:
   - `scripts/update_ips.sh`: 1-second automated IP re-mapper across all configurations
   - `scripts/run_phase2_demo.sh`: Interactive CLI demo runner for faculty evaluation
   - `nginx/test_ha_failover.sh`: Automated HA upstream failover test loop
   - `dns/test_dns_failover_ttl.sh`: Automated DNS resolver test script
   - `firewall/test_firewall.sh`: Automated packet filter isolation verification

---

## Service Launch & Evaluation Instructions

### 1. Launch Backends
* **Backend A (Mohit - 10.7.11.88)**:
  ```bash
  cd backend-a && node serverA.js
  ```
* **Backend B (Jayadeep - 10.7.9.64)**:
  ```bash
  cd backend-b && node serverB.js
  ```

### 2. Launch Active Edge Nginx (Akshith - 10.7.11.175)
```bash
sudo nginx -p $(pwd)/ -c nginx/nginx.conf
```

### 3. Launch DNS Services
* **Primary DNS (Akhil - 10.7.31.13)**:
  ```bash
  sudo dnsmasq -C dns/dnsmasq.conf -d
  ```
* **Backup DNS (Mohit - 10.7.11.88)**:
  ```bash
  sudo dnsmasq -C dns/backup_dnsmasq.conf -d
  ```

### 4. Run Interactive Live Evaluation Demo
```bash
./scripts/run_phase2_demo.sh
```
