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
________________________________________
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


________________________________________
4. Sistem Pelabelan & Taksonomi (Labeling & Taxonomy)
(Gunakan tabel ini untuk memastikan konsistensi istilah di seluruh aplikasi)
Kategori Konten	Nama Label Menu (Bahasa Indonesia)	Nama Label Menu (Bahasa Inggris)	Deskripsi Konten di Dalamnya
Keranjang Belanja	Keranjang	Cart	Halaman untuk melihat barang yang siap dibeli
Pengaturan Akun	Pengaturan	Settings	Halaman ubah kata sandi dan privasi
[Contoh Kategori]	[Contoh Label]	[Contoh Label]	[Contoh Deskripsi]
________________________________________
5. Alur Pengguna Utama (User Flow)
(Tuliskan langkah-langkah logika yang dilalui pengguna untuk menyelesaikan tugas tertentu)
Skenario 1: [Contoh: Pengguna melakukan pembelian barang]
1.	Pengguna membuka Homepage.
2.	Pengguna mencari produk melalui fitur Pencarian atau menu Katalog.
3.	Pengguna masuk ke halaman Detail Produk dan klik tombol "Tambah ke Keranjang".
4.	Pengguna dialihkan ke halaman Keranjang dan menekan tombol "Checkout".
5.	Pengguna mengisi data pengiriman dan menyelesaikan Pembayaran.
6.	Sistem menampilkan halaman Konfirmasi Sukses.
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



