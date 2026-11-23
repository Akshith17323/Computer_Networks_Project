# Phase 2 Final Report: Harden, Recover & Troubleshoot

**Course**: Computer Networks Course Project  
**Team Name**: Nucleus (Team 1)  
**Domain**: `app.team1.test`  
**Review Stage**: Phase 2 Final Review (50 Marks)  

---

## 1. Executive Summary & Changes from Phase 1
In Phase 1, the core network infrastructure was constructed from scratch: a private LAN, a dedicated DNS resolver (`dnsmasq`), TLS termination over HTTPS (`mkcert`), and dual backend load balancing via Nginx.

In Phase 2, the system was hardened against single points of failure, unauthenticated network access, and operational outages. Specifically:
1. **Resilience**: A secondary DNS resolver was added to ensure name resolution survives primary DNS outages.
2. **Security & Isolation**: Host-level packet filtering (`pf`) was introduced to isolate backend services from direct client tampering, enforcing all traffic to traverse the edge reverse proxy.
3. **High Availability**: Nginx was hardened with active failover directives (`proxy_next_upstream`), eliminating downtime when a backend crashes.
4. **Migration & TTL Dynamics**: Configured short DNS TTLs (30s) and executed zero-hardware standby edge cutovers.

---

## 2. Resilience Tests and Results

### Extension A: Backup DNS Resolver
* **Configuration**: Primary DNS at `10.16.13.239`, Backup DNS at `10.16.13.37`.
* **Test Procedure**:
  1. Configured client network settings with both DNS IPs.
  2. Stopped primary `dnsmasq` (`sudo killall dnsmasq` on Mac 1).
  3. Ran `dig app.team1.test` from client.
* **Result**: Query resolved to `10.16.13.1` via the backup server with zero manual intervention.

### Extension B: DNS TTL & Controlled Record Change
* **Configuration**: Set `local-ttl=30` in `dnsmasq_ttl.conf`.
* **Test Procedure**:
  1. Client queried `app.team1.test` (cached `10.16.13.1`).
  2. Updated DNS record to `10.16.13.71`.
  3. Queried client repeatedly over 45 seconds.
* **Result**: Client continued using old cached record until second 30, after which it updated to the new IP. Flushed cache manually via `dscacheutil -flushcache`, triggering an instant update.

### Extension C: Service Isolation (Backend Firewall Rules)
* **Configuration**: Loaded `pf_backend_isolation.conf` on Mac 3 and Mac 4.
* **Test Procedure**:
  1. Direct client `curl http://10.16.13.37:3001/api/status` -> **Connection Refused / Filtered**.
  2. Edge proxy `curl https://app.team1.test/api/status` -> **200 OK**.
* **Result**: Direct backend bypass prevented; clients can only reach backends through the inspected TLS edge proxy.

### Extension D: High-Availability Failover Behavior
* **Configuration**: Configured `proxy_next_upstream error timeout http_502` and `max_fails=1` in `nginx_ha.conf`.
* **Test Procedure**:
  1. Sent continuous requests; observed `X-Backend: A` and `X-Backend: B` alternating.
  2. Terminated Backend A (`node serverA.js` stopped).
  3. Continued sending requests without pausing.
* **Result**: Nginx detected Backend A failure within 1 second and rerouted traffic seamlessly to Backend B (`X-Backend: B`). Zero 502 Bad Gateway responses were returned to the user.

### Extension E: Controlled Edge Migration (DNS-Based Cutover)
* **Configuration**: Spun up standby Nginx instance on Mac 4 (`10.16.13.71`) with matching TLS certificates.
* **Test Procedure**: Changed `app.team1.test` DNS pointer to `10.16.13.71`.
* **Result**: Observed gradual migration of clients from Active Edge to Standby Edge as local DNS caches expired.

---

## 3. Troubleshooting Findings (Extension F)
* **Diagnosis Methodology**: Developed a strict bottom-up diagnostic workflow: DNS resolution (dig) → Transport reachability (ping/nc) → TLS handshake (openssl) → Application HTTP status.
* **Key Finding**: Distinguishing between DNS layer failures (connection cannot be initiated because name does not resolve) versus application upstream failures (DNS resolves, TLS completes, but Nginx returns 502) is essential for rapid root-cause isolation.

---

## 4. Learning Summary (One Paragraph Per Extension)
* **Extension A (DNS Failover)**: Reinforced that DNS client resolvers maintain an ordered list of servers and query secondary resolvers when the primary times out, highlighting the difference between name resolution failure and application service downtime.
* **Extension B (DNS TTL)**: Demonstrated that DNS caching trades off immediate update propagation for reduced query latency, making low TTLs critical prior to scheduled maintenance windows.
* **Extension C (Service Isolation)**: Emphasized the principle of defense-in-depth: web applications should never expose their listening application ports directly to users, but should mandate ingress via edge inspection proxies using firewall boundaries.
* **Extension D (HA Failover)**: Showed how reverse proxies can transparently retry failed upstreams to eliminate user-visible errors, while clarifying that the proxy itself remains an architectural Single Point of Failure (SPOF) requiring VRRP or Anycast at scale.
* **Extension E (Edge Migration)**: Illustrated how cloud load balancers and CDNs perform traffic cutovers globally using DNS delegation without modifying backend applications or requiring physical re-cabling.
