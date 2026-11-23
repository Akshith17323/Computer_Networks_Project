#!/usr/bin/env bash
# File: scripts/update_ips.sh
# Quickly updates all project configuration files when college Wi-Fi DHCP assigns new IPs

echo "=========================================================="
echo "    COMPUTER NETWORKS: AUTOMATIC IP RE-MAPPING SCRIPT     "
echo "=========================================================="
echo "Check your current IP on each Mac using: ipconfig getifaddr en0"
echo ""

# Get current configured IPs (or defaults)
read -p "Enter Mac 1 IP (Akhil - Primary DNS)    [e.g. 10.16.13.239]: " MAC1_IP
read -p "Enter Mac 2 IP (Akshith - Edge Nginx)   [e.g. 10.16.13.1]:   " MAC2_IP
read -p "Enter Mac 3 IP (Mohit - Backend A)      [e.g. 10.16.13.37]:  " MAC3_IP
read -p "Enter Mac 4 IP (Jayadeep - Backend B)   [e.g. 10.16.13.71]:  " MAC4_IP

if [[ -z "$MAC1_IP" || -z "$MAC2_IP" || -z "$MAC3_IP" || -z "$MAC4_IP" ]]; then
    echo "Error: All 4 IP addresses are required."
    exit 1
fi

echo ""
echo "Updating configuration files with new IPs..."

# 1. Update Nginx (Mac 2 Edge)
sed -i '' -E "s/server [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3001/server $MAC3_IP:3001/g" nginx/nginx.conf
sed -i '' -E "s/server [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3002/server $MAC4_IP:3002/g" nginx/nginx.conf
echo "✔ Updated nginx/nginx.conf"

# 2. Update Primary dnsmasq (Mac 1 DNS)
if [[ -f dns/dnsmasq.conf ]]; then
    sed -i '' -E "s/address=\/app\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/app.team1.test\/$MAC2_IP/g" dns/dnsmasq.conf
    sed -i '' -E "s/address=\/api\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/api.team1.test\/$MAC2_IP/g" dns/dnsmasq.conf
    echo "✔ Updated dns/dnsmasq.conf"
fi

# 3. Update Phase 2 Backup DNS & TTL configs if present
if [[ -f phase2_temp/dns/backup_dnsmasq.conf ]]; then
    sed -i '' -E "s/listen-address=127\.0\.0\.1,[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/listen-address=127.0.0.1,$MAC3_IP/g" phase2_temp/dns/backup_dnsmasq.conf
    sed -i '' -E "s/address=\/app\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/app.team1.test\/$MAC2_IP/g" phase2_temp/dns/backup_dnsmasq.conf
    sed -i '' -E "s/address=\/api\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/api.team1.test\/$MAC2_IP/g" phase2_temp/dns/backup_dnsmasq.conf
    echo "✔ Updated phase2_temp/dns/backup_dnsmasq.conf"
fi

if [[ -f phase2_temp/dns/dnsmasq_ttl.conf ]]; then
    sed -i '' -E "s/listen-address=127\.0\.0\.1,[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/listen-address=127.0.0.1,$MAC1_IP/g" phase2_temp/dns/dnsmasq_ttl.conf
    sed -i '' -E "s/address=\/app\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/app.team1.test\/$MAC2_IP/g" phase2_temp/dns/dnsmasq_ttl.conf
    sed -i '' -E "s/address=\/api\.team1\.test\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/address=\/api.team1.test\/$MAC2_IP/g" phase2_temp/dns/dnsmasq_ttl.conf
    echo "✔ Updated phase2_temp/dns/dnsmasq_ttl.conf"
fi

# 4. Update PF Firewall Isolation
if [[ -f phase2_temp/firewall/pf_backend_isolation.conf ]]; then
    sed -i '' -E "s/edge_ip = \"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\"/edge_ip = \"$MAC2_IP\"/g" phase2_temp/firewall/pf_backend_isolation.conf
    echo "✔ Updated phase2_temp/firewall/pf_backend_isolation.conf"
fi

# 5. Update Standby Nginx
if [[ -f phase2_temp/nginx/standby_nginx.conf ]]; then
    sed -i '' -E "s/server [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3001/server $MAC3_IP:3001/g" phase2_temp/nginx/standby_nginx.conf
    sed -i '' -E "s/server [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3002/server $MAC4_IP:3002/g" phase2_temp/nginx/standby_nginx.conf
    echo "✔ Updated phase2_temp/nginx/standby_nginx.conf"
fi

echo ""
echo "All configuration files have been updated to your current subnet!"
echo "You can now start your services cleanly."
