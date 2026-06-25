
## Skenario Multi-Aktor

---

### SKENARIO 1 — Setoran Manzil → Validasi Orang Tua

```
LANGKAH PENGAMPU:
1. Pengampu membuka layar Setoran
2. Pilih santri dari daftar
3. Scroll ke Form Manzil
4. Input: Surah + Rentang Halaman
5. Simpan Manzil

LANGKAH SISTEM:
6. Sistem menyimpan record Manzil
   dengan parent_verified = false
7. Sistem mengirim notifikasi real-time
   ke akun wali santri:
   "Ada Manzil baru yang perlu divalidasi"

LANGKAH WALI SANTRI:
8. Wali membuka notifikasi → masuk app
9. Buka tab Tugas → Section Manzil
10. Klik item Manzil yang pending
11. Lihat info: Surah + Rentang Halaman + Tanggal
12. Tanda tangan di kanvas digital menggunakan jari
13. Jika tidak puas → klik "Hapus & Ulangi"
14. Klik "Simpan Validasi"

LANGKAH SISTEM:
15. Sistem upload tanda tangan ke Supabase Storage
16. Sistem simpan URL tanda tangan ke kolom
    parent_signature di tabel setoran
17. Sistem update parent_verified = true
18. Sistem kirim notifikasi real-time ke pengampu:
    "Manzil [nama santri] sudah divalidasi orang tua"

LANGKAH PENGAMPU:
19. Pengampu terima notifikasi real-time
20. Buka Pantau Manzil → lihat status ✓ Terverifikasi
21. Bisa lihat gambar tanda tangan orang tua
```

---

### SKENARIO 2 — Tikrar Sekolah → Rumah

```
LANGKAH SISTEM (otomatis saat input setoran):
1. Sistem deteksi kesalahan Sabki/Sabak
   melebihi batas
2. Sistem otomatis buat kewajiban Tikrar
   dengan status: wajib_sekolah

LANGKAH PENGAMPU:
3. Pengampu buka tab Tikrar
4. Lihat daftar Tikrar aktif
5. Klik Tikrar santri terkait
6. Klik "Selesai di Sekolah"

LANGKAH SISTEM:
7. Sistem update status:
   wajib_sekolah → selesai_sekolah

LANGKAH PENGAMPU:
8. Pengampu klik "Lanjutkan ke Rumah"

LANGKAH SISTEM:
9. Sistem update status:
   selesai_sekolah → wajib_rumah
10. Sistem kirim notifikasi real-time ke wali:
    "Ada kewajiban Tikrar yang perlu
    diselesaikan di rumah"

LANGKAH WALI SANTRI:
11. Wali buka app → tab Tugas
12. Section Tikrar muncul (sebelumnya hidden)
13. Klik item Tikrar
14. Lihat info: Surah, Halaman,
    Jumlah Pengulangan Wajib, Tanggal
15. Santri mengerjakan Tikrar di rumah
16. Wali klik "Tandai Selesai di Rumah"

LANGKAH SISTEM:
17. Sistem update status:
    wajib_rumah → selesai_rumah
18. Sistem catat timestamp penyelesaian
19. Sistem kirim notifikasi real-time ke pengampu:
    "Tikrar [nama santri] sudah selesai di rumah"

LANGKAH PENGAMPU:
20. Terima notifikasi real-time
21. Buka Tikrar → lihat di Arsip
22. Lihat timestamp konfirmasi orang tua
23. Section Tikrar di app wali
    kembali hidden otomatis
```

---

### SKENARIO 3 — Absensi Alpha → Notifikasi Orang Tua

```
LANGKAH PENGAMPU:
1. Pengampu buka tab Absensi
2. Tanggal default: hari ini
3. Lihat daftar santri (semua default Hadir)
4. Klik santri yang tidak hadir tanpa keterangan
5. Pilih status: Alpha
6. Input keterangan (opsional)
7. Simpan

LANGKAH SISTEM:
8. Sistem simpan record absensi
   dengan status Alpha
9. Sistem cek apakah santri punya
   akun orang tua terhubung
   ├── [Tidak punya akun orang tua]
   │   └── Absensi tersimpan, tidak ada notifikasi
   │       tidak ada error
   └── [Punya akun orang tua]
       ├── Sistem insert notifikasi ke tabel notifikasi
       └── Sistem kirim FCM push notification
           ke perangkat Android wali
           (meskipun app tidak sedang dibuka)
           Isi: nama santri + tanggal +
           instruksi hubungi pengampu

LANGKAH WALI SANTRI:
10. Wali terima push notification FCM
    di perangkat Android
11. Wali buka app → Beranda
12. Banner Alpha muncul di beranda
    isi: nama anak + tanggal + instruksi
13. Wali klik "Kirim Pesan ke Pengampu"
    → langsung buka thread Pesan

LANGKAH WALI SANTRI (opsional):
14. Wali ketik & kirim pesan ke pengampu
    menjelaskan kondisi anak

LANGKAH PENGAMPU:
15. Terima pesan dari wali
    di tab Lainnya → Pesan
16. Badge unread muncul di menu Pesan
17. Pengampu buka thread → balas pesan wali
```

---

### SKENARIO 4 — UKJ → Review Koordinator → Feedback ke Pengampu

```
LANGKAH PENGAMPU:
1. Pengampu buka Lainnya → UKJ
2. Klik "+ Input UKJ Baru"
3. Pilih santri
4. Input: Juz yang diuji
5. Input: Tanggal ujian
6. Input: Jumlah kesalahan
7. Toggle: Lulus / Mengulang
8. Input: Grade 1-5
9. Submit

LANGKAH SISTEM:
10. Sistem simpan UKJ dengan
    approved_by_koordinator = false
11. Label "Menunggu Persetujuan Koordinator"
    muncul di riwayat UKJ pengampu
12. Sistem kirim notifikasi real-time
    ke koordinator:
    "Ada UKJ baru dari [nama halaqah]
    menunggu review"
13. Badge UKJ pending di bottom nav
    koordinator bertambah

LANGKAH KOORDINATOR:
14. Koordinator terima notifikasi
15. Buka tab UKJ → Tab Pending
16. Klik UKJ yang masuk
17. Review info lengkap UKJ
    │
    ├── [Keputusan: SETUJUI]
    │   18a. Klik "Setujui"
    │
    └── [Keputusan: TOLAK]
        18b. Klik "Tolak"
        18c. Input catatan alasan penolakan (wajib)
        18d. Konfirmasi

LANGKAH SISTEM (jika DISETUJUI):
19a. Sistem update approved_by_koordinator = true
20a. UKJ pindah ke tab Disetujui
21a. Sistem kirim FCM push notification
     ke pengampu:
     "UKJ [nama santri] - Juz [X]
     telah disetujui koordinator ✅"

LANGKAH SISTEM (jika DITOLAK):
19b. UKJ pindah ke tab Ditolak
20b. Sistem kirim FCM push notification
     ke pengampu beserta catatan alasan:
     "UKJ [nama santri] - Juz [X]
     ditolak koordinator ❌
     Alasan: [catatan koordinator]"

LANGKAH PENGAMPU (setelah notif):
├── [Jika DISETUJUI]
│   21a. Terima FCM push notification
│   22a. Buka riwayat UKJ → status Disetujui ✅
│   23a. Tidak bisa edit lagi
│
└── [Jika DITOLAK]
    21b. Terima FCM push notification + alasan
    22b. Buka riwayat UKJ → status Ditolak ❌
    23b. Baca catatan alasan koordinator
    24b. Klik "+ Input UKJ Baru" untuk
         input ulang dengan data diperbaiki
    25b. Kembali ke langkah 3
```

---

