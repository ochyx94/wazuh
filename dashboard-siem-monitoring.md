# Desain Dashboard Monitoring SIEM Wazuh

## Layout Overview

```
┌──────────────────────────────────────────────────────────────┐
│                   SIEM SECURITY MONITORING                   │
├──────────────────────────────────────────────────────────────┤
│ [TOTAL ALERTS] [CRITICAL ≥12] [HIGH 8-11] [AGENTS ACTIVE]   │
├───────────────────────────┬──────────────────────────────────┤
│ Alerts Over Time (Line)   │ Top 10 MITRE Tactics (Bar)       │
├───────────────────────────┼──────────────────────────────────┤
│ Top 10 Source IP (Bar)    │ Top Rule Descriptions (Pie)      │
├───────────────────────────┴──────────────────────────────────┤
│ LATEST ALERTS: timestamp | level | description | src.ip     │
└──────────────────────────────────────────────────────────────┘
```

## Tahapan Membuat (10 Langkah)

| # | Panel | Tipe | DQL / Aggregation |
|---|-------|------|-------------------|
| 1 | Buat dashboard kosong | - | Dashboard → Create |
| 2 | Total Alerts | Metric | Count |
| 3 | Critical Alerts | Metric | `rule.level>=12` |
| 4 | Alerts Over Time | Line | X:@timestamp, Y:Count |
| 5 | Top MITRE | Bar | Terms: rule.mitre.tactic (10) |
| 6 | Top Source IP | Bar | Terms: src.ip (10) |
| 7 | Latest Alerts | Table | sort @timestamp desc |
| 8 | Top Rules | Pie | Terms: rule.description (10) |
| 9 | Layout | - | drag & drop, resize |
| 10 | Auto-refresh | - | 10 detik |

## DQL Cheat Sheet

| Kebutuhan | DQL |
|-----------|-----|
| Semua alert | `*` |
| Critical | `rule.level>=12` |
| High | `rule.level>=8 and rule.level<12` |
| Auth failure | `rule.groups:authentication_failed` |
| Brute force | `rule.groups:authentication_failures` |
| Per agent | `agent.name:xxx` |

## Color Coding Severity

| Level | Warna |
|-------|-------|
| 0-4 | Green |
| 5-7 | Yellow |
| 8-11 | Orange |
| 12-14 | Red |
| 15+ | Purple |
