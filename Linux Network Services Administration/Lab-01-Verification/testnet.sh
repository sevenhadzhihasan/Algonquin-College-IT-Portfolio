#!/bin/bash
# CST8246 Network Validation Script - Magic Number 130

echo "STARTING AUTOMATED NETWORK CONFIGURATION VERIFICATION"

# 1. Verify Firewall is Disabled
FIREWALL_STATUS=$(systemctl is-active firewalld)
if [ "$FIREWALL_STATUS" = "inactive" ]; then
    echo "[PASS] Firewall is disabled."
else
    echo "[FAIL] Firewall is active! Current status: $FIREWALL_STATUS"
fi

# 2. Verify Local RED Static IP Address Matching Magic Number
echo "Checking interface ens224 IP..."
IP_CHECK=$(ip addr show ens224 | grep "172.16.30.130")
if [ ! -z "$IP_CHECK" ]; then
    echo "[PASS] RED network interface has correct static mapping: 172.16.30.130"
else
    echo "[FAIL] Could not discover target static IP 172.16.30.130 assigned to ens224."
fi
 3. Verify Connectivity to the Client VM (Visible Pings)
echo "--------------------------------------------------"
echo "Pinging Client VM (172.16.31.130):"
ping -c 3 172.16.31.130
if [ $? -eq 0 ]; then
    echo "[PASS] Client VM (172.16.31.130) is reachable."
else
    echo "[FAIL] Client VM (172.16.31.130) is unreachable!"
fi

# 4. Verify External Internet Routing through BLUE Network (Visible Pings)
echo "--------------------------------------------------"
echo "Pinging Google for Internet Access:"
ping -c 3 google.com
if [ $? -eq 0 ]; then
    echo "[PASS] External WAN verified. Google is reachable."
else
    echo "[FAIL] External network route broken. Google ping returned an error."
fi
echo "--------------------------------------------------"

echo "VERIFICATION COMPLETED SUCCESSFULLY"
