#!/usr/bin/env bash
# File: nginx/test_ha_failover.sh
# Tests Extension D (High-Availability Failover & Upstream Resiliency)

TARGET="https://app.team1.test/api/status"
REQUESTS=10

echo "=== High-Availability Failover Automated Test ==="
echo "Sending $REQUESTS requests to $TARGET..."
echo ""

for i in $(seq 1 $REQUESTS); do
    RESP=$(curl -sI --resolve app.team1.test:443:127.0.0.1 "$TARGET")
    STATUS=$(echo "$RESP" | head -n 1 | awk '{print $2}')
    HEADER=$(echo "$RESP" | grep -i "X-Backend:" | tr -d '\r')
    echo "Request $i: HTTP Status = $STATUS | Response Header = $HEADER"
    sleep 0.5
done

echo ""
echo "--- How to demonstrate HA Failover ---"
echo "1. Run this script while both Backend A (Port 3001) and Backend B (Port 3002) are UP."
echo "   -> You will see alternating 'X-Backend: A' and 'X-Backend: B'."
echo "2. Stop Backend A: 'killall node' on Mac 3."
echo "3. Run this script again."
echo "   -> Nginx immediately detects Backend A is down and routes 100% requests to 'X-Backend: B'."
echo "   -> Client experiences ZERO downtime (no 502 Bad Gateway)."
echo "4. Restart Backend A: 'node serverA.js'."
echo "   -> Nginx automatically heals and resumes alternating between A and B."
