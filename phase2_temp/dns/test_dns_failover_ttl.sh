#!/usr/bin/env bash
# File: phase2_temp/dns/test_dns_failover_ttl.sh
# Demonstrates Extension A (Backup DNS Failover) and Extension B (TTL Caching)

PRIMARY_DNS="10.16.13.239"
BACKUP_DNS="10.16.13.37"
DOMAIN="app.team1.test"

echo "=== 1. Testing Primary DNS Resolution ==="
echo "Querying Primary DNS ($PRIMARY_DNS)..."
dig @$PRIMARY_DNS $DOMAIN +noall +answer +stats

echo ""
echo "=== 2. Testing Backup DNS Resolution ==="
echo "Querying Backup DNS ($BACKUP_DNS)..."
dig @$BACKUP_DNS $DOMAIN +noall +answer +stats

echo ""
echo "=== 3. Testing System Resolver (Simulating Primary Down) ==="
echo "To demonstrate failover during viva:"
echo "1. Stop dnsmasq on Mac 1: 'sudo killall dnsmasq'"
echo "2. Run: 'dig $DOMAIN'"
echo "macOS will automatically fallback to $BACKUP_DNS listed in System Settings -> Network -> DNS."

echo ""
echo "=== 4. Demonstrating DNS TTL & Cache Flushing ==="
echo "Current TTL from dig answer header:"
dig @$PRIMARY_DNS $DOMAIN +noall +answer
echo ""
echo "To flush local DNS cache immediately on macOS:"
echo "Command: sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
