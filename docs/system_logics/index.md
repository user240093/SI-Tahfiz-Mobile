# System Logic Index

Document Version: v1.0
Project: [Nama Proyek]
Product: SI-Tahfiz
Status: Draft
Last Updated: [Tanggal]
Author: [Nama]
Source: user_flows/index.md, srs.md

---

## Catatan Arsitektur

- **Client:** Flutter (Dart) — mobile-first, target Android & iOS
- **Backend:** Supabase SDK langsung dari Flutter client (`supabase_flutter` package)
- **Auth:** `Supabase.instance.client.auth` — session dikelola otomatis oleh Supabase Auth
- **Query:** `Supabase.instance.client.from('table').select/insert/update/delete`
- **Security:** RLS (Row Level Security) policies di level database
- **Realtime:** `Supabase.instance.client.channel()` untuk notifikasi Alpha
- **Navigasi:** Named route via `Navigator.pushReplacementNamed()` atau `GoRouter`
- **Operasi Admin:** Supabase Edge Function (Deno) menggunakan `SERVICE_ROLE_KEY` — menggantikan Server Action karena Flutter tidak memiliki server layer

---

## Keterangan Kompleksitas

| Label | Arti |
|-------|------|
| 🟢 Simple | Operasi CRUD tunggal, tidak ada logika kalkulasi |
| 🟡 Medium | Melibatkan beberapa tabel atau ada validasi bisnis |
| 🔴 Complex | Kalkulasi otomatis, multi-tabel, atau ada side effect ke tabel lain |

---

## Autentikasi & Akun

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-001 | Login Email | sys_uc_001.md | TU, Koordinator, Pengampu, Kepsek | 🟢 Simple | profiles |
| UC-002 | Login Nomor HP | sys_uc_002.md | Orang Tua | 🟢 Simple | orang_tua |
| UC-003 | Logout | sys_uc_003.md | Semua Role | 🟢 Simple | — |
| UC-034 | Edit Profil & Ganti Password | sys_uc_034.md | Semua Role | 🟢 Simple | profiles, orang_tua |

---

## Staff TU

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-004 | CRUD Akun Pengguna | sys_uc_004.md | Staff TU | 🟡 Medium | profiles, orang_tua, audit_trail |
| UC-005 | CRUD Data Santri | sys_uc_005.md | Staff TU | 🟡 Medium | santri, audit_trail |
| UC-006 | CRUD Halaqah | sys_uc_006.md | Staff TU | 🟡 Medium | halaqah, santri, audit_trail |
| UC-007 | Konfigurasi Tanggal Semester | sys_uc_007.md | Staff TU | 🟢 Simple | konfigurasi |
| UC-008 | Konfigurasi Bobot Nilai Akhir | sys_uc_008.md | Staff TU | 🟡 Medium | konfigurasi |
| UC-009 | Konfigurasi Hari Libur | sys_uc_009.md | Staff TU | 🟢 Simple | hari_libur |
| UC-010 | Kelola Audit Trail | sys_uc_010.md | Staff TU | 🟡 Medium | audit_trail |
| UC-011 | Kelola Berita Halaman Login | sys_uc_011.md | Staff TU | 🟢 Simple | berita_login |
| UC-012 | Aktifkan/Nonaktifkan Maintenance Mode | sys_uc_012.md | Staff TU | 🟡 Medium | konfigurasi |

---

## Pengampu

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-013 | Input Setoran Sabak & Sabki | sys_uc_013.md | Pengampu | 🔴 Complex | setoran, tikrar, syahrul_quran |
| UC-014 | Input Absensi Santri | sys_uc_014.md | Pengampu | 🟡 Medium | absensi |
| UC-015 | Kelola Tikrar di Sekolah | sys_uc_015.md | Pengampu | 🟡 Medium | tikrar |
| UC-016 | Lihat Status Manzil Santri | sys_uc_016.md | Pengampu | 🟢 Simple | setoran |
| UC-017 | Input Hasil UKJ | sys_uc_017.md | Pengampu | 🟡 Medium | ukj, audit_trail |
| UC-018 | Input Nilai UAS Per Juz | sys_uc_018.md | Pengampu | 🔴 Complex | uas, uas_detail |
| UC-019 | Input Nilai Akhlaq | sys_uc_019.md | Pengampu | 🟢 Simple | akhlaq, konfigurasi |
| UC-020 | Kirim & Balas Pesan ke Orang Tua | sys_uc_020.md | Pengampu | 🟡 Medium | percakapan, pesan |

---

## Orang Tua

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-021 | Input Setoran Manzil | sys_uc_021.md | Orang Tua | 🟡 Medium | setoran, syahrul_quran |
| UC-022 | Validasi Tikrar Rumah | sys_uc_022.md | Orang Tua | 🟡 Medium | tikrar |
| UC-023 | Switch Antar Anak | sys_uc_023.md | Orang Tua | 🟢 Simple | santri, orang_tua |
| UC-024 | Kirim & Balas Pesan ke Pengampu | sys_uc_024.md | Orang Tua | 🟡 Medium | percakapan, pesan |

---

## Koordinator

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-025 | Approve / Reject UKJ | sys_uc_025.md | Koordinator | 🟡 Medium | ukj, audit_trail |
| UC-026 | Kelola Periode Syahrul Quran | sys_uc_026.md | Koordinator | 🟡 Medium | syahrul_quran |
| UC-027 | Kelola Pekan Murajaah | sys_uc_027.md | Koordinator | 🟡 Medium | pekan_murajaah, target_murajaah |
| UC-028 | Ubah Grade Santri | sys_uc_028.md | Koordinator | 🟢 Simple | santri, target_grade |
| UC-029 | Buat & Kelola Pengumuman | sys_uc_029.md | Koordinator | 🟡 Medium | pengumuman, pengumuman_read |
| UC-030 | Download Rekap Excel | sys_uc_030.md | Koordinator | 🔴 Complex | setoran, absensi, uas, akhlaq, hari_libur, syahrul_quran, pekan_murajaah, konfigurasi |
| UC-031 | Aktifkan / Nonaktifkan Fitur Akhlaq | sys_uc_031.md | Koordinator | 🟢 Simple | konfigurasi |

---

## Kepala Sekolah

| UC ID | Nama | File | Aktor | Kompleksitas | Tabel Utama |
|-------|------|------|-------|--------------|-------------|
| UC-032 | Lihat Dashboard Statistik | sys_uc_032.md | Kepala Sekolah | 🟡 Medium | santri, halaqah, setoran, absensi |
| UC-033 | Download Rekap Excel | sys_uc_033.md | Kepala Sekolah | 🔴 Complex | setoran, absensi, uas, akhlaq, hari_libur, syahrul_quran, pekan_murajaah, konfigurasi |

---

## Ringkasan

| Kompleksitas | Jumlah |
|--------------|--------|
| 🔴 Complex | 4 |
| 🟡 Medium | 18 |
| 🟢 Simple | 12 |
| **Total** | **34** |

---

## Urutan Prioritas Implementasi

Urutan ini disarankan untuk vibe coding agar fitur inti bisa diuji lebih awal:

### Fase 1 — Fondasi (harus ada sebelum fitur lain)
1. UC-001: Login Email
2. UC-002: Login Nomor HP
3. UC-003: Logout
4. UC-004: CRUD Akun Pengguna
5. UC-005: CRUD Data Santri
6. UC-006: CRUD Halaqah
7. UC-007: Konfigurasi Tanggal Semester

### Fase 2 — Fitur Harian (core workflow)
8. UC-013: Input Setoran Sabak & Sabki
9. UC-021: Input Setoran Manzil
10. UC-014: Input Absensi Santri
11. UC-015: Kelola Tikrar di Sekolah
12. UC-022: Validasi Tikrar Rumah
13. UC-016: Lihat Status Manzil

### Fase 3 — Ujian & Penilaian
14. UC-017: Input Hasil UKJ
15. UC-025: Approve / Reject UKJ
16. UC-018: Input Nilai UAS Per Juz
17. UC-019: Input Nilai Akhlaq
18. UC-031: Aktifkan / Nonaktifkan Fitur Akhlaq
19. UC-028: Ubah Grade Santri

### Fase 4 — Periode Khusus
20. UC-026: Kelola Periode Syahrul Quran
21. UC-027: Kelola Pekan Murajaah

### Fase 5 — Rekap & Dashboard
22. UC-030: Download Rekap Excel (Koordinator)
23. UC-033: Download Rekap Excel (Kepsek)
24. UC-032: Lihat Dashboard Statistik
25. UC-008: Konfigurasi Bobot Nilai Akhir
26. UC-009: Konfigurasi Hari Libur

### Fase 6 — Komunikasi & Pengumuman
27. UC-020: Kirim & Balas Pesan ke Orang Tua
28. UC-024: Kirim & Balas Pesan ke Pengampu
29. UC-029: Buat & Kelola Pengumuman
30. UC-011: Kelola Berita Halaman Login

### Fase 7 — Sistem & Profil
31. UC-034: Edit Profil & Ganti Password
32. UC-010: Kelola Audit Trail
33. UC-012: Aktifkan/Nonaktifkan Maintenance Mode
34. UC-023: Switch Antar Anak