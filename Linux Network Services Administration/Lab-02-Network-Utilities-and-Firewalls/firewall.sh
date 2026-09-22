#!/bin/bash
# ==============================================================================
# Script Name:  firewall.sh
# Description:  Configures netfilter iptables rules for CST8246 Demo environments.
#               Controls subnet routing access restrictions for target port 49999.
# ==============================================================================

echo "----------------------------------------"
echo "Configuring firewall policies..."
echo "----------------------------------------"

# 1. Flush existing rules to start with a clean state
echo "[*] Flushing existing INPUT rules..."
iptables -F INPUT

# 2. Grant access to server on port 49999 from Client network (172.16.31.0/24)
echo "[*] Adding rule: Allow access from Client subnet (172.16.31.0/24) on port 49999..."
iptables -A INPUT -p tcp -s 172.16.31.0/24 --dport 49999 -j ACCEPT

# 3. Deny access to server on port 49999 from Server network (172.16.30.0/24)
echo "[*] Adding rule: Reject access from Server subnet (172.16.30.0/24) on port 49999..."
iptables -A INPUT -p tcp -s 172.16.30.0/24 --dport 49999 -j REJECT

# 4. Display the active iptables chain rules verification summary
echo "----------------------------------------"
echo "Active Firewall Rules Implemented:"
echo "----------------------------------------"
iptables -L INPUT -n --line-numbers
