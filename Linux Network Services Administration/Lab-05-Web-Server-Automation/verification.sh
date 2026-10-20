#!/bin/bash
# ==============================================================================
# Script Name:  verification.sh
# Target Lab:   CST8246 - Lab 5 (Automation and Name Verification Validation)
# Target Node:  Linux Client System (172.16.31.130)
# ==============================================================================

SERVER_DNS_IP="172.16.30.130"
SERVER_ALIAS_IP="172.16.32.130"
MN="130"

echo "========================================================================"
echo "         CST8246 AUTOMATED CLIENT VALIDATION SUITE - LAB 5             "
echo "========================================================================"

# --- 1. Prevent NetworkManager from modifying client settings on reboot ---
echo "[+] Locking Client NetworkManager to prevent automated resolution overwrites..."
echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf
systemctl reload NetworkManager

if ! grep -q "dns=none" /etc/NetworkManager/NetworkManager.conf; then
    echo -e "\n[main]\ndns=none" >> /etc/NetworkManager/NetworkManager.conf
fi

# --- 2. Reload the active network profiles ---
systemctl reload NetworkManager

echo "[+] Directing local interface resolver paths to Master BIND Server..."
cat <<EOF > /etc/resolv.conf
search localdomain domain130.lab
nameserver ${SERVER_DNS_IP}
EOF
chmod 644 /etc/resolv.conf
echo "  [OK] Resolv configuration updated successfully."

# --- 3. Interconnect Route Inhabitation ---
echo -e "\n[+] Verifying routing reachability to the secure alias network range..."
if ! ip route show | grep -q "172.16.32.0/24"; then
    ip route add 172.16.32.0/24 via "$SERVER_DNS_IP" || true
    echo "  [OK] Static subnet gateway route injected."
else
    echo "  [OK] Static route already exists."
fi

# --- 4. Executing Standard DNS Verification Blocks ---
echo -e "\n[*] Task 1: Querying BIND Name Server Zones via dig..."

echo -e "\n--> dig www.example${MN}.lab +short"
DIG_EX=$(dig www.example${MN}.lab +short)
if [ -n "$DIG_EX" ]; then
    echo "  Resolved IP: $DIG_EX [PASS]"
else
    echo "  [FAIL] Failed to resolve hostname entry."
fi

echo -e "\n--> dig www.site${MN}.lab +short"
DIG_ST=$(dig www.site${MN}.lab +short)
if [ -n "$DIG_ST" ]; then
    echo "  Resolved IP: $DIG_ST [PASS]"
else
    echo "  [FAIL] Failed to resolve hostname entry."
fi

echo -e "\n--> dig secure.example${MN}.lab +short"
DIG_SEC=$(dig secure.example${MN}.lab +short)
if [ -n "$DIG_SEC" ]; then
    echo "  Resolved IP: $DIG_SEC [PASS]"
else
    echo "  [FAIL] Failed to resolve secure host alias entry."
fi

# --- 5. Executing Standard Web Access Verification Blocks ---
echo -e "\n[*] Task 2: Testing Target Virtual Website Deliveries..."

echo -e "\n--> curl http://www.example${MN}.lab"
curl -s --connect-timeout 4 http://www.example${MN}.lab || echo "  [FAIL] Connection blocked or unreachable."

echo -e "\n--> curl http://www.site${MN}.lab"
curl -s --connect-timeout 4 http://www.site${MN}.lab || echo "  [FAIL] Connection blocked or unreachable."

echo -e "\n--> curl -k https://secure.example${MN}.lab"
curl -k -s --connect-timeout 4 https://secure.example${MN}.lab || echo "  [FAIL] Connection blocked or unreachable."

echo -e "\n========================================================================"
echo "             LAB 5 CLIENT VERIFICATION PROCESS COMPLETED               "
echo "========================================================================"
