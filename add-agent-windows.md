# Cara Install Wazuh Agent di Windows

## Prerequisites

- Wazuh Manager sudah berjalan
- IP/hostname manager diketahui
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

```powershell
# Download langsung dari server
curl -O https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.7-1.msi
```

Atau buka browser:
```
https://172.28.208.227:443 → Agents → Deploy new agent
```

---

## Langkah 3: Install Agent

### Option A: Silent Install (Command Line)

```powershell
msiexec /i wazuh-agent-4.14.7-1.msi /qn ^
    WAZUH_MANAGER="172.28.208.227" ^
    WAZUH_MANAGER_PORT="1514" ^
    WAZUH_PROTOCOL="tcp"
```

### Option B: GUI Install (MSI)

1. Double-click file `.msi`
2. Klik **Next** → **Accept** → **Next**
3. Masukkan **Wazuh Manager IP**: `172.28.208.227`
4. Port: `1514`
5. Klik **Next** → **Install**
6. Klik **Finish**

---

## Langkah 4: Import Key

### Option A: Via UI (GUI)

1. Buka **Wazuh Agent** dari Start Menu
   ```
   Start → Wazuh → Wazuh Agent
   ```
2. Tab **Settings** → **Configuration**
3. Isi:
   - Manager IP: `172.28.208.227`
   - Port: `1514`
4. Klik **Save**
5. Tab **Management** → **Connect**

### Option B: Via Command Line

```powershell
cd "C:\Program Files (x86)\ossec-agent"
manage-agents.exe -i

# Paste key → Enter → Y
```

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

Wazuh Agent punya GUI interface untuk management:

```
Start Menu → Wazuh → Wazuh Agent
```

**Fitur UI:**
- **Overview** - Status agent dan konektivitas
- **Management** - Connect/Disconnect/Restart agent
- **Settings** - Konfigurasi manager IP, port, protocol
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
