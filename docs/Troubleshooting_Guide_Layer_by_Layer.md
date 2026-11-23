# Layer-by-Layer Troubleshooting Guide (Extension F)

During the Phase 2 evaluation, the faculty will introduce an intentional fault into the live network. Use this systematic layer-by-layer methodology to identify, isolate, and fix the issue.

```
       [ Client Request: https://app.team1.test ]
                          │
  Step 1: Check DNS       ▼   (Layer 7 over Layer 4 UDP 53)
  -------------------------------------------------------------
  Command: dig app.team1.test
  Expected: Returns Mac 2 Edge IP (10.16.13.1)
  If Fails:
    • Check /etc/resolv.conf or macOS DNS settings
    • Is dnsmasq running? (`sudo lsof -i :53` or `ps aux | grep dnsmasq`)
    • Did it return wrong IP? Check `dns/dnsmasq.conf` address mapping.
    • Test backup DNS resolver: `dig @10.16.13.37 app.team1.test`

                          │
  Step 2: Check Network   ▼   (Layer 3 IP & Layer 4 TCP)
  -------------------------------------------------------------
  Command: ping -c 2 10.16.13.1 && nc -zv 10.16.13.1 443
  Expected: Ping responds, port 443 OPEN.
  If Fails:
    • Ping fails: Mac 2 Wi-Fi disconnected or wrong subnet.
    • Ping succeeds but port 443 closed:
        - Nginx is stopped: `sudo nginx -p $(pwd)/ -c nginx/nginx.conf`
        - Wrong port: Client connecting to wrong port (e.g. 80 vs 443).
        - Packet filter blocking: `sudo pfctl -d`.

                          │
  Step 3: Check TLS       ▼   (Layer 5/6 Session/Presentation)
  -------------------------------------------------------------
  Command: openssl s_client -connect app.team1.test:443 -servername app.team1.test
  Expected: Verification: OK, Handshake: TLSv1.3, Cert Subject: app.team1.test
  If Fails:
    • Self-signed error / Unknown CA:
        - Client missing trusted root certificate:
          `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/app.team1.test+1.pem`
    • Certificate expired or domain mismatch:
        - Check certificate SAN: `openssl x509 -in certs/app.team1.test+1.pem -text -noout`

                          │
  Step 4: Check App/Proxy ▼   (Layer 7 Application HTTP)
  -------------------------------------------------------------
  Command: curl -i https://app.team1.test/api/status
  Expected: HTTP 200 OK with `{"backend":"A","status":"ok"}` and `X-Backend` header.
  If Fails:
    • 502 Bad Gateway:
        - Both backends are down or unreachable by Nginx.
        - Check backend processes on Mac 3 (port 3001) and Mac 4 (port 3002).
        - Check firewall rules on backends blocking Mac 2 IP (`pfctl -s rules`).
        - Inspect Nginx error log: `tail -n 20 /tmp/cn_project_error.log`.
    • 504 Gateway Timeout:
        - Backend hung or packet dropped by firewall without TCP RST.
    • 404 Not Found:
        - Requested wrong path or incorrect `location` block in `nginx.conf`.
```

---

### Quick Diagnostic Commands Reference

| Check | Tool / Command | Normal Output |
| :--- | :--- | :--- |
| **DNS Resolution** | `dig app.team1.test +short` | `10.16.13.1` |
| **DNS Port Check** | `nc -zuv 10.16.13.239 53` | `Connection to 10.16.13.239 port 53 [udp/domain] succeeded!` |
| **TCP Port 443** | `nc -zv 10.16.13.1 443` | `Connection to 10.16.13.1 port 443 [tcp/https] succeeded!` |
| **TLS Handshake** | `openssl s_client -connect app.team1.test:443 -brief` | `CONNECTION ESTABLISHED ... Verification: OK` |
| **HTTP Headers** | `curl -sI https://app.team1.test/api/status` | `HTTP/1.1 200 OK ... X-Backend: A/B` |
| **Backend Direct Reach** | `nc -zv 10.16.13.37 3001` | Connection allowed from Mac 2, blocked from client |
