# Cara Install Wazuh Agent di Windows

## Prerequisites

- Wazuh Manager sudah berjalan
- IP/hostname manager diketahui (localhost, IP, atau hostname alias)
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

**Langsung paste URL ini di browser:**

```
https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.7-1.msi
```

File akan langsung ter-download.

---

## Langkah 3: Install Agent (GUI)

1. Double-click file `.msi`
2. Klik **Next** → **Accept** → **Next**
3. Masukkan:
   - **Wazuh Manager IP**: `172.28.208.227` (atau `localhost`, `hostname-alias`)
4. Klik **Next** → **Install**
5. Klik **Finish**

---

## Langkah 4: Import Key

1. Buka **Wazuh Agent** dari Start Menu:
   ```
   Start → Wazuh → Wazuh Agent
   ```
2. Tab **Management** → **Connect**
3. Paste **key** yang sudah di-copy
4. Klik **OK**

---

## Langkah 5: Start Service

```powershell
net start wazuh-agent
```

---

## Verifikasi

Buka Dashboard:
```
https://172.28.208.227:443 → Agents → Status: Active (green)
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
- **Settings** - Konfigurasi manager IP
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
net stop wazuh-agent && net start wazuh-agent

# Cek status service
sc query wazuh-agent

# Lihat log
type "C:\Program Files (x86)\ossec-agent\ossec.log"

# Uninstall
msiexec /x wazuh-agent-4.14.7-1.msi /qn
```

---

## Auto-Start on Boot

Wazuh Agent auto-start sudah enabled secara default saat install.

Cek:
```powershell
sc qc wazuh-agent
```

Jika `AUTO_START` bukan `AUTO`, ubah:
```powershell
sc config wazuh-agent start= auto
```
