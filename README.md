# Private Network Service Platform (Phase 1)

This repository contains the configuration and source code for the Computer Networks Course Project.

## Deliverables Included

1. **Architecture Document**: Located at [`docs/Architecture_Document.md`](docs/Architecture_Document.md). Includes topology, IP tables, and protocol flow diagrams.
2. **Configuration Bundle**:
   - **DNS**: `dns/dnsmasq.conf`
   - **Reverse Proxy**: `nginx/nginx.conf`
   - **Certificates**: `certs/` (generated via mkcert)
3. **Backend Source Code**: 
   - Backend A: `backend-a/serverA.js`
   - Backend B: `backend-b/serverB.js`
4. **Evidence Folder**: Located in `evidence/`. Contains Wireshark pcaps and terminal screenshots for all tasks (DNS, LAN, TLS, HTTP, Failures).

---

## Configuration Bundle Notes

### 1. TLS Certificate Setup
We used `mkcert` to generate a local CA and self-signed certificates for our domain.
- The certificate is stored in `certs/app.team1.test+1.pem`
- The private key is in `certs/app.team1.test+1-key.pem`
- **To trust the certificate on a client Mac:**
  ```bash
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/app.team1.test+1.pem
  ```
  *(This satisfies the requirement to avoid using the `-k` flag in curl).*

### 2. Backend Launch Instructions
The backends are simple Node.js Express applications.
**To start Backend A (Mac 3 - Mohit):**
```bash
cd backend-a
npm install
node serverA.js
```
*(Runs on port 3001).*

**To start Backend B (Mac 4 - Jayadeep):**
```bash
cd backend-b
npm install
node serverB.js
```
*(Runs on port 3002).*

### 3. Edge Server (Nginx) Launch Instructions
**To start Nginx securely on Mac 2 (Akshith):**
```bash
sudo nginx -p $(pwd)/ -c nginx/nginx.conf
```
*(The `-p $(pwd)/` flag ensures Nginx resolves the relative paths to our certificate directory correctly).*

### 4. DNS Server Launch Instructions
**To start dnsmasq on Mac 1 (Client/DNS):**
```bash
sudo dnsmasq -C dns/dnsmasq.conf -d
```
