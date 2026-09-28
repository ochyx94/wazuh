# Cara Install Wazuh Agent di Windows

## Prerequisites

- Wazuh Manager sudah berjalan
- Alamat manager diketahui (localhost, hostname, atau IP)
- Agent key sudah di-extract dari manager

---

## Langkah 1: Extract Key di Manager

```bash
cd /var/ossec/bin
sudo ./manage_agents

# Pilih:
# [A] Add new agent
# Agent name: windows-pc
# Agent IP: any
# [E] Extract key for agent(s)
# Copy key yang muncul
# [Q] Quit
```

---

## Langkah 2: Download Agent

**Paste URL ini langsung di browser:**

```
https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.8-1.msi
```

File akan langsung ter-download.

---

## Langkah 3: Install Agent

1. Double-click file `.msi`
2. Klik **Next** → **Accept** → **Next**
3. Klik **Next** → **Install** (TIDAK perlu masukkan address di sini)
4. Klik **Finish**

---

## Langkah 4: Konfigurasi via GUI

1. Buka **Wazuh Agent** dari Start Menu:
   ```
   Start → Wazuh → Wazuh Agent
   ```
2. Terdapat **2 kolom** yang perlu diisi:
   - **Wazuh Manager address**: `localhost` (atau hostname server)
   - **Key**: paste key yang sudah di-copy
3. Klik **Connect**

---

## Langkah 5: Start Service

```powershell
net start WazuhSvc
```

---

## Verifikasi

Buka Dashboard:
```
https://localhost:443 → Agents → Status: Active (green)
```

---

## Wazuh Agent UI

Buka dari Start Menu:
```
Start → Wazuh → Wazuh Agent
```

**Fitur UI:**
- **Overview** - Status agent dan konektivitas
- **Management** - Connect/Disconnect/Restart agent
- **Settings** - Konfigurasi manager address
- **Logs** - Lihat agent logs secara real-time
- **About** - Versi agent

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Agent tidak connect | Cek firewall: allow port 1514, 1515 |
| Status "Disconnected" | Cek manager jalan: `sudo systemctl status wazuh-manager` |
| Key invalid | Hapus agent, add baru, extract key lagi |
| Install gagal | Jalankan sebagai Administrator |

---

## Command Penting

```powershell
# Restart agent
net stop WazuhSvc && net start WazuhSvc

# Cek status service
sc query WazuhSvc

# Lihat log
type "C:\Program Files (x86)\ossec-agent\ossec.log"

# Uninstall
msiexec /x wazuh-agent-4.14.8-1.msi /qn
```

---

## Auto-Start on Boot

Wazuh Agent auto-start sudah enabled secara default saat install.

Cek:
```powershell
sc qc WazuhSvc
```

Jika `AUTO_START` bukan `AUTO`, ubah:
```powershell
sc config WazuhSvc start= auto
```
