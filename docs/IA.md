Berikut adalah templat dokumen Information Architecture (IA) Specification yang siap Anda salin dan gunakan untuk proyek Anda.
________________________________________
Dokumen Spesifikasi Information Architecture (IA)
1. Lembar Informasi Proyek
•	Nama Proyek: [Nama Website / Aplikasi]
•	Versi Dokumen: v1.0
•	Tanggal Pembuatan: [Tanggal]
•	Disusun Oleh: [Nama Anda / Tim UX Designer]
________________________________________
2. Tujuan & Pengguna Target
•	Tujuan Platform: [Tuliskan apa tujuan utama platform ini, misalnya: platform e-learning untuk anak sekolah].
•	Persona Pengguna Utama: [Siapa target utamanya? Misal: Siswa SMA, Guru, Orang Tua].
_____________________________





___________
3. Sitemap (Peta Situs)

## SITEMAP — PENGAMPU / MUROBBI
### (Final, setelah semua diskusi dikunci)

---

### 🔐 LOGIN (Entry Point)
```
Layar Login
├── Tab: Wali Santri (default)
└── Tab: Staff/Guru ← Pengampu masuk sini
    ├── Input: Email + Password
    ├── Rate limiting: 3x gagal → countdown eksponensial
    │   (30 det → 60 det → 120 det dst)
    ├── Pesan error: human-friendly bahasa Indonesia
    ├── Link: "Lupa Password?" → Layar Reset Password via Email
    └── → Redirect: Beranda Pengampu
```

---

### 📱 BOTTOM NAVIGATION
```
[Beranda] [Setoran] [Absensi] [Tikrar] [Lainnya]
                                  ↑
                          Badge jumlah tikrar aktif
```

---

### 1. BERANDA
```
Beranda Pengampu
├── Header
│   ├── Nama Halaqah
│   ├── Unit: Putra / Putri
│   └── Total Santri Aktif
│
├── Banner Kondisional (muncul jika aktif, bisa overlap keduanya)
│   ├── 🟡 Banner Pekan Murajaah (jika jadwal sedang aktif)
│   └── 🟢 Banner Syahrul Quran (jika periode sedang aktif)
│
├── Ringkasan Hari Ini
│   ├── Jumlah santri sudah setor hari ini
│   └── Jumlah santri belum setor hari ini
│
├── Badge Tikrar Aktif
│   └── Jumlah kewajiban tikrar yang belum selesai di halaqah
│
└── Dialog Pengumuman
    └── Popup otomatis jika ada pengumuman baru untuk role pengampu
        └── Tidak muncul lagi untuk pengumuman yang sama (per pengampu)
```

---

### 2. SETORAN
```
Setoran
├── Daftar Santri Halaqah
│   ├── Badge status per santri
│   │   ├── 🔴 Belum Setor
│   │   ├── 🟢 Tuntas Sabak & Sabki
│   │   └── 🟡 Mengulang
│   ├── Info cepat per santri: rata-rata baris + % terhadap target
│   │
│   └── [Klik Santri] → Layar Input Setoran (satu layar, scroll ke bawah)
│       │
│       ├── Header Santri
│       │   ├── Nama Santri
│       │   ├── Grade: Tahsin / Takmil / Tahfiz
│       │   └── Target Baris Harian
│       │       └── [Syahrul Quran aktif] → tampilkan target khusus
│       │           dari konfigurasi koordinator
│       │
│       ├── [KONDISIONAL] Status Manzil Kemarin
│       │   └── Hanya muncul jika Syahrul Quran TIDAK aktif
│       │       └── [Collapsible, default collapsed]
│       │           ├── Surah + Rentang Halaman + Tanggal
│       │           ├── Badge: ✓ Terverifikasi / ⚠ Belum Diverifikasi
│       │           └── Gambar tanda tangan (jika sudah terverifikasi)
│       │
│       ├── Form Sabki
│       │   ├── Input: Surah
│       │   ├── Input: Halaman
│       │   ├── Input: Jumlah Kesalahan
│       │   ├── Toggle: Status Lulus / Mengulang (ditentukan pengampu)
│       │   ├── [Jika mengulang + belum ada tikrar surah sama hari ini]
│       │   │   └── → otomatis buat kewajiban Tikrar Sekolah
│       │   ├── [Sudah diinput hari ini] → otomatis mode Edit
│       │   │   └── tampilkan data yang sudah ada
│       │   └── Tombol Simpan Sabki
│       │
│       ├── Form Sabak
│       │   ├── Input: Surah
│       │   ├── Input: Halaman Mulai
│       │   ├── Input: Halaman Selesai
│       │   ├── Input: Jumlah Baris
│       │   │   └── Indikator % baris vs target harian (real-time)
│       │   ├── Input: Jumlah Kesalahan
│       │   ├── Input: Catatan (opsional)
│       │   ├── Toggle: Status Lulus / Mengulang (ditentukan pengampu)
│       │   ├── [Jika kesalahan > halaman + belum ada tikrar surah sama]
│       │   │   └── → otomatis buat kewajiban Tikrar Sekolah
│       │   ├── [Sudah diinput hari ini] → otomatis mode Edit
│       │   │   └── tampilkan data yang sudah ada
│       │   └── Tombol Simpan Sabak
│       │
│       └── [KONDISIONAL] Form Manzil
│           └── Hanya muncul jika Syahrul Quran TIDAK aktif
│               ├── Input: Surah
│               ├── Input: Rentang Halaman
│               ├── [Sudah diinput hari ini] → otomatis mode Edit
│               └── Tombol Simpan Manzil
│
└── [KONDISIONAL] Jika Pekan Murajaah Aktif
    └── Form setoran harian DIGANTI Form Ujian Murajaah
        ├── Header: materi ujian sesuai kelas santri (7/8/9)
        │   dari konfigurasi koordinator
        ├── Input: Surah
        ├── Input: Halaman
        ├── Input: Jumlah Baris
        ├── Input: Jumlah Kesalahan
        ├── Input: Catatan (opsional)
        ├── Prefix [Pekan Muraja'ah] otomatis ditambahkan di catatan
        ├── [Sudah diinput hari ini] → otomatis mode Edit
        └── Tombol Simpan
```

---

### 3. ABSENSI
```
Absensi
├── Date Picker
│   ├── Default: hari ini
│   └── Bisa pilih tanggal lain (maju/mundur)
│
├── Ringkasan Tanggal Terpilih
│   ├── Total santri
│   ├── Jumlah Hadir
│   └── Jumlah Tidak Hadir
│
├── Daftar Santri
│   ├── Model: exception-based
│   │   └── Tidak ada record = dianggap Hadir
│   │
│   ├── [Santri berstatus Hadir] → Klik → Ubah Status
│   │   ├── Pilih: Sakit / Izin / Alpha
│   │   ├── Input: Keterangan (opsional)
│   │   └── [Pilih Alpha]
│   │       └── → otomatis kirim notifikasi FCM ke orang tua
│   │           ├── Isi notif: nama santri + tanggal + instruksi hubungi pengampu
│   │           └── [Orang tua tidak punya akun] → absensi tetap tersimpan, tanpa error
│   │
│   └── [Santri berstatus Tidak Hadir] → Klik → Edit
│       ├── Ubah status (Sakit ↔ Izin ↔ Alpha)
│       └── Kembalikan ke Hadir (hapus record absensi)
│
└── Catatan: Sakit dan Izin TIDAK memicu notifikasi ke orang tua
```

---

### 4. TIKRAR
```
Tikrar
├── Badge jumlah tikrar aktif (sinkron dengan bottom nav badge)
│
├── Daftar Tikrar Aktif Halaqah
│   ├── Info per tikrar
│   │   ├── Nama Santri
│   │   ├── Surah + Halaman
│   │   ├── Jumlah Pengulangan Wajib
│   │   ├── Tanggal Diberikan
│   │   └── Status Terkini
│   │
│   └── [Klik Tikrar] → Detail & Aksi
│       │
│       ├── [Status: wajib_sekolah]
│       │   └── Tombol: "Selesai di Sekolah"
│       │       └── → status berubah: wajib_sekolah → selesai_sekolah
│       │
│       ├── [Status: selesai_sekolah]
│       │   └── Tombol: "Lanjutkan ke Rumah"
│       │       └── → status berubah: selesai_sekolah → wajib_rumah
│       │
│       └── [Status: wajib_rumah]
│           └── Menunggu konfirmasi orang tua
│               └── Notifikasi real-time masuk saat ortu tandai selesai
│
└── Arsip Tikrar (status: selesai_rumah)
    └── Read-only
        ├── Semua info tikrar
        └── Timestamp konfirmasi orang tua
```

---

### 5. LAINNYA
```
Lainnya
│
├── 👁 Pantau Manzil
│   └── Daftar Santri + Status Manzil Terakhir
│       ├── Info: Surah, Rentang Halaman, Tanggal, Status Verifikasi
│       ├── Gambar tanda tangan (jika sudah terverifikasi)
│       ├── ⚠ Peringatan jika belum ada konfirmasi orang tua
│       └── Notifikasi real-time masuk saat orang tua selesai validasi
│
├── 📋 UKJ (Ujian Kenaikan Juz)
│   ├── Daftar Riwayat UKJ semua santri halaqah
│   │   └── Info: Juz, Tanggal, Kesalahan, Status Lulus/Mengulang,
│   │       Grade 1-5, Status Persetujuan Koordinator
│   │
│   ├── [+ Input UKJ Baru]
│   │   ├── Pilih Santri
│   │   ├── Input: Juz yang diuji
│   │   ├── Input: Tanggal Ujian
│   │   ├── Input: Jumlah Kesalahan
│   │   ├── Toggle: Lulus / Mengulang (ditentukan pengampu)
│   │   ├── Input: Grade 1-5
│   │   └── Submit
│   │       └── → notifikasi ke koordinator ada UKJ baru
│   │
│   └── Status UKJ setelah submit
│       ├── 🟡 Pending → label "Menunggu Persetujuan Koordinator"
│       │   └── Pengampu bisa edit selama masih pending
│       ├── ✅ Disetujui → FCM push notification ke pengampu
│       │   └── Pengampu tidak bisa edit lagi
│       └── ❌ Ditolak → FCM push notification + catatan alasan
│           └── Pengampu bisa input ulang UKJ baru
│
├── 📝 UAS (Ujian Akhir Semester)
│   ├── Pilih Semester: Ganjil / Genap
│   ├── Daftar Santri + Status UAS (sudah/belum diinput)
│   └── [Input / Edit UAS per Santri]
│       ├── Tampilkan total juz hafalan santri
│       ├── [Hafalan ≤ 3 juz]
│       │   └── Semua juz otomatis dipilih, tidak bisa diubah
│       ├── [Hafalan > 3 juz]
│       │   └── Pilih max 3 juz → error jika lebih dari 3
│       ├── Input: Nilai 0-100 per juz
│       ├── Preview nilai akhir rata-rata (real-time)
│       ├── [Semua juz belum dinilai] → nilai akhir = null
│       └── Tombol: Simpan / Edit / Hapus
│
├── 🌟 Nilai Akhlaq
│   ├── [Hanya bisa diakses jika koordinator toggle ON]
│   ├── Label semester aktif (dari konfigurasi koordinator)
│   └── Daftar Santri
│       └── [Input / Edit per Santri]
│           ├── Input: Nilai 0-100
│           ├── Input: Catatan (opsional)
│           └── Satu nilai per santri per semester (update jika sudah ada)
│
├── 🏆 Nilai Akhir Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Daftar Santri → Kartu Breakdown per Santri
│   │   ├── Komponen: Setoran 40% + UAS 40% + Akhlaq 10% + Kehadiran 10%
│   │   ├── Detail setoran: Sabak 30% + Sabki 30% + Manzil 40%
│   │   │   (Manzil tidak memperhitungkan periode Syahrul Quran)
│   │   ├── Kehadiran: hanya Alpha yang mengurangi nilai
│   │   ├── Badge warna nilai akhir
│   │   │   ├── 🟢 ≥85 → Sangat Baik
│   │   │   ├── 🔵 75-84 → Baik
│   │   │   ├── 🟡 60-74 → Cukup
│   │   │   └── 🔴 <60 → Perlu Perhatian
│   │   └── ⚠ Peringatan jika UAS / Akhlaq belum diinput
│   └── Tombol: Ekspor Excel → share sheet (WhatsApp, Drive, Email, dll)
│
├── 📊 Rekap Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Preview Rekap
│   │   ├── Dikelompokkan per pekan (label range: contoh "2-6 Jun")
│   │   ├── Hanya hari kerja: Senin-Jumat dikurangi hari libur
│   │   ├── Per santri: 4 baris
│   │   │   ├── Sabak
│   │   │   ├── Sabki
│   │   │   ├── Manzil
│   │   │   └── Target Tidak Tercapai (hari Sabak < target harian)
│   │   ├── Pekan Syahrul Quran
│   │   │   ├── Label kolom diberi tanda ★
│   │   │   └── Kolom Manzil → "-"
│   │   └── Hanya santri halaqah sendiri
│   └── Tombol: Ekspor Excel (.xlsx) → share sheet
│
├── 📈 Analitik Halaqah
│   ├── Grafik: rata-rata baris setoran per santri
│   ├── Grafik: tren setoran per bulan seluruh halaqah
│   ├── Perbandingan pencapaian antar santri
│   ├── Filter: per santri / periode waktu
│   └── Indikator santri berstatus stagnant
│
├── 📄 Laporan Harian
│   └── Ekspor 30 hari terakhir
│       ├── Format Excel (.xlsx) → share sheet
│       └── Format PDF → share sheet
│           └── Header: identitas sekolah + tanggal cetak
│
├── 💬 Pesan
│   ├── Daftar Santri
│   │   └── Badge unread count per santri
│   └── [Klik Santri] → Thread Pesan dengan Orang Tua
│       ├── Riwayat percakapan kronologis
│       ├── Input + kirim pesan baru kapan saja
│       └── Auto-read saat layar dibuka
│
└── ⚙️ Profil & Pengaturan
    ├── Nama + Email pengampu
    ├── Ganti Password
    │   └── Minimal 8 karakter, huruf + angka
    └── Logout
        └── Hapus semua token dari secure storage
```

---

### 📌 Catatan Kondisional Penting

```
Kondisi                    → Dampak di UI
─────────────────────────────────────────────────────────
Syahrul Quran AKTIF        → Collapsible Manzil Kemarin HILANG
                           → Form Manzil HILANG
                           → Target baris pakai nilai konfigurasi koordinator
                           → Banner ★ di Beranda

Pekan Murajaah AKTIF       → Form Setoran DIGANTI Form Ujian Murajaah
                           → Banner kuning di Beranda

Akhlaq toggle OFF          → Menu Nilai Akhlaq tidak bisa diakses

Tanggal semester belum     → Peringatan di Rekap Semester
dikonfigurasi TU             dan Nilai Akhir Semester

Orang tua tidak punya      → Absensi tetap tersimpan
akun                         tanpa error, tanpa notifikasi

Santri hafalan ≤ 3 juz     → Pilihan juz UAS dikunci otomatis
```

---

Oke dikunci! Sekarang sudah cukup info untuk aku buatkan sitemap lengkapnya.

---

## SITEMAP — WALI SANTRI
### (Final)

---

### 🔐 LOGIN (Entry Point)
```
Layar Login
├── Tab: Wali Santri (DEFAULT) ← Orang tua masuk sini
│   ├── Input: Nomor HP saja
│   ├── Rate limiting: 3x gagal → countdown eksponensial
│   │   (30 det → 60 det → 120 det dst)
│   ├── Pesan error: human-friendly bahasa Indonesia
│   │   └── Hint: "Pastikan nomor HP sesuai yang didaftarkan ke sekolah"
│   └── → Redirect: Beranda Wali Santri
└── Tab: Staff/Guru
    └── (bukan jalur orang tua)
```

---

### 📱 BOTTOM NAVIGATION
```
[Beranda] [Tugas] [Pesan] [Lainnya]
              ↑
    Badge jumlah tugas pending
    (Manzil belum divalidasi + Tikrar wajib rumah)
```

---

### 1. BERANDA
```
Beranda Wali Santri
│
├── Header
│   ├── Salam + Nama Wali
│   └── [KONDISIONAL] Dropdown Pilih Anak
│       └── Hanya muncul jika wali punya lebih dari 1 anak
│           └── Semua data di bawah berubah sesuai anak dipilih
│
├── Kartu Profil Anak
│   ├── Nama Santri
│   ├── Grade: Tahsin / Takmil / Tahfiz
│   ├── Juz yang sedang dihafal (current_juz)
│   └── Total hafalan yang sudah selesai
│
├── Notifikasi Alpha (kondisional)
│   └── Muncul jika ada Alpha yang belum direspons
│       ├── Nama anak + tanggal tidak hadir
│       ├── Instruksi: hubungi pengampu
│       └── Tombol: "Kirim Pesan ke Pengampu"
│           └── → langsung buka thread Pesan
│
├── Status Setoran Hari Ini
│   ├── Sabak: sudah / belum + info surah & baris (jika sudah)
│   └── Sabki: sudah / belum + info surah (jika sudah)
│
├── Grafik Perkembangan
│   └── Grafik setoran per bulan (total baris)
│
└── Riwayat Setoran (scroll ke bawah)
    ├── List: Sabak, Sabki, Manzil
    └── Per item: Surah, Halaman, Baris, Status Lulus/Mengulang, Tanggal
```

---

### 2. TUGAS
```
Tugas
│
├── Header: nama anak yang sedang dipilih
│
├── Section: Manzil
│   ├── [Tidak ada manzil pending] → label "Tidak ada Manzil yang perlu divalidasi"
│   └── [Ada manzil pending] → Daftar Manzil Belum Divalidasi
│       └── [Klik Item Manzil] → Detail & Validasi
│           ├── Info: Surah, Rentang Halaman, Tanggal
│           ├── Widget Tanda Tangan Digital
│           │   ├── Kanvas untuk tanda tangan dengan jari
│           │   ├── Tombol: "Hapus & Ulangi"
│           │   └── Tombol: "Simpan Validasi"
│           │       ├── → Upload tanda tangan ke Supabase Storage
│           │       ├── → Status parent_verified = true
│           │       └── → Notifikasi real-time ke pengampu
│           └── [Sudah divalidasi] → read-only, tombol validasi tidak muncul
│
└── Section: Tikrar
    ├── [KONDISIONAL] Hanya muncul jika ada Tikrar wajib_rumah
    │   └── Jika tidak ada → section ini hidden otomatis
    └── [Ada tikrar wajib_rumah] → Daftar Tikrar
        └── [Klik Item Tikrar] → Detail & Konfirmasi
            ├── Info: Surah, Halaman, Jumlah Pengulangan Wajib, Tanggal
            ├── Tombol: "Tandai Selesai di Rumah"
            │   ├── → Status tikrar: wajib_rumah → selesai_rumah
            │   ├── → Catat timestamp penyelesaian
            │   └── → Notifikasi real-time ke pengampu
            └── [Sudah selesai_rumah] → Arsip read-only
```

---

### 3. PESAN
```
Pesan
│
├── [Wali 1 anak] → langsung buka thread pesan dengan pengampu
└── [Wali lebih dari 1 anak] → Pilih Anak dulu
    └── Thread Pesan per Anak
        ├── Riwayat percakapan kronologis dengan pengampu
        ├── Badge unread dari pengampu
        ├── Input + kirim pesan baru kapan saja
        └── Auto-read saat layar dibuka
```

---

### 4. LAINNYA
```
Lainnya
│
├── 📢 Pengumuman
│   ├── Dialog popup otomatis saat buka app jika ada pengumuman baru
│   │   └── Tidak muncul lagi untuk pengumuman yang sama
│   └── List semua pengumuman yang pernah diterima
│
└── ⚙️ Profil & Pengaturan
    ├── Nama Wali
    ├── Nomor HP terdaftar (tidak bisa diubah sendiri, harus via TU)
    └── Logout
        └── Hapus semua token dari secure storage
```

---

### 📌 Catatan Kondisional Penting
```
Kondisi                        → Dampak di UI
──────────────────────────────────────────────────────
Wali punya > 1 anak            → Dropdown pilih anak muncul di header
                               → Semua data berubah sesuai anak dipilih
                               → Notif Alpha menyebut nama anak eksplisit

Anak kena Alpha                → Banner notif muncul di Beranda
                               → Berisi nama anak + tanggal + tombol pesan

Tidak ada Manzil pending       → Label kosong di section Manzil

Tidak ada Tikrar wajib_rumah   → Section Tikrar hidden otomatis

Manzil sudah divalidasi        → Tombol validasi tidak muncul, read-only

Tikrar sudah selesai_rumah     → Masuk arsip, read-only
```

---

Oke semua sudah dikunci! Langsung aku buatkan.

---

## SITEMAP — STAFF TATA USAHA (TU)
### (Final)

---

### 🔐 LOGIN (Entry Point)
```
Layar Login
├── Tab: Wali Santri (default)
└── Tab: Staff/Guru ← TU masuk sini
    ├── Input: Email + Password
    ├── Rate limiting: 3x gagal → countdown eksponensial
    │   (30 det → 60 det → 120 det dst)
    ├── Pesan error: human-friendly bahasa Indonesia
    ├── Link: "Lupa Password?" → Reset via Email
    └── → Redirect: Beranda Staff TU
        └── [Maintenance Mode aktif] → TU tetap bisa masuk
            semua role lain → layar maintenance
```

---

### 📱 BOTTOM NAVIGATION
```
[Beranda] [Santri & Akun] [Konfigurasi] [Lainnya]
```

---

### 1. BERANDA
```
Beranda Staff TU
│
├── Header
│   └── Sambutan personal: "Halo, [Nama TU]"
│
├── Statistik Sistem
│   ├── Total santri terdaftar
│   ├── Total halaqah aktif
│   ├── Total pengguna semua role
│   ├── Total setoran 30 hari terakhir
│   ├── Info platform backend (Supabase)
│   └── Info backup terakhir (simulasi)
│
└── Dialog Pengumuman
    └── Popup otomatis jika ada pengumuman baru
        untuk role tata_usaha
        └── Tidak muncul lagi untuk pengumuman yang sama
```

---

### 2. SANTRI & AKUN
```
Santri & Akun
│
├── Tab: Santri
│   ├── Fitur Pencarian: nama / NIS
│   ├── Filter: berdasarkan halaqah
│   ├── Daftar Semua Santri
│   │   └── Info per santri: nama, NIS, kelas, grade, halaqah, status
│   │
│   ├── [+ Tambah Santri Baru]
│   │   ├── Input: Nama (wajib)
│   │   ├── Input: NIS (opsional)
│   │   ├── Input: Kelas
│   │   ├── Input: Grade (Tahsin/Takmil/Tahfiz)
│   │   ├── Input: Target Baris Harian
│   │   ├── Pilih: Halaqah
│   │   ├── Input: Nama Orang Tua
│   │   └── Input: Nomor HP Orang Tua
│   │
│   ├── [Klik Santri] → Detail Santri
│   │   ├── Edit Data Santri
│   │   ├── Relasi Orang Tua
│   │   │   ├── Status: sudah terhubung / belum
│   │   │   ├── [Hubungkan ke Akun Wali]
│   │   │   │   └── Pilih dari daftar akun role orangtua
│   │   │   └── [Putuskan Relasi Wali]
│   │   └── [Hapus Santri]
│   │       ├── Dialog konfirmasi
│   │       └── → dicatat di audit_log: HAPUS_SANTRI
│   │
│   └── Catatan Operasional
│       └── Import massal via Supabase Dashboard (bukan via app)
│
├── Tab: Akun Pengguna
│   ├── Fitur Pencarian: nama / email
│   ├── Daftar Semua Pengguna
│   │   └── Info: nama, email, nomor HP, role, status aktif/nonaktif
│   │       └── Label "Login via HP" untuk akun wali
│   │
│   ├── [+ Tambah Akun Pengampu]
│   │   ├── Input: Nama Lengkap (wajib)
│   │   ├── Input: Nomor HP (opsional)
│   │   └── Input: Email (opsional)
│   │       └── Jika kosong → auto-generate dari nama
│   │
│   ├── [+ Tambah Akun Wali Santri]
│   │   ├── Input: Nama Lengkap (wajib)
│   │   ├── Input: Nomor HP (wajib)
│   │   └── Info box live (muncul saat TU isi nomor HP)
│   │       ├── Email yang akan digunakan: {nomor_hp}@jamilurrahman.sch.id
│   │       └── Password default: nomor HP
│   │
│   └── [Klik Pengguna] → Detail & Aksi
│       ├── Aktifkan / Nonaktifkan Akun
│       ├── [Akun Pengampu / Staff]
│       │   └── Reset Password langsung
│       │       ├── Input: Password baru (min 8 karakter, huruf + angka)
│       │       └── Tanpa perlu alur email
│       └── [Akun Wali Santri]
│           ├── Dialog konfirmasi reset
│           └── Reset password → kembali ke nomor HP terdaftar
│
└── Tab: Halaqah
    ├── Daftar Semua Halaqah Aktif
    │   └── Info: nama, unit (Putra/Putri), nama pengampu, jumlah santri
    │
    ├── [+ Tambah Halaqah Baru]
    │   ├── Input: Nama Halaqah
    │   ├── Pilih: Unit (Putra / Putri)
    │   └── Pilih: Pengampu (hanya dari akun role pengampu)
    │
    └── [Klik Halaqah] → Detail & Aksi
        ├── Edit: nama, unit, pengampu
        └── Nonaktifkan Halaqah
```

---

### 3. KONFIGURASI
```
Konfigurasi
│
├── Maintenance Mode
│   ├── Toggle ON/OFF
│   ├── [Toggle → ON] → 2-Step Confirmation
│   │   ├── Step 1: Dialog
│   │   │   "Yakin ingin mengaktifkan Maintenance Mode?
│   │   │   Semua pengguna selain Staff TU tidak dapat
│   │   │   mengakses aplikasi."
│   │   │   → Tombol: Lanjutkan / Batal
│   │   └── Step 2: Dialog
│   │       "Ketik MAINTENANCE untuk mengkonfirmasi"
│   │       ├── Input teks
│   │       └── Tombol: Aktifkan (aktif jika teks = MAINTENANCE)
│   │           ├── → maintenance_mode = true di system_config
│   │           ├── → Semua role lain dialihkan ke layar maintenance
│   │           └── → Dicatat di audit_log: MAINTENANCE_ON
│   │
│   └── [Toggle → OFF]
│       ├── Dialog konfirmasi biasa
│       ├── → maintenance_mode = false di system_config
│       ├── → Layar maintenance otomatis redirect ke login
│       └── → Dicatat di audit_log: MAINTENANCE_OFF
│
├── Tanggal Semester
│   ├── Semester Ganjil
│   │   ├── Input: Tanggal Mulai
│   │   └── Input: Tanggal Selesai
│   ├── Semester Genap
│   │   ├── Input: Tanggal Mulai
│   │   └── Input: Tanggal Selesai
│   ├── Validasi: tanggal selesai harus setelah tanggal mulai
│   └── → Disimpan ke system_config
│       (semester_ganjil_mulai, semester_ganjil_selesai,
│        semester_genap_mulai, semester_genap_selesai)
│
└── Koreksi Data Setoran
    ├── Cari Setoran
    │   ├── Input: Nama Santri
    │   └── Input: Tanggal
    ├── Hasil Pencarian
    │   └── Tabel: tipe (Sabak/Sabki/Manzil), surah,
    │       baris, kesalahan, status
    └── [Hapus Setoran]
        ├── Dialog konfirmasi
        └── Hanya untuk koreksi data entry salah,
            bukan manipulasi nilai
```

---

### 4. LAINNYA
```
Lainnya
│
├── 📋 Audit Log
│   ├── Daftar semua aktivitas kritis seluruh pengguna
│   │   └── Info per entri: waktu, nama pengguna,
│   │       jenis aksi, target, detail
│   │       └── Aksi ditampilkan ramah pembaca
│   │           contoh: APPROVE_UKJ → "✓ Approve UKJ"
│   │
│   ├── Filter
│   │   ├── Filter: nama pengguna
│   │   ├── Filter: jenis aksi (dropdown)
│   │   └── Filter: rentang tanggal (dari - sampai)
│   │
│   ├── Tombol: Reset Semua Filter (1 ketukan)
│   ├── Info: total entri + halaman aktif
│   └── Pagination: 20 entri per halaman
│       └── Tombol navigasi halaman
│
└── ⚙️ Profil & Pengaturan
    ├── Nama + Email TU
    ├── Ganti Password
    │   └── Minimal 8 karakter, huruf + angka
    └── Logout
        └── Hapus semua token dari secure storage
```

---

### 📌 Catatan Kondisional Penting
```
Kondisi                          → Dampak di UI
────────────────────────────────────────────────────────
Maintenance Mode ON              → TU tetap bisa akses penuh
                                 → Semua role lain → layar maintenance
                                 → Layar maintenance polling status berkala
                                 → Saat OFF → redirect ke login otomatis

Tanggal semester belum diisi     → Peringatan muncul di Rekap Semester
                                   dan Nilai Akhir di dashboard pengampu
                                   dan koordinator

Akun wali dibuat                 → Email auto-generate dari nomor HP
                                 → Password default = nomor HP
                                 → Info box live muncul saat TU isi HP

Hapus santri                     → Wajib konfirmasi
                                 → Dicatat di audit_log: HAPUS_SANTRI

Reset password wali              → Wajib konfirmasi
                                 → Kembali ke nomor HP terdaftar

Tambah halaqah                   → Hanya akun role pengampu
                                   yang muncul sebagai pilihan
```

---



Oke semua sudah dikunci! Bottom nav jadi 4 item yang clean:

```
[Beranda] [UKJ] [Konfigurasi] [Lainnya]
```

Langsung aku buatkan!

---

## SITEMAP — KOORDINATOR TAHFIZ
### (Final)

---

### 🔐 LOGIN (Entry Point)
```
Layar Login
├── Tab: Wali Santri (default)
└── Tab: Staff/Guru ← Koordinator masuk sini
    ├── Input: Email + Password
    ├── Rate limiting: 3x gagal → countdown eksponensial
    │   (30 det → 60 det → 120 det dst)
    ├── Pesan error: human-friendly bahasa Indonesia
    ├── Link: "Lupa Password?" → Reset via Email
    └── → Redirect: Beranda Koordinator
```

---

### 📱 BOTTOM NAVIGATION
```
[Beranda] [UKJ] [Konfigurasi] [Lainnya]
              ↑
    Badge jumlah UKJ pending
```

---

### 1. BERANDA
```
Beranda Koordinator
│
├── Header
│   └── Sambutan personal: "Halo, [Nama Koordinator]"
│
├── Ringkasan Program
│   ├── Total santri aktif seluruh halaqah
│   ├── Jumlah santri berstatus stagnant
│   ├── Jumlah UKJ pending (menunggu review)
│   └── Jumlah halaqah aktif
│
├── Notifikasi Real-time
│   └── Alert masuk saat ada santri baru berstatus stagnant
│
└── Dialog Pengumuman
    └── Popup otomatis jika ada pengumuman baru
        untuk role koordinator
        └── Tidak muncul lagi untuk pengumuman yang sama
```

---

### 2. UKJ (Ujian Kenaikan Juz)
```
UKJ
│
├── Badge jumlah UKJ pending (sinkron dengan bottom nav)
│
├── Tab: Pending
│   ├── Daftar semua UKJ belum direview dari seluruh halaqah
│   │   └── Info per UKJ: nama santri, halaqah, juz diuji,
│   │       tanggal, kesalahan, status lulus/mengulang,
│   │       grade 1-5 dari pengampu
│   │
│   └── [Klik UKJ] → Detail & Keputusan
│       ├── Info lengkap UKJ
│       ├── Tombol: "Setujui"
│       │   ├── → approved_by_koordinator = true
│       │   └── → FCM push notification ke pengampu
│       │       "UKJ [nama santri] telah disetujui"
│       └── Tombol: "Tolak"
│           ├── Input: Catatan alasan penolakan (wajib)
│           └── → FCM push notification ke pengampu
│               beserta catatan alasan penolakan
│               └── Pengampu bisa input ulang UKJ baru
│
├── Tab: Disetujui
│   ├── Riwayat semua UKJ yang sudah disetujui
│   ├── Filter: halaqah / juz tertentu
│   └── Info: nama santri, juz, tanggal, grade, halaqah
│
└── Tab: Ditolak
    ├── Riwayat semua UKJ yang ditolak
    ├── Filter: halaqah / juz tertentu
    └── Info: nama santri, juz, tanggal, catatan penolakan
```

---

### 3. KONFIGURASI
```
Konfigurasi
│
├── 📅 Hari Libur
│   ├── Daftar semua hari libur terdaftar
│   │   └── Info: nama, tanggal mulai, tanggal selesai, jenis
│   │       (libur nasional / libur semester / libur tahfiz mendadak)
│   ├── [+ Tambah Hari Libur]
│   │   ├── Input: Nama Hari Libur
│   │   ├── Input: Tanggal Mulai
│   │   ├── Input: Tanggal Selesai
│   │   ├── Pilih: Jenis Libur
│   │   └── Input: Keterangan (opsional)
│   └── [Klik Hari Libur] → Edit / Hapus
│       └── Hapus → dialog konfirmasi terlebih dahulu
│
├── 🌙 Syahrul Quran
│   ├── Daftar semua periode Syahrul Quran
│   │   └── Info: nama periode, tanggal mulai, tanggal selesai,
│   │       target baris per grade
│   ├── [+ Tambah Periode Syahrul Quran]
│   │   ├── Input: Nama Periode
│   │   ├── Input: Tanggal Mulai
│   │   ├── Input: Tanggal Selesai
│   │   └── Target Baris Per Grade
│   │       ├── Tahfiz: default 30 baris/hari (bisa diubah)
│   │       ├── Takmil: default 15 baris/hari (bisa diubah)
│   │       └── Tahsin: opsional (jika kosong → pakai target individu)
│   └── [Klik Periode] → Edit / Hapus
│       └── Hapus → dialog konfirmasi terlebih dahulu
│
├── 📖 Pekan Murajaah
│   ├── Daftar semua jadwal Pekan Murajaah
│   │   └── Info: tanggal mulai, selesai, status (aktif/selesai)
│   ├── [+ Buat Jadwal Pekan Murajaah]
│   │   ├── Input: Tanggal Mulai
│   │   ├── Input: Tanggal Selesai
│   │   ├── Input: Materi Ujian per Kelas
│   │   │   ├── Kelas 7
│   │   │   ├── Kelas 8
│   │   │   └── Kelas 9
│   │   ├── Input: Batas Kesalahan
│   │   └── Input: Deadline Akses
│   │       └── → Notifikasi real-time ke semua pengampu
│   │           saat jadwal baru diaktifkan
│   └── [Klik Jadwal Aktif] → Hentikan Pekan Murajaah
│       ├── Dialog konfirmasi
│       └── → Notifikasi real-time ke semua pengampu
│           saat Pekan Murajaah dihentikan
│
└── 🌟 Penilaian Akhlaq
    ├── Toggle: Aktifkan / Nonaktifkan Input Akhlaq
    │   ├── ON → akhlaq_input_aktif = true di system_config
    │   │   └── Panel nilai akhlaq di dashboard pengampu bisa diakses
    │   └── OFF → akhlaq_input_aktif = false di system_config
    │       └── Panel nilai akhlaq di dashboard pengampu tidak bisa diakses
    └── Input: Label Semester Aktif
        └── Contoh: "Ganjil 2025/2026"
            └── → disimpan ke akhlaq_semester_aktif di system_config
                └── Digunakan semua pengampu sebagai acuan input
```

---

### 4. LAINNYA
```
Lainnya
│
├── 👥 Santri
│   ├── Manajemen Grade
│   │   ├── Daftar semua santri seluruh halaqah
│   │   │   └── Info: nama, grade saat ini, halaqah
│   │   ├── Filter: berdasarkan halaqah tertentu
│   │   └── [Klik Santri] → Ubah Grade
│   │       ├── Pilih grade baru: Tahsin / Takmil / Tahfiz
│   │       ├── Input: Target baris harian baru (wajib)
│   │       ├── Input: Alasan perubahan grade (wajib)
│   │       ├── Modal konfirmasi sebelum disimpan
│   │       └── Simpan
│   │           ├── → Update grade + target_baris di tabel santri
│   │           ├── → Simpan ke tabel riwayat_grade
│   │           └── → Dicatat di audit_log: UBAH_GRADE
│   │
│   └── Stagnant Santri
│       ├── Daftar semua santri berstatus stagnant
│       │   └── Info: nama, halaqah, grade
│       └── [Klik Santri] → Detail & Penanganan
│           ├── [+ Tambah Catatan Stagnasi]
│           │   ├── Pilih penyebab:
│           │   │   keluarga / psikososial / game / lainnya
│           │   ├── Input: Detail penyebab
│           │   └── Input: Langkah korektif
│           ├── Update Status Penanganan
│           │   └── proses → dipantau → selesai
│           └── Riwayat catatan stagnasi kronologis
│
├── 📊 Rekap Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Filter: halaqah tertentu / semua halaqah
│   ├── Preview Rekap
│   │   ├── Dikelompokkan per pekan (label range tanggal)
│   │   ├── Hanya hari kerja: Senin-Jumat dikurangi hari libur
│   │   ├── Per santri: 4 baris
│   │   │   ├── Sabak
│   │   │   ├── Sabki
│   │   │   ├── Manzil
│   │   │   └── Target Tidak Tercapai
│   │   ├── Pekan Syahrul Quran: label ★ + kolom Manzil = "-"
│   │   └── Dikelompokkan per halaqah dengan pemisah jelas
│   └── Tombol: Ekspor Excel (.xlsx) → langsung diunduh
│
├── 🏆 Nilai Akhir Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Filter: halaqah tertentu / semua halaqah
│   ├── Daftar Santri → Kartu Breakdown per Santri
│   │   ├── Komponen: Setoran 40% + UAS 40% + Akhlaq 10% + Kehadiran 10%
│   │   ├── Hasil dikelompokkan per halaqah
│   │   ├── Badge warna nilai akhir
│   │   │   ├── 🟢 ≥85 → Sangat Baik
│   │   │   ├── 🔵 75-84 → Baik
│   │   │   ├── 🟡 60-74 → Cukup
│   │   │   └── 🔴 <60 → Perlu Perhatian
│   │   └── ⚠ Peringatan jika UAS / Akhlaq belum diinput
│   └── Tombol: Ekspor Excel → dikelompokkan per halaqah
│
├── 📈 Analitik Program
│   ├── Grafik: perbandingan rata-rata baris antar halaqah
│   ├── Grafik: tren setoran per bulan seluruh program
│   ├── Grafik: perbandingan santri lulus UKJ antar halaqah
│   ├── Distribusi grade: Tahsin / Takmil / Tahfiz
│   └── Filter: halaqah / periode waktu tertentu
│
└── ⚙️ Profil & Pengaturan
    ├── Nama + Email koordinator
    ├── Ganti Password
    │   └── Minimal 8 karakter, huruf + angka
    └── Logout
        └── Hapus semua token dari secure storage
```

---

### 📌 Catatan Kondisional Penting
```
Kondisi                          → Dampak di UI
────────────────────────────────────────────────────────
UKJ baru masuk dari pengampu     → Badge UKJ pending bertambah
                                 → Notifikasi real-time ke koordinator

UKJ disetujui                    → FCM push notification ke pengampu
                                 → Pindah ke tab Disetujui

UKJ ditolak                      → FCM + catatan alasan ke pengampu
                                 → Pengampu bisa input ulang

Santri baru stagnant             → Notifikasi real-time ke koordinator
                                 → Muncul di daftar Stagnant Santri

Pekan Murajaah dibuat            → Notifikasi real-time ke semua pengampu
                                 → Banner muncul di beranda pengampu

Pekan Murajaah dihentikan        → Notifikasi real-time ke semua pengampu
                                 → Banner hilang dari beranda pengampu

Syahrul Quran aktif              → Manzil tidak diperhitungkan di rekap
                                 → Target baris pakai nilai konfigurasi
                                 → Label ★ di rekap semester

Akhlaq toggle OFF                → Panel akhlaq pengampu tidak bisa diakses

Tanggal semester belum diisi     → Peringatan di Rekap + Nilai Akhir
```

---

Semua sudah dikunci! Langsung aku buatkan.

---

## SITEMAP — KEPALA SEKOLAH & KOMITE
### (Final)

---

### 🔐 LOGIN (Entry Point)
```
Layar Login
├── Tab: Wali Santri (default)
└── Tab: Staff/Guru ← Kepala Sekolah masuk sini
    ├── Input: Email + Password
    ├── Rate limiting: 3x gagal → countdown eksponensial
    │   (30 det → 60 det → 120 det dst)
    ├── Pesan error: human-friendly bahasa Indonesia
    ├── Link: "Lupa Password?" → Reset via Email
    └── → Redirect: Beranda Kepala Sekolah
```

---

### 📱 BOTTOM NAVIGATION
```
[Beranda] [Santri] [Laporan] [Lainnya]
```

---

### 1. BERANDA
```
Beranda Kepala Sekolah
│
├── Header
│   └── Sambutan personal: "Halo, [Nama Kepala Sekolah]"
│
├── Ringkasan Eksekutif (semua read-only)
│   ├── Total santri aktif seluruh halaqah
│   ├── Jumlah santri berstatus stagnant
│   ├── Jumlah UKJ sudah lulus & disetujui koordinator
│   ├── Total setoran tercatat dalam sistem
│   └── Jumlah modul ajar tersedia
│
└── Dialog Pengumuman
    └── Popup otomatis jika ada pengumuman baru
        untuk role kepala_sekolah
        └── Tidak muncul lagi untuk pengumuman yang sama
```

---

### 2. SANTRI
```
Santri (semua read-only)
│
├── Daftar Lengkap Semua Santri Seluruh Halaqah
│   └── Info per santri: nama, grade, kelas,
│       status aktif/stagnant, halaqah
│
├── Filter
│   ├── Filter: berdasarkan halaqah
│   ├── Filter: berdasarkan status (aktif / stagnant)
│   └── Filter: berdasarkan grade (Tahsin / Takmil / Tahfiz)
│
├── [Klik Santri Stagnant] → Info Stagnasi
│   └── Penyebab + status penanganan (read-only)
│       └── Tidak bisa mengubah data apapun
│
└── 📈 Analitik Program
    ├── Grafik: perbandingan rata-rata baris antar halaqah
    │   └── Data historis keseluruhan (tidak dibatasi 30 hari)
    ├── Grafik: tren setoran per bulan seluruh program
    ├── Distribusi grade: Tahsin / Takmil / Tahfiz (visual)
    ├── Perbandingan santri lulus UKJ antar halaqah
    └── Filter: halaqah / unit (Putra / Putri)
```

---

### 3. LAPORAN
```
Laporan
│
├── Tab: Rekap Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Filter: halaqah tertentu / semua halaqah
│   ├── Preview Rekap (read-only)
│   │   ├── Dikelompokkan per pekan (label range tanggal)
│   │   ├── Hanya hari kerja: Senin-Jumat dikurangi hari libur
│   │   ├── Per santri: 4 baris
│   │   │   ├── Sabak
│   │   │   ├── Sabki
│   │   │   ├── Manzil
│   │   │   └── Target Tidak Tercapai
│   │   ├── Pekan Syahrul Quran: label ★ + kolom Manzil = "-"
│   │   └── Dikelompokkan per halaqah dengan pemisah jelas
│   └── Tombol: Ekspor Excel (.xlsx) → langsung diunduh
│
├── Tab: Nilai Akhir Semester
│   ├── Pilih Semester: Ganjil / Genap
│   ├── ⚠ Peringatan jika tanggal semester belum dikonfigurasi TU
│   ├── Filter: halaqah tertentu / semua halaqah
│   ├── Daftar Santri → Kartu Breakdown per Santri (read-only)
│   │   ├── Komponen: Setoran 40% + UAS 40% + Akhlaq 10% + Kehadiran 10%
│   │   ├── Hasil dikelompokkan per halaqah
│   │   ├── Badge warna nilai akhir
│   │   │   ├── 🟢 ≥85 → Sangat Baik
│   │   │   ├── 🔵 75-84 → Baik
│   │   │   ├── 🟡 60-74 → Cukup
│   │   │   └── 🔴 <60 → Perlu Perhatian
│   │   └── ⚠ Peringatan jika UAS / Akhlaq belum diinput
│   └── Tombol: Ekspor Excel → dikelompokkan per halaqah
│
└── Tab: Dokumen Laporan
    ├── Filter: tipe (mingguan/bulanan/semesteran/tahunan) / status
    ├── Daftar Laporan Tersedia
    │   └── Info: judul, tipe, periode,
    │       status (draf / divalidasi / diarsip)
    └── [Klik Laporan] → Detail & Aksi
        ├── Tombol: Unduh Laporan
        ├── [Status: draf]
        │   └── Tombol: "Validasi Laporan" ← satu-satunya write action
        │       ├── → Status berubah: draf → divalidasi
        │       └── → Catat nama Kepala Sekolah + waktu validasi
        └── [Status: divalidasi]
            └── Tombol: "Arsipkan Laporan" ← satu-satunya write action
                └── → Status berubah: divalidasi → diarsip
```

---

### 4. LAINNYA
```
Lainnya
│
├── 📚 Modul Ajar
│   ├── Daftar semua modul yang tersedia
│   │   └── Info: judul, ukuran file, versi
│   │       └── Hanya modul dengan akses role kepala_sekolah
│   └── [Klik Modul] → Unduh
│       └── → Dicatat di log_unduh_modul:
│           modul diunduh + user + waktu unduh
│
└── ⚙️ Profil & Pengaturan
    ├── Nama + Email Kepala Sekolah
    ├── Ganti Password
    │   └── Minimal 8 karakter, huruf + angka
    └── Logout
        └── Hapus semua token dari secure storage
```

---

### 📌 Catatan Kondisional Penting
```
Kondisi                          → Dampak di UI
────────────────────────────────────────────────────────
Semua tampilan data              → Read-only
                                 → Tidak ada tombol edit/hapus
                                 → Kecuali validasi & arsip laporan

Tanggal semester belum diisi     → Peringatan di Rekap + Nilai Akhir

Laporan status draf              → Tombol Validasi muncul

Laporan status divalidasi        → Tombol Arsipkan muncul

Laporan status diarsip           → Hanya bisa diunduh, tidak ada aksi lain

Modul tanpa akses kepala_sekolah → Tidak muncul di daftar
```

---






























________________________________________
4. Sistem Pelabelan & Taksonomi (Labeling & Taxonomy)
(Gunakan tabel ini untuk memastikan konsistensi istilah di seluruh aplikasi)
Kategori Konten	Nama Label Menu (Bahasa Indonesia)	Nama Label Menu (Bahasa Inggris)	Deskripsi Konten di Dalamnya
Keranjang Belanja	Keranjang	Cart	Halaman untuk melihat barang yang siap dibeli
Pengaturan Akun	Pengaturan	Settings	Halaman ubah kata sandi dan privasi
[Contoh Kategori]	[Contoh Label]	[Contoh Label]	[Contoh Deskripsi]
________________________________________

________________________________________
6. Inventaris Konten (Content Inventory)
(Daftar elemen atau informasi wajib yang harus ada di halaman-halaman kunci)
•	Elemen Wajib di Homepage:
o	Banner Promosi / Hero Section.
o	Bilah Pencarian (Search Bar).
o	Rekomendasi Konten Terpopuler.
o	Tombol Log In / Sign Up.
•	Elemen Wajib di Halaman Detail:
o	Judul Konten / Nama Produk.
o	Deskripsi Lengkap.
o	Tombol Aksi Utama (CTA - Call to Action).
________________________________________
Agar templat di atas bisa langsung diisi dengan konten yang relevan, beri tahu saya:
•	Apakah platform ini berupa E-commerce, Portofolio, SaaS, atau Blog/Media Massa?
•	Berapa banyak kategori utama yang rencananya akan ada di menu navigasi Anda?
Saya bisa langsung mengisikan draf sitemap dan user flow pertamanya untuk Anda.



