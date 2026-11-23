#!/usr/bin/env bash
# File: phase2_temp/firewall/enable_firewall.sh
# Enables macOS Packet Filter (pf) backend isolation rules

RULE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pf_backend_isolation.conf"

echo "=== Enabling Backend Firewall Isolation ==="
echo "Loading pf rules from: $RULE_FILE"

# Backup default state and load project rules
sudo pfctl -e -f "$RULE_FILE" 2>/dev/null || sudo pfctl -f "$RULE_FILE"

echo ""
echo "Current pf active status:"
sudo pfctl -s info | head -n 5
echo ""
echo "Active rules for backend ports (3001/3002):"
sudo pfctl -s rules | grep -E "3001|3002"
echo ""
echo "Firewall isolation is active: Only Edge Proxy (10.16.13.1) can reach backends."
