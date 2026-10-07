# Panduan Uji Coba Wazuh via PowerShell (untuk Pemula)

> Panduan ini untuk **pengujian setelah workshop** — TIDAK termasuk materi slide.
> Semua perintah diketik di **PowerShell** pada laptop Windows yang sudah terinstall
> Wazuh Agent.

---

## Bagian 0 — Persiapan (Sekali Saja)

### Kenapa perlu persiapan?

Wazuh tidak bisa melihat command PowerShell kalau **PowerShell Logging** belum aktif.
Fitur ini standar Windows, hanya perlu dinyalakan.

### Langkah aktifkan (pakai GUI, mudah):

1. Tekan tombol **Windows + R** → ketik `gpedit.msc` → Enter
2. Di jendela yang terbuka, klik menu di sebelah kiri:
   `Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell`
3. Cari di daftar kanan: **"Turn on PowerShell Script Block Logging"**
4. Klik 2x → pilih **Enabled** → klik **OK**
5. Tekan **Windows + R** lagi → ketik `cmd` → Enter → ketik `gpupdate /force` → Enter
6. Selesai ✅

> 💻 Komputer kantor: kalau `gpedit.msc` tidak ada, hubungi IT admin.

---

## Bagian 1 — Test Dasar: Command Sehari-hari

### Command yang diketik di PowerShell dicatat sebagai **Event 4104**.

### Langkah:

1. Buka **PowerShell**: tekan Windows → ketik `powershell` → Enter
2. Jalankan command berikut **satu per satu**:

| Command | Fungsinya |
|---------|-----------|
| `ping google.com` | Menguji koneksi internet ke google |
| `whoami` | Menampilkan nama user & komputer kamu |
| `dir` | Menampilkan daftar file di folder sekarang |
| `Get-Date` | Menampilkan tanggal & jam sekarang |

3. Buka **Event Viewer**: tekan Windows → ketik `event viewer` → Enter
4. Klik menu kiri: `Applications and Services Logs → Windows PowerShell → Operational`
5. Lihat log paling atas — Event ID **4104** berisi command yang tadi diketik

### Cek di Wazuh Dashboard:

```
rule.groups:(windows) and agent.name:nama-laptop-kamu
```

> ⚠️ **Catatan penting:** Event 4104 hanya dicatat untuk command yang mengandung
> **script block** (perintah panjang/script). Command pendek seperti `ping` atau `dir`
> kadang **tidak** membuat Event 4104 — ini perilaku normal Windows.
>
> **Solusi:** gunakan test di Bagian 2 & 3 yang pasti menghasilkan alert.

---

## Bagian 2 — Test yang Pasti Muncul di Wazuh

### Test A — Brute Force Login (5x password salah)

**Fungsinya:** mensimulasikan attacker menebak password.
**Hasilnya:** alert `authentication_failed` di Wazuh.

```powershell
# Ketik semua baris ini sekaligus, lalu Enter:
1..5 | ForEach-Object {
    cmdkey /add:localhost /user:faketester /pass:WrongPass$_
}
```

**Cleanup** (hapus kredensial test):
```powershell
cmdkey /delete:localhost
```

**Cek di Wazuh:**
```
rule.groups:authentication_failed
```

---

### Test B — File Mencurigakan di Desktop (FIM)

**Fungsinya:** mensimulasikan attacker membuat file di folder penting.
**Hasilnya:** alert `file added` → `file modified` → `file deleted`.

**Syarat:** Wazuh Agent memantau folder Desktop (lihat `fim-config.xml`).

1. Buka **Notepad**: tekan Windows → ketik `notepad` → Enter
2. Tulis apa saja, misal: `ini file percobaan FIM`
3. **File → Save As** → pilih **Desktop** → nama: `lab-fim-test.txt` → Save
4. Tambah satu baris teks → **Ctrl+S** (Save lagi)
5. Klik kanan file di Desktop → **Delete**

**Cek di Wazuh:**
```
rule.groups:syscheck and syscheck.path:*Desktop*
```

---

### Test C — Buat User Baru (Backdoor Simulation)

**Fungsinya:** attacker sering membuat user baru untuk akses diam-diam.
**Hasilnya:** alert `user added` di Wazuh.

**Jalankan PowerShell sebagai Administrator** (klik kanan PowerShell → Run as Administrator):

```powershell
# Buat user test:
New-LocalUser -Name "testbackdoor" -Password (ConvertTo-SecureString "Test1234!" -AsPlainText -Force)

# Cek user-nya ada:
Get-LocalUser testbackdoor

# HAPUS setelah selesai test (penting!):
Remove-LocalUser -Name "testbackdoor"
```

**Cek di Wazuh:**
```
data.win.eventdata.targetUserName:testbackdoor
```

---

### Test D — Registry Persistence

**Fungsinya:** attacker membuat program jalan otomatis saat komputer nyala.
**Hasilnya:** alert perubahan registry (via FIM).

```powershell
# Tambah entry test:
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "TestPersistence" -Value "notepad.exe" -PropertyType String -Force

# HAPUS setelah test:
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "TestPersistence"
```

**Cek di Wazuh:**
```
rule.groups:syscheck and syscheck.path:*Run*
```

---

## Bagian 3 — Verifikasi di Wazuh Dashboard

1. Buka browser → Wazuh Dashboard (`https://ip-server:443`)
2. Login → menu **Discover / Threat Hunting**
3. Set **time range**: Last 15 minutes
4. Filter by agent: `agent.name: NAMA-LAPTOP-KAMU`
5. Sort kolom timestamp dari besar ke kecil (terbaru di atas)

**Alert yang diharapkan:**

| Test | Alert yang muncul |
|------|-------------------|
| A — Brute force | `sshd: authentication failed` / `Windows logon failure` |
| B — File Desktop | `file added` / `file modified` / `file deleted` |
| C — User baru | `user added` / `windows: user creation` |
| D — Registry | `syscheck: registry value modified` |

---

## Troubleshooting

| Masalah | Penyebab & Solusi |
|---------|-------------------|
| Tidak ada alert sama sekali | Cek agent status: `Get-Service WazuhSvc` harus **Running** |
| FIM tidak deteksi file | Pastikan Desktop ada di config `fim-config.xml`, restart agent |
| PowerShell tidak tercatat | Ulangi Bagian 0 (gpedit), pastikan Enabled + `gpupdate /force` |
| Alert delay 1-2 menit | Normal — agent kirim log berkala (bukan real-time penuh) |
| User baru gagal dibuat | PowerShell belum Run as Administrator |

---

## Ringkasan Perintah (Cheat Sheet)

```powershell
# Prasyarat check:
Get-Service WazuhSvc                              # agent harus Running
Get-WinEvent -LogName "Windows PowerShell" -MaxEvents 5   # lihat event 4104

# Test cepat berurutan:
whoami                                            # Event 4104 (kadang)
New-Item C:\Users\Public\lab.txt -Force        # FIM: file added
Remove-Item C:\Users\Public\lab.txt -Force     # FIM: file deleted
```
