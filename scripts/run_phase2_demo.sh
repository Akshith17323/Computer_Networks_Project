#!/usr/bin/env bash
# File: scripts/run_phase2_demo.sh
# Master Interactive Demonstration Script for Phase 2 Evaluation

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=========================================================="
echo "    COMPUTER NETWORKS PROJECT: PHASE 2 LIVE DEMO RUNNER   "
echo "=========================================================="
echo "1. Test Backup DNS Failover (Extension A)"
echo "2. Test DNS TTL & Cache Expiration (Extension B)"
echo "3. Test Backend Firewall Isolation (Extension C)"
echo "4. Test High-Availability Upstream Failover (Extension D)"
echo "5. View Layer-by-Layer Troubleshooting Guide (Extension F)"
echo "6. Exit"
echo "=========================================================="
read -p "Select a demonstration step [1-6]: " choice

case $choice in
    1)
        bash "$PROJECT_ROOT/phase2_temp/dns/test_dns_failover_ttl.sh"
        ;;
    2)
        echo "Querying DNS with TTL information:"
        dig app.team1.test +noall +answer
        echo ""
        echo "To flush cache on macOS:"
        echo "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
        ;;
    3)
        bash "$PROJECT_ROOT/phase2_temp/firewall/test_firewall.sh"
        ;;
    4)
        bash "$PROJECT_ROOT/nginx/test_ha_failover.sh"
        ;;
    5)
        cat "$PROJECT_ROOT/docs/Troubleshooting_Guide_Layer_by_Layer.md"
        ;;
    6)
        echo "Exiting demo runner."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
