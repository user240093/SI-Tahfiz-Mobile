# SI-Tahfiz Mobile 📖

Aplikasi mobile manajemen program Tahfiz Al-Qur'an untuk MTs TQ Jamilurrahman Yogyakarta — mendukung **SDG 4: Pendidikan Berkualitas**.

---

## 📌 Ringkasan Proyek

| Item | Detail |
|---|---|
| Nama Aplikasi | SI-Tahfiz Mobile |
| SDGs Utama | SDG 4 — Quality Education (Pendidikan Berkualitas) |
| SDGs Pendukung | SDG 9 — Industry & Innovation (Digitalisasi Proses) |
| Mata Kuliah | Teknologi Mobile |
| NIM | 2400016067 |
| NIM | 2400016089 |
| NIM | 2400016070 |
| Tech Stack | Flutter, Supabase (PostgreSQL, Auth, Storage) |

---

## 🎯 Latar Belakang Masalah

**What** — Pencatatan setoran hafalan santri masih manual (buku fisik/spreadsheet terpisah per pengampu).

**Who** — Santri, pengampu, koordinator tahfiz, wali santri, kepala sekolah.

**Where** — MTs TQ Jamilurrahman, Yogyakarta.

**When** — Setiap hari saat setoran berlangsung, dan setiap akhir semester saat rekapitulasi nilai.

**Why** — Risiko kehilangan data historis, rekapitulasi nilai rawan salah hitung, dan orang tua tidak punya visibilitas real-time terhadap progres hafalan anak.

**How** — Membangun aplikasi mobile berbasis peran (RBAC) yang mengintegrasikan pencatatan setoran, evaluasi, dan komunikasi sekolah–orang tua dalam satu sistem digital.

---

## 👥 Sasaran Pengguna

| Aktor | Peran Utama |
|---|---|
| Pengampu / Murobbi | Mencatat setoran harian & menilai ujian |
| Koordinator Tahfiz | Memantau progres & menyetujui kelulusan ujian |
| Wali Santri | Memantau hafalan anak & validasi setoran via tanda tangan digital |
| Staff Tata Usaha (TU) | Mengelola data master santri & maintenance sistem |
| Kepala Sekolah | Melihat laporan & rekapitulasi performa program |

---

## ⚙️ Fitur Utama

1. **Manajemen Setoran Harian** — input Sabak (hafalan baru), Sabki (review kemarin), Manzil (review jangka panjang), dengan anti-duplikasi entri.
2. **Dashboard Role-Based (RBAC)** — antarmuka khusus per aktor dengan aksen visual pembeda.
3. **Modul Ujian & Nilai Otomatis** — UKJ & UAS dengan kalkulasi nilai akhir semester otomatis (Setoran 40%, UAS 40%, Akhlaq 10%, Kehadiran 10%).
4. **Tanda Tangan Digital Wali Santri** — validasi setoran Manzil via kanvas tanda tangan jari, tersimpan ke Supabase Storage.
5. **Ekspor Laporan** — unduh laporan progres santri dalam format `.xlsx` dan `.pdf`.
6. **Program Tikrar Otomatis** — alur pengulangan hafalan (wajib di sekolah → selesai di sekolah → wajib di rumah → selesai di rumah) saat santri melebihi ambang batas kesalahan.
7. **Audit Log** — pencatatan append-only untuk setiap aksi kritis (perubahan grade, penghapusan record).

---

## 🏗️ Arsitektur Sistem

```
[ Flutter Mobile App ]
        │
        ▼
[ Supabase Auth ]──────[ Row Level Security (RLS) ]
        │
        ▼
[ Supabase PostgreSQL ]──[ Supabase Storage (Tanda Tangan Digital) ]
        │
        ▼
[ Export Engine ] → .xlsx / .pdf
```

---

## 🗓️ Linimasa Internal Kelompok

| Minggu | Agenda | Target Output |
|---|---|---|
| Ke-7 | Ideasi & pembentukan tim | SDGs, masalah, sasaran, rencana fitur |
| Ke-8 | Desain & arsitektur | User flow, mockup, tech-stack, draft poster |
| Ke-9 | Development | Setoran harian, RBAC dashboard, integrasi DB |
| Ke-10 | Finalisasi | Modul ujian, tanda tangan digital, fixing bug, poster final |
| Responsi | Demo & presentasi | Aplikasi running, demo live, Q&A |

---

## 🚀 Rencana Pengembangan ke Depan

- [ ] Setup project Flutter + koneksi Supabase
- [ ] Implementasi autentikasi multi-role (TU, Koordinator, Pengampu, Wali, Kepala Sekolah)
- [ ] Desain skema database PostgreSQL + RLS policy per role
- [ ] Build modul Manajemen Setoran Harian
- [ ] Build modul Tikrar otomatis
- [ ] Build modul UKJ & UAS
- [ ] Integrasi Kanvas Tanda Tangan Digital + Supabase Storage
- [ ] Build sistem perhitungan Nilai Akhir Semester otomatis
- [ ] Fitur ekspor laporan (.xlsx, .pdf)
- [ ] Implementasi Maintenance Mode & Audit Log
- [ ] Testing & bug fixing
- [ ] Finalisasi poster & persiapan demo responsi

---

## 🛠️ Tech Stack

- **Frontend:** Flutter
- **Backend:** Supabase (PostgreSQL, Auth, Storage, RLS)
- **Version Control:** Git & GitHub
- **Design Tools:** Figma / Canva (mockup)

---

## 📂 Status

🚧 *Project sedang dalam tahap ideasi — Minggu ke-7*