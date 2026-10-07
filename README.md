# Wazuh Workshop Resources

Kumpulan konfigurasi, panduan, dan dokumentasi untuk workshop Wazuh SIEM.

## Isi

| File | Keterangan |
|------|-----------|
| `INSTALL-GUIDE.md` | Panduan install Wazuh (manager + indexer + dashboard) |
| `INSTALL-LOG.txt` | Log instalasi aktual sebagai referensi |
| `add-agent-windows.md` | Cara add Wazuh Agent di Windows (GUI + command line) |
| `fim-config.xml` | Konfigurasi FIM untuk user folders (Downloads/Desktop/Documents) |
| `fim-downloads-config.xml` | (Lama) FIM Downloads - lihat fim-config.xml |
| `windows-event-ids.txt` | Daftar Windows Event IDs penting untuk monitoring |
| `08-resource-limits.sh` | Script setting resource limits |
| `dashboard-siem-monitoring.md` | Desain dashboard monitoring SIEM + tahapan pembuatan |

## Simulator Workshop

Simulator wazuh-logtest online: https://simulator.laptopexp.my.id/wazuh_logtest_local.html

- 13 sample log siap pakai (Fortigate, CEF, LEEF, JSON vendor, dll)
- Generate Rules Local (offline) & AI (perlu token)
- Dukungan OS_Regex semantics, decoder offset, if_fts

## Link

- Wazuh docs: https://documentation.wazuh.com
- Wazuh github: https://github.com/wazuh/wazuh
