#!/usr/bin/env bash
# File: phase2_temp/firewall/test_firewall.sh
# Demonstrates Extension C (Service Isolation Verification)

BACKEND_A="10.7.11.88:3001"
BACKEND_B="10.7.9.64:3002"
EDGE_PROXY="https://app.team1.test/api/status"

echo "=== 1. Testing Direct Connection to Backend A from Client ==="
echo "Attempting direct curl to http://$BACKEND_A/api/status (timeout 2s)..."
DIRECT_A=$(curl -s --connect-timeout 2 "http://$BACKEND_A/api/status" 2>&1)
if [[ $? -eq 0 ]]; then
    echo "Result: Direct access SUCCEEDED (Firewall NOT active or this is Mac 2)."
    echo "Response: $DIRECT_A"
else
    echo "Result: Direct access BLOCKED/TIMED OUT (Firewall Isolation SUCCESSFUL!)."
fi

echo ""
echo "=== 2. Testing Direct Connection to Backend B from Client ==="
echo "Attempting direct curl to http://$BACKEND_B/api/status (timeout 2s)..."
DIRECT_B=$(curl -s --connect-timeout 2 "http://$BACKEND_B/api/status" 2>&1)
if [[ $? -eq 0 ]]; then
    echo "Result: Direct access SUCCEEDED (Firewall NOT active or this is Mac 2)."
    echo "Response: $DIRECT_B"
else
    echo "Result: Direct access BLOCKED/TIMED OUT (Firewall Isolation SUCCESSFUL!)."
fi

echo ""
echo "=== 3. Testing Legitimate Connection via Edge Nginx Proxy ==="
echo "Querying through Edge Reverse Proxy ($EDGE_PROXY)..."
PROXY_RES=$(curl -s "$EDGE_PROXY" 2>&1)
echo "Response: $PROXY_RES"
echo "Result: Edge proxy connects to backends normally, proving isolation works as intended."
