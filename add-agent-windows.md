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
```

Ikuti langkah-langkah berikut:

```
[A] Add new agent
```

Masukkan informasi agent:

```
Agent name: WINDOWS-PC
        ↑ WAJIB DIISI - Gunakan nama komputer Windows kamu
        Cara cek: Jalankan "hostname" di Command Prompt

Agent IP: any
        ↑ DISARANKAN "any" UNTUK PEMULA
        Penjelasan:
        - "any" = agent bisa konek dari IP berapa pun
        - Kalau pakai IP spesifik, agent harus dari IP tersebut
        - Untuk percobaan/belajar, pakai "any" lebih mudah
```

```
[E] Extract key for agent(s)
```

Pilih agent ID yang baru dibuat, lalu **copy key** yang muncul.

```
[Q] Quit
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

1. Buka **Wazuh Agent GUI**:
   ```
   C:\Program Files (x86)\ossec-agent\win32ui.exe
   ```
2. Terdapat **2 kolom** yang perlu diisi:
   - **Wazuh Manager address**: `localhost` (atau hostname server)
   - **Key**: paste key yang sudah di-copy
3. Klik **Connect**

---

## Langkah 5: Kelola Service

### Cek Nama dan Status Service (PowerShell)

```powershell
Get-Service *wazuh*
```

Output:
```
Status   Name               DisplayName
------   ----               -----------
Running  WazuhSvc           Wazuh Agent
```

### Kapan Start, Stop, Restart?

| Kondisi | Aksi | Alasan |
|---------|------|--------|
| Agent tidak konek ke manager | **Restart** | Reset koneksi |
| Setelah edit konfigurasi | **Restart** | Apply konfigurasi baru |
| Agent macet/bermasalah | **Stop** lalu **Start** | Fresh start |
| Mau hentikan monitoring | **Stop** | Stop monitoring |
| Mau mulai monitoring | **Start** | Mulai monitoring |

### Start Service

```powershell
Start-Service -Name "Wazuh"
```

### Stop Service

```powershell
Stop-Service -Name "Wazuh"
```

### Restart Service

```powershell
Restart-Service -Name "Wazuh"
```

---

## Verifikasi

Buka Dashboard:
```
https://localhost:443 → Agents → Status: Active (green)
```

---

## Wazuh Agent UI

Lokasi:
```
C:\Program Files (x86)\ossec-agent\win32ui.exe
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
| Agent tidak connect | Restart service |
| Status "Disconnected" | Cek manager jalan, restart service |
| Key invalid | Hapus agent, add baru, extract key lagi |
| Install gagal | Jalankan sebagai Administrator |

---

## Command Penting

```powershell
# Cek nama dan status service
Get-Service *wazuh*

# Start service
Start-Service -Name "Wazuh"

# Stop service
Stop-Service -Name "Wazuh"

# Restart service
Restart-Service -Name "Wazuh"

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
Get-Service -Name "Wazuh" | Select-Object Name, Status, StartType
```

---

## Cara Cek Nama Komputer Windows

```powershell
# Via Command Prompt
hostname

# Via PowerShell
$env:COMPUTERNAME

# Via System Properties
Win + R → sysdm.cpl → Computer Name
```

Nama komputer ini digunakan sebagai **Agent name** saat menambah agent di manager.
