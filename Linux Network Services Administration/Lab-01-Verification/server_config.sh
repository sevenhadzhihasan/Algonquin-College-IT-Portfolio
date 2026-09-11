#!/bin/bash
# ==============================================================================
# Script Name : show_config.sh
# Purpose     : Read-only display of existing CST8246 configurations.
# Course      : CST8246 - Network Setup and Automated Configuration Verification
# Student ID  : hadz0024
# ==============================================================================

LINE="--------------------------------------------------------------------------------"
clear
echo "================================================================================"
echo "                       CST8246 SYSTEM AUDIT & CONFIGURATION VIEW                "
echo "================================================================================"

echo -e "\n[1. IDENTITY & HARDWARE DETECTION]"
echo "$LINE"
echo "--- Hostname Information ---"
hostnamectl
echo -e "\n--- User Account Check ---"
id cst8246
echo -e "\n--- Detected Ethernet Hardware (Kernel) ---"
lspci | grep -i ethernet

echo -e "\n[2. NETWORK SERVICES & FIREWALL STATUS]"
echo "$LINE"
echo "NetworkManager Active Status  : $(systemctl is-active NetworkManager)"
echo "NetworkManager Enabled Status : $(systemctl is-enabled NetworkManager)"
echo -e "\n--- Firewalld Service Status Detail ---"
systemctl status firewalld --no-pager | head -n 5

echo -e "\n[3. NETWORK MANAGER CONNECTIONS & LINKS]"
echo "$LINE"
echo "--- Active NM Profiles ---"
nmcli connection show
echo -e "\n--- Brief Link Layer Interfaces ---"
ip -br link

echo -e "\n[4. INTERFACE ADDRESSING & ROUTING LAYOUT]"
echo "$LINE"
echo "--- Detailed IP Allocations ---"
ip addr show
echo -e "\n--- Kernel Routing Tables ---"
ip route show

echo -e "\n[5. RESOLUTION & LOCAL RESOLVER TABLES]"
echo "$LINE"
echo "--- Upstream DNS Name Servers (/etc/resolv.conf) ---"
cat /etc/resolv.conf
echo -e "\n--- Hostname Resolution Priority (/etc/nsswitch.conf) ---"
cat /etc/nsswitch.conf | grep '^hosts:'
echo -e "\n--- Local Static Mapping Table (/etc/hosts) ---"
cat /etc/hosts

echo -e "\n[6. LEGACY CONFIGURATION SCRIPTS VALIDATION]"
echo "$LINE"
echo "--- Blue Profile (ifcfg-ens160) ---"
if [ -f "/etc/sysconfig/network-scripts/ifcfg-ens160" ]; then cat /etc/sysconfig/network-scripts/ifcfg-ens160; else echo "File not found."; fi
echo -e "\n--- Red Profile (ifcfg-ens224) ---"
if [ -f "/etc/sysconfig/network-scripts/ifcfg-ens224" ]; then cat /etc/sysconfig/network-scripts/ifcfg-ens224; else echo "File not found."; fi

echo -e "\n[7. NETWORKMANAGER DEPLOYMENTS]"
echo "$LINE"
echo "--- System Connections Inventory ---"
ls -l /etc/NetworkManager/system-connections/
echo -e "\n--- Red Keyfile Mapping Connection (ens224.nmconnection) ---"
if [ -f "/etc/NetworkManager/system-connections/ens224.nmconnection" ]; then 
    sudo cat /etc/NetworkManager/system-connections/ens224.nmconnection
else 
    echo "Connection file not generated."
fi
