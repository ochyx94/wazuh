#!/bin/bash
# =============================================================================
# WAZUH RESOURCE LIMITS SCRIPT
# =============================================================================
# Tujuan: Batasi RAM usage komponen Wazuh di WSL
# Total limit: 4GB (Indexer 2GB, Dashboard 1GB, Manager 1GB)
# =============================================================================

set -e

echo "=== WAZUH RESOURCE LIMITS ==="
echo "Total limit: 4GB"
echo "  - Indexer:  2GB"
echo "  - Dashboard: 1GB"
echo "  - Manager:   1GB"
echo ""

# === INDEXER (2GB) ===
echo "[1/3] Setup Indexer heap (2GB)..."
sudo tee /etc/wazuh-indexer/jvm.options.d/heap.options > /dev/null << 'EOF'
-Xms2g
-Xmx2g
EOF
echo "  Done: /etc/wazuh-indexer/jvm.options.d/heap.options"

# === DASHBOARD (1GB) ===
echo "[2/3] Setup Dashboard memory (1GB)..."
sudo tee /etc/wazuh-dashboard/opensearch_dashboards.in.sh > /dev/null << 'EOF'
export NODE_OPTIONS="--max-old-space-size=1024"
EOF
echo "  Done: /etc/wazuh-dashboard/opensearch_dashboards.in.sh"

# === MANAGER (1GB) ===
echo "[3/3] Setup Manager limits (queue_size)..."
if grep -q "<ossec_config>" /var/ossec/etc/ossec.conf; then
    if ! grep -q "<limits>" /var/ossec/etc/ossec.conf; then
        sudo sed -i 's|<ossec_config>|<ossec_config>\n  <limits>\n    <queue_size>16384</queue_size>\n  </limits>|' /var/ossec/etc/ossec.conf
        echo "  Done: Added <limits> to ossec.conf"
    else
        echo "  Skipped: <limits> already exists"
    fi
else
    echo "  Skipped: <ossec_config> not found"
fi

echo ""
echo "=== RESTARTING SERVICES ==="
sudo systemctl restart wazuh-indexer wazuh-dashboard wazuh-manager
echo "Services restarted."

echo ""
echo "=== VERIFIKASI (ček RAM setelah 10 detik) ==="
sleep 10
ps aux | grep -E 'opensearch|node' | awk '{printf "  %s %.1f MB\n", $11, $6/1024}'

echo ""
echo "=== SELESAI ==="
echo "Total RAM untuk Wazuh dibatasi ~4GB"
