# WAZUH INSTALL GUIDE
# ===================
# Tanggal: 02 September 2026
# Sistem Target: Linux (VM/Server) atau WSL2 Ubuntu 22.04 LTS
# Versi Wazuh: 4.14 (latest)

================================================================================
PERSYARATAN SISTEM
================================================================================

HARDWARE MINIMAL:
- CPU: 2 core
- RAM: 4GB (8GB direkomendasikan)
- Disk: 20GB

SISTEM YANG DIDUKUNG:
- ✅ WSL2 Ubuntu 22.04 LTS (Windows)
- ✅ VM Ubuntu 22.04 LTS (Linux)
- ✅ Server Ubuntu 22.04 LTS (Linux)
- ✅ Debian-based Linux lainnya

================================================================================
OPSI 1: WSL2 UBUNTU (WINDOWS)
================================================================================

LANGKAH 1.1: SETUP .wslconfig (Windows)
-----------------------------------------
File: %USERPROFILE%\.wslconfig

Buka PowerShell, ketik:
```
notepad %USERPROFILE%\.wslconfig
```

Isi dengan:
```
[wsl2]
memory=6GB
processors=3
swap=8GB
localhostForwarding=true
```

Simpan file.

Restart WSL:
```
wsl --shutdown
```

Buka ulang Ubuntu.

---

LANGKAH 1.2: UPDATE UBUNTU
---------------------------
```
sudo apt update && sudo apt upgrade -y
```

---

LANGKAH 1.3: INSTALL DEPENDENCIES
----------------------------------
```
sudo apt install -y curl apt-transport-https gnupg
```

---

================================================================================
OPSI 2: VM/SERVER LINUX (NON-WSL)
================================================================================

LANGKAH 2.1: UPDATE SISTEM
----------------------------
```
sudo apt update && sudo apt upgrade -y
```

---

LANGKAH 2.2: INSTALL DEPENDENCIES
----------------------------------
```
sudo apt install -y curl apt-transport-https gnupg ca-certificates
```

---

================================================================================
CARA INSTALL WAZUH (UNTUK SEMUA SISTEM)
================================================================================

LANGKAH 3: DOWNLOAD & INSTALL WAZUH v4.14
------------------------------------------
```
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
chmod +x wazuh-install.sh
sudo bash wazuh-install.sh -a
```

Waktu install: ~15-20 menit

---

LANGKAH 4: SIMPAN CREDENTIALS
-------------------------------
Setelah install selesai, akan muncul credentials.

CONTOH OUTPUT:
```
02/09/2026 14:57:48 INFO: You can access the web interface https://<wazuh-dashboard-ip>:443
02/09/2026 14:57:48 INFO: User: admin
02/09/2026 14:57:48 INFO: Password: [GENERATED_PASSWORD]
02/09/2026 14:57:48 INFO: Installation finished.
```

SIMPAN:
- URL Dashboard
- Username: admin
- Password: [ISI DENGAN PASSWORD YANG TAMPIL]

---

LANGKAH 5: AKSES DASHBOARD
----------------------------

UNTUK WSL:
1. Buka Chrome/Edge di Windows
2. Kunjungi https://localhost:443
3. Klik "Advanced" → "Proceed to localhost (unsafe)"
4. Login dengan credentials

UNTUK VM/SERVER:
1. Buka browser
2. Kunjungi https://[IP-SERVER]:443
3. Klik "Advanced" → "Proceed to [IP-SERVER] (unsafe)"
4. Login dengan credentials

---

================================================================================
KOMPONEN YANG TERINSTALL
================================================================================

- Wazuh Manager    : Port 1514, 1515 (agent management)
- Wazuh Indexer    : Port 9200 (Elasticsearch fork, indexing)
- Wazuh Dashboard  : Port 443 (Kibana fork, UI)
- Filebeat         : Log forwarder

---

================================================================================
VERIFIKASI SERVICE
================================================================================

Cek status service:
```
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard
```

Cek port yang berjalan:
```
sudo ss -tlnp | grep -E '9200|5601|1514|1515'
```

---

================================================================================
TROUBLESHOOTING
================================================================================

MASALAH: Install Gagal
-----------------------
Cek log error:
```
cat /var/log/wazuh-installation.log
```

MASALAH: Port Sudah Dipakai
---------------------------
Cek port:
```
sudo lsof -i :443
sudo lsof -i :9200
```

MATIKAN SERVICE YANG MEMAKAI:
```
sudo systemctl stop [nama-service]
sudo systemctl disable [nama-service]
```

MASALAH: Disable Auto-Update (Ubuntu/Debian)
--------------------------------------------
```
sudo mv /etc/apt/sources.list.d/wazuh.list /etc/apt/sources.list.d/wazuh.list.bak
sudo apt update
```

---

================================================================================
TEST SIEM
================================================================================

Setelah login ke Dashboard:
1. Menu: Threat Detection → Log Test
2. Paste sample log:

```
Feb 14 12:00:00 myserver sshd[1234]: Accepted password for root from 192.168.1.100 port 22 ssh2
```

3. Klik "Analyze"
4. Jika muncul alert, berarti Wazuh berfungsi

---

================================================================================
STATUS: ✅ SELESAI
================================================================================
