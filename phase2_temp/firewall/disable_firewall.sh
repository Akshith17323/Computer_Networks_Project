#!/usr/bin/env bash
# File: phase2_temp/firewall/disable_firewall.sh
# Disables pf firewall rules and restores macOS default network configuration

echo "=== Disabling Backend Firewall Isolation ==="
echo "Flushing custom pf rules..."
sudo pfctl -F all -f /etc/pf.conf 2>/dev/null
sudo pfctl -d 2>/dev/null

echo "Packet Filter (pf) rules disabled. Default network configuration restored."
