
# Spesifikasi Kebutuhan Perangkat Lunak (SKPL)

## Sistem Informasi Manajemen Program Tahfiz Al-Qur'an

### MTs TQ Jamilurrahman Yogyakarta

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen

Dokumen Spesifikasi Kebutuhan Perangkat Lunak (SKPL) ini disusun untuk mendefinisikan secara lengkap dan terstruktur seluruh kebutuhan fungsional dan non-fungsional dari Sistem Informasi Manajemen Program Tahfiz Al-Qur'an MTs TQ Jamilurrahman Yogyakarta, yang selanjutnya disebut **SI-Tahfiz**.

Dokumen ini ditujukan kepada:

| Pembaca | Kepentingan |
|---------|-------------|
| Tim pengembang | Acuan implementasi fitur dan logika bisnis sistem |
| Penguji perangkat lunak | Acuan penyusunan skenario pengujian |
| Pihak sekolah (MTs TQ Jamilurrahman) | Validasi bahwa sistem yang dikembangkan sesuai kebutuhan operasional |
| Dosen pembimbing dan penguji | Evaluasi kelengkapan dan kesesuaian analisis kebutuhan |

Dokumen ini bersifat hidup (*living document*) dan dapat diperbarui seiring berjalannya proses pengembangan jika ditemukan kebutuhan baru atau terjadi perubahan kebijakan dari pihak sekolah.

---

### 1.2 Ruang Lingkup Sistem

**SI-Tahfiz** adalah aplikasi mobile lintas platform berbasis Flutter yang dirancang untuk mendigitalisasi dan mengintegrasikan seluruh proses manajemen program Tahfiz Al-Qur'an di MTs TQ Jamilurrahman Yogyakarta. Sistem ini menggantikan proses pencatatan manual yang sebelumnya dilakukan menggunakan buku catatan dan lembar kerja spreadsheet tidak terintegrasi.

**Sistem ini mencakup:**

- a. Pencatatan setoran hafalan harian santri (Sabak, Sabki, Manzil) dengan dukungan mode offline yang disinkronisasi saat koneksi tersedia
- b. Pengelolaan program Tikrar (pengulangan hafalan)
- c. Validasi Manzil oleh orang tua secara digital menggunakan tanda tangan pada layar sentuh perangkat
- d. Manajemen Ujian Kenaikan Juz (UKJ) dari pengampu hingga persetujuan koordinator
- e. Manajemen Ujian Akhir Semester (UAS) berbasis juz hafalan
- f. Pencatatan kehadiran santri dengan notifikasi otomatis ke orang tua saat santri Alpha, termasuk push notification ke perangkat Android melalui Firebase Cloud Messaging (FCM)
- g. Penilaian akhlaq santri per semester
- h. Pengelolaan periode Syahrul Quran dengan penyesuaian target baris per grade
- i. Rekap setoran semester dalam format Excel dengan pengelompokan per pekan hari kerja, yang dapat disimpan ke penyimpanan perangkat atau dibagikan melalui aplikasi lain
- j. Perhitungan nilai akhir semester otomatis dari empat komponen: setoran, UAS, akhlaq, kehadiran
- k. Manajemen akun pengguna dengan mekanisme login khusus untuk wali santri via nomor HP
- l. Sistem komunikasi pesan antara pengampu dan orang tua santri
- m. Pengelolaan pengumuman antar role
- n. Audit trail seluruh aktivitas kritis pengguna
- o. Konfigurasi sistem terpusat oleh Staff TU
- p. Push notification ke perangkat Android untuk notifikasi kritis: Alpha (ke wali santri), UKJ disetujui/ditolak (ke pengampu), Manzil divalidasi (ke pengampu), Tikrar selesai di rumah (ke pengampu), dan Pekan Murajaah baru (ke seluruh pengampu)

**Sistem ini tidak mencakup:**

- a. Sistem informasi akademik umum di luar program tahfiz (nilai mata pelajaran reguler, absensi kelas, dll.)
- b. Pengelolaan keuangan atau administrasi pembayaran
- c. Sistem pendaftaran siswa baru (PPDB)
- d. Integrasi dengan sistem eksternal seperti Dapodik atau EMIS Kemenag
- e. Versi iOS; aplikasi saat ini hanya tersedia untuk platform Android. Pengembangan versi iOS dapat dilakukan di masa mendatang menggunakan codebase Flutter yang sama tanpa perubahan logika bisnis
- f. Distribusi melalui Google Play Store; aplikasi didistribusikan secara langsung kepada pengguna dalam bentuk file APK
- g. Import data santri massal melalui antarmuka aplikasi; penginputan data awal tahun ajaran dilakukan melalui Supabase Dashboard oleh administrator teknis menggunakan fitur CSV import bawaan Supabase
- h. Halaman atau panel berita publik; informasi sekolah disampaikan melalui fitur pengumuman in-app yang hanya dapat diakses setelah login

---
### 1.3 Definisi, Akronim, dan Singkatan 

#### 1.3.1 Istilah Domain Tahfiz 

| Istilah | Definisi | 

|---------|----------| 

| **Tahfiz** | Program hafalan Al-Qur'an secara keseluruhan; juga digunakan sebagai nama grade tertinggi dalam sistem (Marhalah Tahfiz) | 

| **Sabak** | Setoran hafalan baru yang belum pernah disetorkan sebelumnya; merupakan materi hafalan yang baru diperoleh santri pada hari itu | 

| **Sabki** | Setoran review hafalan dari materi sehari sebelumnya; bertujuan memastikan hafalan baru tidak cepat lupa | | **Manzil** | Setoran review hafalan jangka panjang yang dilakukan di rumah bersama orang tua dan divalidasi menggunakan tanda tangan digital | 

| **Tikrar** | Kewajiban pengulangan hafalan yang diberikan pengampu kepada santri yang melakukan kesalahan melebihi batas yang ditentukan saat setoran | | **Murobbi** | Sebutan lain untuk pengampu/guru tahfiz yang bertanggung jawab membimbing satu kelompok halaqah | | **Halaqah** | Kelompok belajar tahfiz yang terdiri dari beberapa santri di bawah bimbingan satu pengampu | | **UKJ** | Ujian Kenaikan Juz; ujian formal yang menentukan apakah santri berhak melanjutkan hafalan ke juz berikutnya | 

| **UAS** | Ujian Akhir Semester; ujian yang dilaksanakan di akhir semester dengan menguji 3 juz pilihan pengampu (atau seluruh hafalan jika kurang dari 3 juz) | 

| **Syahrul Quran** | Periode khusus program intensif Al-Qur'an di mana santri hanya melakukan setoran Sabak dan Sabki tanpa Manzil, dengan target baris harian berbeda per grade | 

| **Stagnant** | Kondisi santri yang perkembangan hafalannya terhenti atau tidak mencapai target dalam kurun waktu tertentu | 

| **Pekan Murajaah** | Program ujian massal periodik yang diselenggarakan koordinator untuk seluruh santri secara bersamaan | 

| **Marhalah** | Tingkatan/grade dalam program tahfiz | 

| **Marhalah Tahsin** | Grade awal; santri dalam tahap perbaikan bacaan, target baris 7-10 baris/hari | | **Marhalah Takmil** | Grade menengah; santri dalam tahap penguatan hafalan, target baris 15 baris/hari | 

| **Marhalah Tahfiz** | Grade tertinggi; santri dalam tahap hafalan intensif, target baris 30 baris/hari | 

#### 1.3.2 Istilah Teknis Sistem 

| Istilah / Akronim | Definisi | 

|-------------------|----------| 

| **SI-Tahfiz** | Nama singkat sistem: Sistem Informasi Manajemen Program Tahfiz AlQur'an MTs TQ Jamilurrahman | 

| **SKPL** | Spesifikasi Kebutuhan Perangkat Lunak; dokumen ini | 

| **SRS** | *Software Requirements Specification*; padanan bahasa Inggris dari SKPL | | **KU** | Kebutuhan User; kebutuhan tingkat tinggi yang merepresentasikan satu tujuan yang ingin dicapai aktor | 

| **KF** | Kebutuhan Fungsional; kebutuhan spesifik yang menjelaskan perilaku sistem dalam memenuhi satu KU | 

| **RBAC** | *Role-Based Access Control*; mekanisme pengendalian akses berdasarkan peran pengguna | 

| **RLS** | *Row Level Security*; fitur keamanan Supabase yang membatasi akses data hingga level baris tabel | 

| **Auth** | *Authentication*; proses verifikasi identitas pengguna sebelum diberikan akses ke sistem | 

| **JWT** | *JSON Web Token*; format token yang digunakan Supabase untuk manajemen sesi pengguna | 

| **API** | *Application Programming Interface*; antarmuka yang memungkinkan komunikasi antar komponen sistem | 

| **OTP** | *One-Time Password*; kata sandi sekali pakai yang tidak digunakan dalam sistem ini | 

| **SSR** | *Server-Side Rendering*; teknik rendering halaman web di sisi server yang digunakan Next.js | 

| **CDN** | *Content Delivery Network*; jaringan distribusi konten yang digunakan Vercel untuk hosting | 

| **UUID** | *Universally Unique Identifier*; format identifikasi unik yang digunakan sebagai primary key semua tabel | 

| **CRUD** | *Create, Read, Update, Delete*; empat operasi dasar manajemen data | | **Real-time** | Kemampuan sistem menyampaikan pembaruan data secara langsung tanpa perlu me-refresh halaman | 

#### 1.3.3 Singkatan Role Pengguna 

| Singkatan | Role Lengkap | Keterangan | 

|-----------|-------------|------------| 

| **TU** | Tata Usaha | Staff administrasi dengan akses tertinggi di sistem | 

| **Koordinator** | Koordinator Tahfiz | Pengelola program tahfiz secara keseluruhan | 

| **Pengampu** | Pengampu / Murobbi | Guru tahfiz yang membimbing satu halaqah | | **Ortu / Wali** | Orang Tua / Wali Santri | Orang tua atau wali yang memantau perkembangan anak | 

| **Kepsek** | Kepala Sekolah | Kepala sekolah dan komite yang melakukan monitoring eksekutif | 

#### 1.3.4 Singkatan Teknologi

| Singkatan | Kepanjangan | Fungsi dalam Sistem |
|-----------|-------------|---------------------|
| **Flutter** | - | Framework UI lintas platform untuk pengembangan aplikasi mobile Android |
| **Dart** | - | Bahasa pemrograman yang digunakan oleh Flutter |
| **Supabase** | - | Backend-as-a-Service: database PostgreSQL, auth, storage, realtime |
| **PostgreSQL** | - | Sistem manajemen basis data relasional yang digunakan Supabase |
| **Riverpod** | - | Library state management untuk Flutter |
| **Drift** | - | Library local database berbasis SQLite untuk Flutter; digunakan untuk penyimpanan data offline sementara sebelum disinkronisasi ke server |
| **FCM** | Firebase Cloud Messaging | Layanan push notification Google untuk pengiriman notifikasi ke perangkat Android meskipun aplikasi tidak sedang dibuka |
| **flutter_secure_storage** | - | Package Flutter untuk menyimpan token autentikasi secara aman menggunakan Keystore Android |
| **supabase_flutter** | - | Package Flutter resmi untuk integrasi dengan layanan Supabase (auth, database, storage, realtime) |
| **share_plus** | - | Package Flutter untuk membagikan file ke aplikasi lain melalui share sheet native Android (WhatsApp, Google Drive, email, dll.) |
| **path_provider** | - | Package Flutter untuk mengakses direktori penyimpanan perangkat Android |
| **fl_chart** | - | Library Flutter untuk visualisasi data dalam bentuk grafik |
| **file_picker** | - | Package Flutter untuk memilih file dari penyimpanan perangkat |
| **firebase_messaging** | - | Package Flutter untuk integrasi dengan Firebase Cloud Messaging |
| **APK** | Android Package Kit | Format file instalasi aplikasi Android yang didistribusikan langsung kepada pengguna |

---

### 1.4 Referensi

| No | Dokumen / Sumber | Keterangan |
|----|-----------------|------------|
| 1 | IEEE Std 830-1998 | *IEEE Recommended Practice for Software Requirements Specifications*; standar acuan penulisan dokumen SKPL |
| 2 | Supabase Documentation — https://supabase.com/docs | Dokumentasi resmi platform backend yang digunakan |
| 3 | Flutter Documentation — https://docs.flutter.dev | Dokumentasi resmi framework mobile yang digunakan |
| 4 | Firebase Cloud Messaging Documentation — https://firebase.google.com/docs/cloud-messaging | Dokumentasi resmi layanan push notification yang digunakan |
| 5 | Buku Panduan Program Tahfiz MTs TQ Jamilurrahman | Dokumen internal sekolah yang menjadi acuan kebijakan akademik program tahfiz; diperoleh langsung dari pihak sekolah |
| 6 | Rekap Setoran Semester Spreadsheet MTs TQ Jamilurrahman (2024/2025) | Format rekap yang digunakan sekolah sebelum sistem ini dikembangkan; menjadi acuan desain fitur Rekap Semester |
| 7 | Wawancara dan Diskusi dengan Koordinator Tahfiz MTs TQ Jamilurrahman | Sumber kebutuhan bisnis utama; dilaksanakan selama proses analisis kebutuhan |

---

### 1.5 Gambaran Umum Dokumen 

Dokumen SKPL ini disusun mengikuti struktur standar IEEE 830-1998 yang telah disesuaikan dengan konteks pengembangan sistem ini. Dokumen terdiri dari bagian-bagian berikut: 

**Bab 1 — Pendahuluan** *(bab ini)* 

Menjelaskan tujuan penulisan dokumen, ruang lingkup sistem yang dikembangkan, definisi istilah dan akronim yang digunakan, daftar referensi, serta gambaran umum struktur dokumen ini. 

**Bab 2 — Deskripsi Umum Sistem** 

Menjelaskan gambaran besar sistem dari sudut pandang produk: konteks sistem, fungsi utama sistem secara ringkas, karakteristik pengguna yang akan menggunakan sistem, batasan-batasan yang berlaku, dan asumsi serta ketergantungan yang digunakan selama pengembangan. 

**Bab 3 — Kebutuhan Fungsional** 

Menjabarkan secara lengkap dan terperinci seluruh kebutuhan fungsional sistem yang dikelompokkan berdasarkan aktor. Setiap aktor memiliki sejumlah Kebutuhan User (KU) yang masing-masing dijabarkan ke dalam Kebutuhan Fungsional (KF) yang spesifik, terukur, dan dapat diuji. Bab ini merupakan inti dari dokumen SKPL dan menjadi acuan utama implementasi dan pengujian sistem. 

**Bab 4 — Kebutuhan Non-Fungsional** 

Menjabarkan kebutuhan yang tidak berkaitan langsung dengan perilaku fungsional sistem, namun menentukan kualitas sistem secara keseluruhan, meliputi: kebutuhan performa, 

keamanan, ketersediaan, kemudahan penggunaan (*usability*), skalabilitas, dan pemeliharaan (*maintainability*). 

**Bab 5 — Batasan Desain dan Implementasi** Menjelaskan batasan-batasan teknis yang harus diikuti selama proses implementasi, termasuk pilihan teknologi yang telah ditetapkan, keterbatasan platform, dan kebijakan keamanan data. 

--- 

*Dokumen ini disusun sebagai bagian dari Tugas Akhir / Proyek Pengembangan Sistem Informasi pada [nama institusi pendidikan] dan sekaligus sebagai dokumen teknis yang akan diserahkan kepada MTs TQ Jamilurrahman Yogyakarta sebagai pengguna sistem.* 

--- 

## 2. Deskripsi Umum Sistem

---

### 2.1 Perspektif Sistem

SI-Tahfiz merupakan sistem informasi yang dikembangkan secara mandiri (*standalone mobile-based system*) dan tidak merupakan bagian dari sistem informasi yang lebih besar. Sistem ini beroperasi sebagai aplikasi mobile native yang diinstal pada perangkat Android dan dapat digunakan kapan saja termasuk dalam kondisi koneksi terbatas.

#### 2.1.1 Konteks Sistem

Sebelum SI-Tahfiz dikembangkan, seluruh proses manajemen program tahfiz di MTs TQ Jamilurrahman dilakukan secara manual menggunakan buku catatan setoran, lembar absensi kertas, dan spreadsheet Microsoft Excel yang tidak terintegrasi antar pengampu. Proses ini memiliki sejumlah kelemahan:

- a. Data setoran tersebar di buku masing-masing pengampu, tidak dapat diakses koordinator atau kepala sekolah secara real-time
- b. Orang tua tidak memiliki visibilitas terhadap perkembangan hafalan anak kecuali melalui komunikasi langsung dengan pengampu
- c. Proses validasi Manzil dilakukan secara lisan tanpa bukti tertulis yang terarsip
- d. Rekap semester harus disusun manual setiap akhir semester dan rentan terhadap kesalahan perhitungan
- e. Tidak ada mekanisme notifikasi otomatis saat santri tidak hadir atau melanggar aturan hafalan

SI-Tahfiz hadir untuk menggantikan seluruh proses manual tersebut dengan sistem digital yang terintegrasi, dapat diakses dari mana saja melalui perangkat Android, dan memberikan visibilitas data secara real-time kepada semua pemangku kepentingan sesuai peran masing-masing.

#### 2.1.2 Arsitektur Sistem

SI-Tahfiz dibangun di atas arsitektur *serverless* dengan komponen utama sebagai berikut:
┌─────────────────────────────────────────────────────────┐

│              PENGGUNA (Perangkat Android)                │

│         Smartphone / Tablet Android ≥ 5.0 (API 21)      │

└────────────────────────── ┬ ──────────────────────────────┘

│ HTTPS

┌────────────────┴──────────────────┐

│                                   │

┌──────────▼─────────────┐       ┌─────────────▼──────────┐

│   FLUTTER APP (Client) │       │  FCM (Firebase Cloud)  │

│  Riverpod (state)      │       │  Push Notification     │

│  Drift (local DB)      │       │  Android               │

│  flutter_secure_storage│       └────────────────────────┘

└──────────┬─────────────┘

│ REST API / Realtime WebSocket

┌──────────▼─────────────────────────────────────────────┐

│                   BACKEND (Supabase)                    │

│  ┌─────────────┐  ┌──────────┐  ┌──────────────────┐  │

│  │ PostgreSQL  │  │   Auth   │  │     Storage      │  │

│  │  25 Tabel   │  │  + RLS   │  │  (tanda tangan)  │  │

│  └─────────────┘  └──────────┘  └──────────────────┘  │

│  ┌─────────────────────────────────────────────────┐   │

│  │             Realtime (WebSocket)                │   │

│  │  in-app: perubahan status tikrar, manzil, pesan │   │

│  └─────────────────────────────────────────────────┘   │

│  ┌─────────────────────────────────────────────────┐   │

│  │             Edge Function                       │   │

│  │  pengiriman push notification via FCM           │   │

│  └─────────────────────────────────────────────────┘   │

└────────────────────────────────────────────────────────┘

Data offline disimpan sementara di Drift (SQLite lokal) dan disinkronisasi ke Supabase saat koneksi tersedia. Push notification dikirim melalui FCM untuk notifikasi kritis yang perlu diterima pengguna meskipun aplikasi tidak sedang dibuka. Logika pengiriman push notification dijalankan melalui Supabase Edge Function agar FCM Server Key tidak tersimpan di dalam kode aplikasi Flutter.

#### 2.1.3 Antarmuka Eksternal

**Antarmuka Pengguna:**

Sistem diakses melalui aplikasi Flutter yang diinstal pada perangkat Android minimal versi 5.0 (API Level 21). Antarmuka dirancang untuk layar smartphone dan tablet Android dari ukuran 5 inci hingga 10 inci tanpa perbedaan fungsionalitas.

**Antarmuka Perangkat Keras:**

Untuk fitur validasi Manzil, sistem memerlukan perangkat dengan layar sentuh untuk menggambar tanda tangan digital. Selain itu, koneksi internet diperlukan untuk sinkronisasi data dan fitur real-time; input setoran harian dan absensi dapat dilakukan dalam kondisi offline dan akan disinkronisasi secara otomatis saat koneksi tersedia kembali. Tidak ada perangkat keras khusus lain yang diperlukan.

**Antarmuka Perangkat Lunak:**

Sistem terintegrasi dengan Firebase Cloud Messaging (FCM) untuk pengiriman push notification ke perangkat Android. Seluruh data utama dikelola dalam ekosistem Supabase. Tidak ada integrasi dengan perangkat lunak eksternal lain.

**Antarmuka Komunikasi:**

Sistem menggunakan protokol HTTPS untuk seluruh komunikasi data antara aplikasi Flutter dan Supabase. WebSocket (melalui Supabase Realtime) digunakan untuk fitur notifikasi in-app dan pembaruan data secara real-time. Push notification dikirimkan melalui protokol FCM dari Supabase Edge Function ke perangkat Android pengguna.

---

### 2.2 Fungsi Utama Sistem 

Berikut adalah ringkasan fungsi-fungsi utama SI-Tahfiz yang dikelompokkan berdasarkan domain fungsional: 

#### 2.2.1 Manajemen Setoran Harian 

Sistem menyediakan mekanisme pencatatan setoran hafalan harian yang terdiri dari tiga jenis: Sabak (hafalan baru), Sabki (review sehari sebelumnya), dan Manzil (review jangka panjang di rumah). Sistem mencegah duplikasi setoran pada hari yang sama dan secara otomatis menentukan status lulus atau mengulang berdasarkan jumlah kesalahan. 

#### 2.2.2 Program Tikrar 

Sistem secara otomatis membuat kewajiban Tikrar saat santri melakukan kesalahan yang melebihi batas yang ditentukan. Tikrar dikelola dalam alur status empat tahap: wajib di sekolah → selesai di sekolah → wajib di rumah → selesai di rumah, dengan keterlibatan orang tua pada tahap rumah. 

#### 2.2.3 Validasi Manzil Digital 

Sistem menyediakan fitur kanvas tanda tangan digital yang memungkinkan orang tua memvalidasi setoran Manzil anak secara digital dari smartphone. Tanda tangan diunggah ke Supabase Storage dan URL-nya disimpan sebagai bukti validasi yang dapat dilihat pengampu. 

#### 2.2.4 Manajemen UKJ dan UAS 

Sistem mendukung dua jenis ujian: Ujian Kenaikan Juz (UKJ) yang diinput pengampu dan memerlukan persetujuan koordinator, serta Ujian Akhir Semester (UAS) yang menguji maksimal 3 juz pilihan pengampu per santri dengan nilai per juz yang diratarata menjadi nilai akhir UAS. 

#### 2.2.5 Absensi dan Notifikasi Alpha 

Sistem menggunakan model exception-based untuk absensi: semua santri dianggap hadir secara default, dan pengampu hanya mencatat ketidakhadiran. Saat santri ditandai Alpha, sistem secara otomatis mengirimkan notifikasi ke akun orang tua. 

#### 2.2.6 Penilaian Akhlaq 

Sistem menyediakan fitur input nilai akhlaq (skala 0-100) per santri per semester oleh pengampu, yang dapat diaktifkan atau dinonaktifkan oleh koordinator sesuai kebutuhan. 

#### 2.2.7 Periode Syahrul Quran 

Sistem mendukung penetapan periode Syahrul Quran oleh koordinator dengan target baris khusus per grade. Selama periode ini, setoran Manzil tidak diperhitungkan dan rekap semester menandai pekan tersebut dengan simbol ★. 

#### 2.2.8 Rekap Semester dan Nilai Akhir 

Sistem menghasilkan rekap setoran semester dalam format Excel yang dikelompokkan per pekan hari kerja aktual. Nilai akhir semester dihitung secara otomatis dari empat komponen: setoran harian (40%), UAS (40%), akhlaq (10%), dan kehadiran (10%). 

#### 2.2.9 Komunikasi dan Pengumuman 

Sistem menyediakan fitur pesan antara pengampu dan orang tua per santri, serta sistem pengumuman dari koordinator atau Staff TU yang dapat ditujukan ke role tertentu dan ditampilkan sebagai popup saat login. 

#### 2.2.10 Administrasi dan Konfigurasi Sistem 

Sistem menyediakan panel administrasi untuk Staff TU mencakup: manajemen akun pengguna (termasuk mekanisme login khusus wali via nomor HP), manajemen data santri dan halaqah, konfigurasi tanggal semester, maintenance mode, pengelolaan berita halaman login, dan audit trail seluruh aktivitas kritis. 

--- 

### 2.3 Karakteristik Pengguna 

Sistem memiliki lima kategori pengguna dengan karakteristik dan kemampuan teknis yang berbeda-beda: 

#### 2.3.1 Staff Tata Usaha (TU) 

| Atribut | Keterangan | 

|---------|------------| 

| Jumlah perkiraan | 1-2 orang | 

| Tingkat pendidikan | Minimal SMA/sederajat | 

| Kemampuan teknis | Mampu mengoperasikan komputer dan aplikasi perkantoran dasar (Microsoft Office) | 

| Frekuensi penggunaan | Harian untuk manajemen data; mingguan untuk konfigurasi dan audit | 

| Perangkat utama | Smartphone Android| 

| Akses istimewa | Satu-satunya role yang dapat mengakses sistem saat Maintenance Mode aktif | 

#### 2.3.2 Koordinator Tahfiz 

| Atribut | Keterangan | |---------|------------| 

| Jumlah perkiraan | 1 orang | 

| Tingkat pendidikan | Minimal S1 atau setara | 

| Kemampuan teknis | Terbiasa menggunakan aplikasi berbasis web; familiar dengan spreadsheet | 

| Frekuensi penggunaan | Harian untuk monitoring; mingguan untuk review UKJ dan konfigurasi jadwal | 

| Perangkat utama | Smartphone Android | 

| Catatan khusus | Memiliki otoritas pengambilan keputusan tertinggi dalam program tahfiz | 

#### 2.3.3 Pengampu / Murobbi 

| Atribut | Keterangan | 

|---------|------------| 

| Jumlah perkiraan | 2-5 orang | 

| Tingkat pendidikan | Minimal SMA/sederajat; sebagian besar hafiz/hafizah | 

| Kemampuan teknis | Tidak diasumsikan mahir teknologi; antarmuka harus intuitif | 

| Frekuensi penggunaan | Setiap hari kerja untuk input setoran dan absensi | 

| Perangkat utama | Smartphone Android | 

| Catatan khusus | Pengguna paling aktif dan paling sering berinteraksi dengan sistem; desain antarmuka harus mengutamakan kemudahan input cepat | 

#### 2.3.4 Orang Tua / Wali Santri 

| Atribut | Keterangan | 

|---------|------------| 

| Jumlah perkiraan | 50-100 orang (menyesuaikan jumlah santri) | 

| Tingkat pendidikan | Bervariasi; tidak dapat diasumsikan | 

| Kemampuan teknis | Diasumsikan minimal; hanya terbiasa menggunakan WhatsApp dan aplikasi sehari-hari | 

| Frekuensi penggunaan | Beberapa kali per minggu untuk validasi Manzil dan pemantauan anak | 

| Perangkat utama | Smartphone | 

| Catatan khusus | Merupakan kelompok pengguna dengan kemampuan teknis terendah; login dirancang semudah mungkin hanya menggunakan nomor HP tanpa perlu mengingat email atau password terpisah | 

#### 2.3.5 Kepala Sekolah & Komite 

| Atribut | Keterangan | 

|---------|------------| 

| Jumlah perkiraan | 1-3 orang | 

| Tingkat pendidikan | S1 atau lebih tinggi | 

| Kemampuan teknis | Mampu mengoperasikan komputer dan membaca laporan digital | 

| Frekuensi penggunaan | Mingguan atau bulanan untuk monitoring eksekutif dan laporan | 

| Perangkat utama | Smartphone Android | 

| Catatan khusus | Pengguna dengan frekuensi terendah; lebih mengutamakan tampilan ringkasan dan kemudahan ekspor laporan | 

--- 

### 2.4 Batasan Sistem 

Berikut adalah batasan-batasan yang berlaku dalam pengembangan dan pengoperasian SI-Tahfiz: 

#### 2.4.1 Batasan Teknis 

``` 

- a. hanya tersedia untuk platform Android; platform iOS dapat dikembangkan di masa mendatang menggunakan codebase Flutter yang sama"

(Android/iOS) 

- b. input setoran harian dan absensi mendukung mode offline dengan penyimpanan lokal; fitur lain memerlukan koneksi internet aktif

- c. Kapasitas penyimpanan tanda tangan digital dibatasi oleh kuota Supabase Storage yang digunakan 

- d. Push notification bergantung pada layanan FCM Google; notifikasi in-app bergantung pada koneksi WebSocket Supabase Realtime

- e. Generate file Excel dan PDF dilakukan di sisi klien (aplikasi Flutter) dan disimpan ke penyimpanan perangkat atau dibagikan melalui share sheet

- f. Sistem tidak menyediakan mekanisme backup mandiri; backup database sepenuhnya dikelola oleh infrastruktur Supabase secara otomatis ``` 

#### 2.4.2 Batasan Regulasi dan Kebijakan 

``` 

- a. Data pribadi santri dan orang tua (nama, nomor HP, informasi akademik) harus dijaga kerahasiaannya dan hanya dapat diakses oleh pengguna dengan role yang relevan sesuai kebijakan RLS Supabase 

- b. Nomor HP orang tua yang digunakan sebagai kredensial login harus diperlakukan sebagai data sensitif 

- c. Penghapusan data santri hanya dapat dilakukan oleh Staff TU dan selalu dicatat dalam audit_log 

- d. Perubahan grade santri hanya dapat dilakukan oleh Koordinator Tahfiz dan selalu dicatat dalam 

riwayat_grade dan audit_log 

``` 

#### 2.4.3 Batasan Bisnis dan Operasional 

``` 

- a. Formula nilai akhir semester (40% setoran, 40% UAS, 

10% akhlaq, 10% kehadiran) bersifat tetap dan tidak dapat dikonfigurasi melalui antarmuka sistem; perubahan formula memerlukan modifikasi kode 

- b. Target baris harian per grade selama Syahrul Quran (Tahfiz: 30 baris, Takmil: 15 baris, Tahsin: per individu) dikonfigurasi per periode oleh koordinator; bukan nilai global yang tetap 

- c. Sistem hanya mendukung dua semester per tahun akademik (Ganjil dan Genap) dengan tanggal yang dikonfigurasi manual oleh Staff TU 

- d. UAS hanya menguji maksimal 3 juz per santri; santri dengan hafalan ≤ 3 juz diuji seluruh hafalannya 

- e. Penilaian akhlaq hanya dapat dilakukan oleh pengampu halaqah masing-masing, bukan oleh koordinator atau Staff TU ``` 

--- 

### 2.5 Asumsi dan Ketergantungan 

#### 2.5.1 Asumsi 

Dokumen ini disusun berdasarkan asumsi-asumsi berikut: 

``` 

- a. Setiap santri terdaftar dalam tepat satu halaqah aktif pada satu waktu; perpindahan halaqah hanya dapat dilakukan oleh Staff TU 

- b. Setiap halaqah memiliki tepat satu pengampu yang bertanggung jawab 

- c. Satu akun orang tua dapat memiliki lebih dari satu anak yang terdaftar; sistem mendukung relasi satu-ke-banyak antara wali dan santri 

- d. Hari kerja didefinisikan sebagai Senin sampai Jumat, dikurangi tanggal-tanggal yang terdaftar sebagai hari libur di tabel hari_libur 

- e. Nomor HP orang tua yang digunakan sebagai kredensial 

login bersifat unik per orang tua dan sudah terdaftar sebelumnya oleh Staff TU 

f. Koordinator Tahfiz bertanggung jawab mengonfigurasi tanggal Syahrul Quran dan jadwal Pekan Murajaah; Staff TU bertanggung jawab mengonfigurasi tanggal semester 

- g. Semua pengguna memiliki akses ke perangkat dengan mobile dan koneksi internet yang memadai 

h. Data dummy (data uji coba) akan dihapus sepenuhnya sebelum sistem diserahkan ke sekolah dan digunakan dengan data nyata ``` 

#### 2.5.2 Ketergantungan

SI-Tahfiz memiliki ketergantungan terhadap layanan dan komponen eksternal berikut:

| Komponen | Ketergantungan | Risiko Jika Tidak Tersedia |
|----------|----------------|---------------------------|
| **Supabase** | Platform backend utama: database, auth, storage, realtime | Sistem tidak dapat beroperasi sama sekali |
| **Koneksi Internet** | Diperlukan untuk semua fitur kecuali input setoran harian dan absensi yang didukung offline | Fitur real-time, sinkronisasi data, validasi Manzil, UKJ, UAS, dan ekspor file tidak dapat digunakan; input setoran dan absensi masih dapat dilakukan secara lokal |
| **Layar Sentuh Perangkat Android** | Diperlukan khusus untuk fitur tanda tangan digital validasi Manzil | Fitur validasi Manzil tidak dapat digunakan |
| **Email Server Supabase** | Diperlukan untuk fitur reset password Staff/Guru | Fitur lupa password tidak dapat digunakan; login Wali Santri tidak terpengaruh karena menggunakan nomor HP |
| **Firebase Cloud Messaging (FCM)** | Diperlukan untuk pengiriman push notification ke perangkat Android | Push notification tidak terkirim; notifikasi in-app tetap berfungsi melalui Supabase Realtime selama aplikasi dibuka |
| **Google Play Services** | Diperlukan di perangkat Android untuk penerimaan push notification FCM | Push notification tidak dapat diterima pada perangkat tanpa Google Play Services |

---

*Bab ini memberikan gambaran umum sistem sebagai konteks untuk memahami kebutuhan fungsional dan non-fungsional yang dijabarkan pada bab-bab selanjutnya.*

---

L 

## **3. Kebutuhan Fungsional (Functional Requirements)** 

**Kebutuhan Fungsional — Aktor: Wali Santri** 
## Kebutuhan Fungsional — Aktor: Wali Santri

---

### KU-01 — Wali dapat mengakses sistem dengan mudah tanpa perlu mengingat email

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-01.1 | Sistem menyediakan mode login khusus "Wali Santri" yang terpisah dari mode login Staff/Guru di layar login aplikasi |
| KF-01.2 | Sistem menerima input berupa nomor HP sebagai satu-satunya kredensial yang perlu diingat wali |
| KF-01.3 | Sistem mengonstruksi email secara otomatis dari nomor HP dengan format {nomor_hp}@jamilurrahman.sch.id tanpa perlu ditampilkan ke wali |
| KF-01.4 | Sistem menggunakan nomor HP yang sama sebagai password secara otomatis tanpa wali perlu mengetahuinya |
| KF-01.5 | Sistem mengarahkan wali ke layar utama wali setelah login berhasil |
| KF-01.6 | Sistem menerapkan rate limiting login: setelah 3 kali gagal, wali dikunci sementara dengan countdown timer yang meningkat secara eksponensial dan ditampilkan di layar login aplikasi |
| KF-01.7 | Sistem menampilkan pesan error yang informatif dan ramah saat login gagal |

---

### KU-02 — Wali dapat memantau kehadiran anaknya di sekolah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-02.1 | Sistem mengirimkan notifikasi secara otomatis ke akun wali ketika pengampu mencatat anaknya Alpha (tidak hadir tanpa keterangan), termasuk push notification FCM ke perangkat Android wali meskipun aplikasi tidak sedang dibuka |
| KF-02.2 | Notifikasi Alpha memuat informasi: nama santri, tanggal ketidakhadiran, dan instruksi untuk menghubungi pengampu |
| KF-02.3 | Sistem menampilkan notifikasi Alpha di layar beranda wali saat wali membuka aplikasi |
| KF-02.4 | Wali dapat merespons notifikasi Alpha dengan mengirim pesan langsung ke pengampu melalui fitur pesan yang terintegrasi |
| KF-02.5 | Sistem tidak mengirimkan notifikasi otomatis untuk ketidakhadiran dengan status Sakit atau Izin (hanya Alpha) |

---

### KU-03 — Wali dapat memantau perkembangan hafalan anaknya

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-03.1 | Sistem menampilkan ringkasan setoran harian anak di layar beranda wali, mencakup status setor hari ini (Sabak, Sabki) |
| KF-03.2 | Sistem menampilkan grade anak saat ini (Tahsin/Takmil/Tahfiz) dan target baris harian |
| KF-03.3 | Sistem menampilkan juz yang sedang dihafal anak (current_juz) dan total hafalan yang sudah selesai |
| KF-03.4 | Sistem menampilkan grafik perkembangan setoran anak per bulan (total baris) |
| KF-03.5 | Sistem menampilkan riwayat setoran anak (Sabak, Sabki, Manzil) dengan informasi surah, halaman, baris, dan status lulus/mengulang |
| KF-03.6 | Sistem menampilkan status tikrar aktif anak jika ada kewajiban tikrar yang belum selesai |

---

### KU-04 — Wali dapat memvalidasi setoran Manzil anak di rumah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-04.1 | Sistem menampilkan daftar setoran Manzil anak yang sudah diinput pengampu namun belum divalidasi orang tua |
| KF-04.2 | Sistem menampilkan informasi lengkap setiap Manzil yang perlu divalidasi: surah, rentang halaman, dan tanggal |
| KF-04.3 | Sistem menyediakan widget tanda tangan digital yang dapat digunakan wali untuk menandatangani validasi menggunakan layar sentuh perangkat Android |
| KF-04.4 | Wali dapat menghapus tanda tangan dan menggambar ulang sebelum menyimpan |
| KF-04.5 | Sistem mengunggah tanda tangan ke Supabase Storage bucket signatures dan menyimpan URL-nya (bukan base64) ke kolom parent_signature di tabel setoran |
| KF-04.6 | Sistem mengubah status parent_verified menjadi true pada record setoran Manzil yang divalidasi |
| KF-04.7 | Sistem mengirimkan notifikasi real-time ke pengampu saat wali menyelesaikan validasi Manzil |
| KF-04.8 | Setoran Manzil yang sudah divalidasi tidak dapat divalidasi ulang (tombol validasi tidak ditampilkan) |

---

### KU-05 — Wali dapat membantu menyelesaikan kewajiban Tikrar anak di rumah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-05.1 | Sistem menampilkan daftar kewajiban Tikrar anak yang sudah berstatus wajib_rumah |
| KF-05.2 | Sistem menampilkan informasi Tikrar: surah, halaman, jumlah pengulangan yang diwajibkan, dan tanggal diberikan |
| KF-05.3 | Wali dapat menandai Tikrar sebagai selesai dikerjakan di rumah dengan menekan tombol konfirmasi |
| KF-05.4 | Sistem mengubah status Tikrar menjadi selesai_rumah dan mencatat timestamp penyelesaian |
| KF-05.5 | Sistem mengirimkan notifikasi real-time ke pengampu saat wali menandai Tikrar selesai di rumah |
| KF-05.6 | Tikrar yang sudah berstatus selesai_rumah ditampilkan sebagai arsip (read-only, tidak dapat diubah lagi) |

---

### KU-06 — Wali dapat berkomunikasi langsung dengan pengampu

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-06.1 | Sistem menyediakan fitur pesan teks antara wali dan pengampu, dikelompokkan per santri |
| KF-06.2 | Wali dapat mengirim pesan baru ke pengampu kapan saja |
| KF-06.3 | Sistem menampilkan seluruh riwayat percakapan antara wali dan pengampu dalam format thread kronologis |
| KF-06.4 | Pesan dari pengampu yang belum dibaca ditandai secara visual (unread indicator) |
| KF-06.5 | Pesan otomatis ditandai sudah dibaca saat wali membuka layar Pesan |
| KF-06.6 | Wali dapat menggunakan fitur Pesan untuk membalas notifikasi Alpha dari pengampu |

---

### KU-07 — Wali yang memiliki lebih dari satu anak dapat memantau semua anaknya

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-07.1 | Sistem mendeteksi secara otomatis apakah akun wali terhubung ke lebih dari satu santri melalui tabel relasi ortu-santri |
| KF-07.2 | Jika wali memiliki lebih dari satu anak, sistem menampilkan child selector di bagian atas layar utama wali |
| KF-07.3 | Wali dapat berpindah antar anak dengan satu ketukan, dan seluruh data di layar utama (setoran, manzil, tikrar, pesan) diperbarui sesuai anak yang dipilih |
| KF-07.4 | Jika wali hanya memiliki satu anak, child selector tidak ditampilkan |
| KF-07.5 | Push notification Alpha yang diterima wali memuat nama anak secara eksplisit sehingga jelas anak mana yang tidak hadir |

---

### KU-08 — Wali dapat menerima pengumuman dari pihak sekolah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-08.1 | Sistem menampilkan dialog pengumuman secara otomatis saat wali masuk ke layar utama, jika ada pengumuman baru yang ditujukan ke role orangtua |
| KF-08.2 | Sistem mencatat status sudah-dibaca per wali per pengumuman sehingga dialog tidak muncul ulang untuk pengumuman yang sama |
| KF-08.3 | Wali dapat menutup dialog pengumuman setelah membacanya |

---

**Ringkasan Aktor Wali Santri**

| | |
|-|-|
| Aktor | Wali Santri |
| Kebutuhan | 8 kebutuhan user |
| Total KF | 38 kebutuhan fungsional |

| Kebutuhan User | Deskripsi | Jumlah KF |
|----------------|-----------|-----------|
| KU-01 | Login via Nomor HP | 7 KF |
| KU-02 | Pantau kehadiran | 5 KF |
| KU-03 | Pantau perkembangan hafalan | 6 KF |
| KU-04 | Validasi Manzil | 8 KF |
| KU-05 | Tikrar Rumah | 6 KF |
| KU-06 | Komunikasi dengan pengampu | 6 KF |
| KU-07 | Multi-anak | 5 KF |
| KU-08 | Pengumuman sekolah | 3 KF |


## Kebutuhan Fungsional — Aktor: Pengampu / Murobbi

---

### KU-01 — Pengampu dapat mengakses sistem dengan kredensial yang diberikan Staff TU

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-01.1 | Sistem menyediakan mode login "Staff/Guru" dengan input email dan password |
| KF-01.2 | Sistem mengarahkan pengampu ke layar utama pengampu setelah login berhasil |
| KF-01.3 | Sistem menerapkan rate limiting: 3 kali gagal login → dikunci sementara dengan countdown timer eksponensial yang ditampilkan di layar login aplikasi |
| KF-01.4 | Pengampu dapat meminta reset password melalui fitur "Lupa Password" yang mengirim link ke email terdaftar |
| KF-01.5 | Sistem memvalidasi password baru: minimal 8 karakter, mengandung huruf dan angka |

---

### KU-02 — Pengampu dapat melihat ringkasan kondisi halaqahnya setiap hari

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-02.1 | Sistem menampilkan nama halaqah, unit (Putra/Putri), dan total santri aktif milik pengampu yang login |
| KF-02.2 | Sistem menampilkan jumlah santri yang sudah setor hari ini dan yang belum setor |
| KF-02.3 | Sistem menampilkan jumlah tikrar aktif yang ada di halaqah pengampu |
| KF-02.4 | Sistem menampilkan banner peringatan kuning jika Pekan Murajaah Massal sedang aktif |
| KF-02.5 | Sistem menampilkan dialog pengumuman secara otomatis saat pengampu masuk ke layar utama jika ada pengumuman baru yang ditujukan ke role pengampu |
| KF-02.6 | Sistem mencatat status sudah-dibaca per pengampu per pengumuman sehingga dialog tidak muncul ulang untuk pengumuman yang sama |

---

### KU-03 — Pengampu dapat mencatat setoran Sabki (review kemarin) setiap hari

> **Catatan:** Fitur ini mendukung mode offline. Data setoran Sabki yang diinput saat perangkat tidak terhubung ke internet disimpan terlebih dahulu di lokal perangkat (Drift/SQLite) dan disinkronisasi secara otomatis ke server saat koneksi tersedia kembali.

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-03.1 | Sistem menampilkan daftar santri halaqah beserta status setor masing-masing hari ini |
| KF-03.2 | Pengampu dapat memilih santri dari daftar untuk membuka form input setoran |
| KF-03.3 | Sistem menampilkan status Manzil kemarin sebelum form Sabki: surah, halaman, status verifikasi orang tua, dan gambar tanda tangan jika sudah diverifikasi |
| KF-03.4 | Pengampu dapat menginput setoran Sabki: surah, halaman, dan jumlah kesalahan |
| KF-03.5 | Sistem menentukan status Sabki secara otomatis: lulus jika kesalahan dalam batas, mengulang jika melebihi |
| KF-03.6 | Jika kesalahan Sabki melebihi batas dan belum ada tikrar untuk surah yang sama hari ini, sistem secara otomatis membuat kewajiban Tikrar Sekolah untuk santri tersebut |
| KF-03.7 | Sistem mencegah duplikasi: jika Sabki sudah diinput hari ini untuk santri yang sama, form beralih ke mode Edit |
| KF-03.8 | Pengampu dapat mengedit setoran Sabki yang sudah diinput hari ini |

---

### KU-04 — Pengampu dapat mencatat setoran Sabak (hafalan baru) setiap hari

> **Catatan:** Fitur ini mendukung mode offline. Data setoran Sabak yang diinput saat perangkat tidak terhubung ke internet disimpan terlebih dahulu di lokal perangkat (Drift/SQLite) dan disinkronisasi secara otomatis ke server saat koneksi tersedia kembali.

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-04.1 | Pengampu dapat menginput setoran Sabak: surah, halaman mulai, halaman selesai, jumlah baris, jumlah kesalahan, dan catatan |
| KF-04.2 | Sistem menampilkan indikator persentase baris yang disetor terhadap target baris harian santri secara real-time saat pengampu mengisi jumlah baris |
| KF-04.3 | Sistem menentukan status Sabak secara otomatis: lulus atau mengulang berdasarkan jumlah kesalahan |
| KF-04.4 | Jika jumlah kesalahan melebihi jumlah halaman yang disetor dan belum ada tikrar untuk surah yang sama hari ini, sistem secara otomatis membuat kewajiban Tikrar Sekolah |
| KF-04.5 | Sistem mencegah duplikasi: jika Sabak sudah diinput hari ini untuk santri yang sama, form beralih ke mode Edit |
| KF-04.6 | Pengampu dapat mengedit setoran Sabak yang sudah diinput hari ini |
| KF-04.7 | Sistem menampilkan badge status per santri di daftar: Belum Setor / Tuntas Sabak & Sabki / Mengulang |
| KF-04.8 | Sistem menampilkan rata-rata baris dan persentase terhadap target di daftar santri untuk monitoring cepat |

---

### KU-05 — Pengampu dapat mengelola setoran saat Pekan Murajaah Massal aktif

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-05.1 | Sistem mendeteksi secara otomatis jika ada jadwal Pekan Murajaah yang sedang aktif sesuai tanggal hari ini |
| KF-05.2 | Saat Pekan Murajaah aktif, sistem mengganti form setoran harian dengan form ujian massal khusus |
| KF-05.3 | Form ujian massal menampilkan materi ujian sesuai kelas santri (kelas 7/8/9) berdasarkan konfigurasi yang dibuat koordinator |
| KF-05.4 | Pengampu dapat menginput hasil ujian Murajaah: surah, halaman, jumlah baris, jumlah kesalahan, dan catatan |
| KF-05.5 | Sistem menyimpan setoran ujian Murajaah dengan prefix catatan [Pekan Muraja'ah] untuk membedakan dari setoran harian biasa |
| KF-05.6 | Sistem mencegah duplikasi: jika ujian sudah diinput hari ini untuk santri yang sama, form beralih ke mode Edit |

---

### KU-06 — Pengampu dapat memantau dan mengelola status Tikrar santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-06.1 | Sistem menampilkan daftar semua kewajiban Tikrar aktif di halaqah pengampu |
| KF-06.2 | Setiap Tikrar menampilkan informasi: nama santri, surah, halaman, jumlah pengulangan wajib, tanggal, dan status terkini |
| KF-06.3 | Pengampu dapat menandai Tikrar Sekolah sebagai selesai dikerjakan di sekolah |
| KF-06.4 | Pengampu dapat memindahkan status Tikrar menjadi wajib_rumah untuk dilanjutkan santri di rumah bersama orang tua |
| KF-06.5 | Sistem menampilkan badge jumlah Tikrar aktif pada ikon menu Tikrar di navigation bar |
| KF-06.6 | Sistem menampilkan notifikasi real-time saat orang tua menandai Tikrar selesai di rumah |
| KF-06.7 | Sistem menampilkan timestamp konfirmasi orang tua pada Tikrar yang sudah berstatus selesai di rumah |

---

### KU-07 — Pengampu dapat memantau status Manzil santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-07.1 | Sistem menampilkan daftar santri beserta status Manzil terakhir masing-masing |
| KF-07.2 | Sistem menampilkan informasi Manzil per santri: surah, rentang halaman, tanggal, dan status verifikasi orang tua |
| KF-07.3 | Sistem menampilkan gambar tanda tangan digital orang tua jika Manzil sudah diverifikasi |
| KF-07.4 | Sistem menampilkan peringatan jika santri belum mendapat konfirmasi Manzil dari orang tua |
| KF-07.5 | Sistem mengirimkan notifikasi real-time ke pengampu saat orang tua menyelesaikan validasi Manzil |

---

### KU-08 — Pengampu dapat mencatat kehadiran santri setiap hari

> **Catatan:** Fitur ini mendukung mode offline. Data absensi yang diinput saat perangkat tidak terhubung ke internet disimpan terlebih dahulu di lokal perangkat (Drift/SQLite) dan disinkronisasi secara otomatis ke server saat koneksi tersedia kembali. Notifikasi Alpha ke orang tua akan dikirim setelah data berhasil disinkronisasi.

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-08.1 | Sistem menggunakan model exception-based: semua santri dianggap Hadir secara default, pengampu hanya mencatat yang tidak hadir |
| KF-08.2 | Pengampu dapat memilih tanggal untuk melihat dan mengedit data absensi hari mana saja |
| KF-08.3 | Sistem menampilkan ringkasan: total santri, jumlah hadir, dan jumlah tidak hadir untuk tanggal yang dipilih |
| KF-08.4 | Pengampu dapat menandai santri sebagai Sakit, Izin, atau Alpha disertai keterangan opsional |
| KF-08.5 | Pengampu dapat mengubah status absensi yang sudah dicatat |
| KF-08.6 | Pengampu dapat mengembalikan status santri menjadi Hadir dengan menghapus record absensi |
| KF-08.7 | Sistem secara otomatis mengirimkan notifikasi ke akun orang tua santri yang ditandai Alpha, termasuk push notification FCM ke perangkat Android orang tua |
| KF-08.8 | Sistem tidak mengirimkan notifikasi otomatis untuk status Sakit atau Izin |
| KF-08.9 | Jika santri tidak memiliki akun orang tua yang terhubung, sistem tetap menyimpan absensi tanpa error |

---

### KU-09 — Pengampu dapat menginput nilai akhlaq santri per semester

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-09.1 | Fitur input nilai akhlaq hanya dapat diakses jika koordinator telah mengaktifkan toggle akhlaq di konfigurasi sistem |
| KF-09.2 | Sistem menampilkan label semester yang sedang aktif untuk penilaian akhlaq sesuai konfigurasi koordinator |
| KF-09.3 | Pengampu dapat menginput nilai akhlaq 0-100 per santri disertai catatan opsional |
| KF-09.4 | Sistem mencegah duplikasi: satu santri hanya boleh memiliki satu nilai akhlaq per semester |
| KF-09.5 | Pengampu dapat mengedit nilai akhlaq yang sudah diinput untuk semester yang sama |
| KF-09.6 | Sistem menampilkan nilai yang sudah diinput sebelumnya saat pengampu membuka layar nilai akhlaq |

---

### KU-10 — Pengampu dapat menginput dan mengirimkan hasil Ujian Kenaikan Juz (UKJ) ke Koordinator

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-10.1 | Pengampu dapat menginput hasil UKJ per santri di halaqahnya: juz yang diuji, tanggal ujian, dan jumlah kesalahan |
| KF-10.2 | Pengampu menentukan sendiri status UKJ: lulus atau mengulang (bukan ditentukan otomatis oleh sistem) |
| KF-10.3 | Pengampu memberikan nilai grade UKJ dalam skala 1-5 sebagai penilaian kualitatif tambahan terhadap hasil ujian |
| KF-10.4 | Sistem menyimpan hasil UKJ dengan status approved_by_koordinator = false (menunggu review koordinator) |
| KF-10.5 | Setelah pengampu menginput hasil UKJ, sistem mengirimkan notifikasi ke koordinator bahwa ada UKJ baru yang menunggu review |
| KF-10.6 | Sistem menampilkan label "Menunggu Persetujuan Koordinator" pada hasil UKJ yang sudah diinput namun belum direview |
| KF-10.7 | Pengampu dapat mengedit hasil UKJ yang masih berstatus pending (belum diapprove atau ditolak koordinator) |
| KF-10.8 | Pengampu tidak dapat mengedit hasil UKJ yang sudah diapprove atau ditolak koordinator |
| KF-10.9 | Sistem menampilkan riwayat UKJ per santri mencakup: juz, tanggal, kesalahan, status lulus/mengulang, grade 1-5, dan status persetujuan koordinator |
| KF-10.10 | Saat koordinator menyetujui UKJ, sistem mengirimkan push notification FCM ke perangkat Android pengampu bahwa UKJ telah disetujui |
| KF-10.11 | Saat koordinator menolak UKJ, sistem mengirimkan push notification FCM ke perangkat Android pengampu disertai catatan alasan penolakan dari koordinator |
| KF-10.12 | Jika UKJ ditolak, pengampu dapat menginput ulang hasil UKJ untuk santri yang sama |

---

### KU-11 — Pengampu dapat menginput nilai Ujian Akhir Semester (UAS) per santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-11.1 | Pengampu dapat memilih semester (Ganjil/Genap) untuk input nilai UAS |
| KF-11.2 | Sistem menampilkan jumlah hafalan juz setiap santri sebagai acuan pemilihan juz yang akan diujikan |
| KF-11.3 | Pengampu dapat membuka form input UAS per santri untuk memilih juz yang akan diujikan |
| KF-11.4 | Sistem menampilkan seluruh juz yang sudah dihafal santri (dari tabel hafalan_juz) sebagai pilihan yang dapat dipilih |
| KF-11.5 | Jika total hafalan santri ≤ 3 juz, sistem secara otomatis memilih semua juz dan tidak mengizinkan pengampu mengubah pilihan |
| KF-11.6 | Jika total hafalan santri > 3 juz, pengampu dapat memilih maksimal 3 juz untuk diujikan |
| KF-11.7 | Sistem mencegah pengampu memilih lebih dari 3 juz dan menampilkan pesan error jika batas terlampaui |
| KF-11.8 | Pengampu dapat menginput nilai 0-100 untuk setiap juz yang dipilih |
| KF-11.9 | Sistem menampilkan preview nilai akhir (rata-rata) secara real-time saat pengampu mengisi nilai per juz |
| KF-11.10 | Nilai akhir UAS dihitung otomatis sebagai rata-rata dari semua nilai per juz; jika ada juz yang belum dinilai, nilai akhir = null |
| KF-11.11 | Sistem mencegah duplikasi: satu santri hanya boleh memiliki satu data UAS per semester |
| KF-11.12 | Pengampu dapat mengedit data UAS yang sudah diinput dan menghapus data UAS jika diperlukan |

---

### KU-12 — Pengampu dapat melihat rekap setoran semester dalam format Excel

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-12.1 | Pengampu dapat memilih semester (Ganjil/Genap) untuk melihat rekap |
| KF-12.2 | Sistem menampilkan peringatan jika tanggal semester belum dikonfigurasi Staff TU |
| KF-12.3 | Sistem dapat menghasilkan preview rekap sebelum export untuk verifikasi data |
| KF-12.4 | Rekap dikelompokkan per pekan dengan label range tanggal (contoh: "2-6 Jun", "9-13 Jun") |
| KF-12.5 | Setiap pekan hanya menghitung hari kerja aktual: Senin-Jumat dikurangi hari libur dari tabel hari_libur |
| KF-12.6 | Setiap santri ditampilkan dalam 4 baris: Sabak, Sabki, Manzil, dan Target Tidak Tercapai |
| KF-12.7 | Kolom Target Tidak Tercapai per pekan berisi jumlah hari kerja di mana baris Sabak santri tidak mencapai target harian |
| KF-12.8 | Pekan yang jatuh dalam periode Syahrul Quran diberi tanda ★ pada label kolom pekan |
| KF-12.9 | Kolom Manzil pada pekan Syahrul Quran menampilkan tanda "-" karena tidak ada setoran Manzil selama periode tersebut |
| KF-12.10 | Rekap hanya menampilkan santri dari halaqah pengampu yang sedang login |
| KF-12.11 | Sistem menghasilkan file Excel (.xlsx) yang disimpan ke penyimpanan perangkat dan dapat dibagikan melalui share sheet (WhatsApp, Google Drive, email, dan aplikasi lain) |

---

### KU-13 — Pengampu dapat melihat nilai akhir semester santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-13.1 | Pengampu dapat memilih semester untuk melihat nilai akhir |
| KF-13.2 | Sistem menampilkan peringatan jika tanggal semester belum dikonfigurasi Staff TU |
| KF-13.3 | Sistem menghitung nilai akhir secara real-time dari 4 komponen: setoran (40%), UAS (40%), akhlaq (10%), kehadiran (10%) |
| KF-13.4 | Nilai setoran dihitung dari: Sabak 30% + Sabki 30% + Manzil 40% berbasis rasio baris aktual terhadap target semester, di-cap maksimal 100 |
| KF-13.5 | Target baris Manzil tidak memperhitungkan hari-hari yang masuk dalam periode Syahrul Quran |
| KF-13.6 | Nilai kehadiran hanya dikurangi oleh hari Alpha; Sakit dan Izin tidak mengurangi nilai kehadiran |
| KF-13.7 | Sistem menampilkan breakdown lengkap per komponen dalam kartu per santri |
| KF-13.8 | Sistem menampilkan badge status nilai akhir dengan warna: ≥85 Sangat Baik, 75-84 Baik, 60-74 Cukup, <60 Perlu Perhatian |
| KF-13.9 | Sistem menampilkan peringatan jika UAS atau nilai akhlaq belum diinput untuk santri tertentu |
| KF-13.10 | Pengampu dapat mengekspor nilai akhir semua santri halaqahnya ke file Excel (.xlsx) yang disimpan ke penyimpanan perangkat dan dapat dibagikan melalui share sheet |

---

### KU-14 — Pengampu dapat berkomunikasi dengan orang tua santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-14.1 | Pengampu dapat memilih santri untuk membuka thread pesan dengan orang tua santri tersebut |
| KF-14.2 | Pengampu dapat mengirim pesan teks ke orang tua kapan saja |
| KF-14.3 | Sistem menampilkan seluruh riwayat percakapan dalam format thread kronologis |
| KF-14.4 | Sistem menampilkan badge jumlah pesan belum dibaca dari orang tua pada ikon menu Pesan di navigation bar |
| KF-14.5 | Pesan dari orang tua otomatis ditandai sudah dibaca saat pengampu membuka layar Pesan untuk santri tersebut |

---

### KU-15 — Pengampu dapat menganalisis perkembangan halaqahnya

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-15.1 | Sistem menampilkan grafik rata-rata baris setoran per santri dalam periode tertentu |
| KF-15.2 | Sistem menampilkan grafik tren setoran per bulan untuk seluruh halaqah |
| KF-15.3 | Sistem menampilkan perbandingan pencapaian antar santri dalam halaqah yang sama |
| KF-15.4 | Pengampu dapat memfilter analitik berdasarkan santri tertentu |
| KF-15.5 | Sistem menampilkan indikator santri yang berstatus stagnant dalam daftar analitik |

---

### KU-16 — Pengampu dapat mengekspor laporan setoran harian halaqah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-16.1 | Pengampu dapat menyimpan data setoran 30 hari terakhir halaqahnya ke format Excel (.xlsx) ke penyimpanan perangkat atau dibagikan melalui share sheet |
| KF-16.2 | Pengampu dapat menyimpan data setoran 30 hari terakhir halaqahnya ke format PDF ke penyimpanan perangkat atau dibagikan melalui share sheet |
| KF-16.3 | File ekspor memuat informasi: nama santri, tanggal, surah/halaman, jumlah baris, kesalahan, dan status |
| KF-16.4 | File ekspor menyertakan header identitas sekolah dan tanggal cetak |

---

**Ringkasan Aktor Pengampu / Murobbi**

| | |
|-|-|
| Aktor | Pengampu / Murobbi |
| Kebutuhan | 16 kebutuhan user |
| Total KF | 87 kebutuhan fungsional |

| Kebutuhan User | Deskripsi | Jumlah KF |
|----------------|-----------|-----------|
| KU-01 | Akses sistem | 5 KF |
| KU-02 | Ringkasan harian halaqah | 6 KF |
| KU-03 | Input setoran Sabki | 8 KF |
| KU-04 | Input setoran Sabak | 8 KF |
| KU-05 | Input setoran Pekan Murajaah | 6 KF |
| KU-06 | Kelola Tikrar | 7 KF |
| KU-07 | Pantau Manzil | 5 KF |
| KU-08 | Absensi santri | 9 KF |
| KU-09 | Nilai Akhlaq | 6 KF |
| KU-10 | Ujian Kenaikan Juz (UKJ) | 12 KF |
| KU-11 | Ujian Akhir Semester (UAS) | 12 KF |
| KU-12 | Rekap Semester Excel | 11 KF |
| KU-13 | Nilai Akhir Semester | 10 KF |
| KU-14 | Komunikasi dengan orang tua | 5 KF |
| KU-15 | Analitik halaqah | 5 KF |
| KU-16 | Ekspor laporan harian | 4 KF |



## **Kebutuhan Fungsional — Aktor: Koordinator Tahfiz** 

## **KU-01 — Koordinator dapat mengakses sistem dengan kredensial yang diberikan Staff TU** 

## **Kode Kebutuhan Fungsional** 

KFSistem menyediakan mode login "Staff/Guru" dengan input email dan password 01.1 

KFSistem mengarahkan koordinator ke dashboard /koordinator setelah login berhasil 01.2 

KFSistem menerapkan rate limiting: 3 kali gagal login → dikunci sementara dengan countdown 01.3 eksponensial 

## **Kode Kebutuhan Fungsional** 

KFKoordinator dapat meminta reset password melalui fitur "Lupa Password" yang mengirim 01.4 link ke email terdaftar KFSistem memvalidasi password baru: minimal 8 karakter, mengandung huruf dan angka 01.5 

## **KU-02 — Koordinator dapat melihat ringkasan kondisi program tahfiz secara keseluruhan** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan total santri aktif dari seluruh halaqah 02.1 KFSistem menampilkan jumlah santri yang berstatus stagnant saat ini 02.2 KFSistem menampilkan jumlah hasil UKJ yang menunggu review koordinator 02.3 KFSistem menampilkan jumlah halaqah aktif yang sedang berjalan 02.4 KFSistem menampilkan popup pengumuman secara otomatis saat login jika ada pengumuman 02.5 baru yang ditujukan ke role koordinator KFSistem mencatat status sudah-dibaca per koordinator per pengumuman sehingga popup 02.6 tidak muncul ulang untuk pengumuman yang sama KFSistem mengirimkan notifikasi real-time ke koordinator saat ada santri yang statusnya 02.7 berubah menjadi stagnant 

## **KU-03 — Koordinator dapat mengelola grade santri** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan daftar semua santri dari seluruh halaqah beserta grade masing-masing 03.1 saat ini KFKoordinator dapat memfilter daftar santri berdasarkan halaqah tertentu 03.2 KFKoordinator dapat mengubah grade santri dari satu level ke level lain (Tahsin/Takmil/Tahfiz) 03.3 KFKoordinator wajib mengisi target baris harian baru dan alasan perubahan grade saat 03.4 melakukan perubahan 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan modal konfirmasi sebelum perubahan grade disimpan 03.5 KFSistem menyimpan riwayat perubahan grade ke tabel riwayat_grade: grade lama, grade 03.6 baru, target baris baru, alasan, dan waktu perubahan KFSistem mencatat perubahan grade ke audit_log dengan aksi UBAH_GRADE 03.7 KFSistem memperbarui kolom grade dan target_baris di tabel santri setelah perubahan 03.8 dikonfirmasi 

## **KU-04 — Koordinator dapat mengelola santri yang mengalami stagnasi** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan daftar semua santri yang berstatus stagnant beserta informasi halaqah 04.1 dan grade KFKoordinator dapat menambahkan catatan stagnasi untuk santri yang bermasalah: penyebab 04.2 (keluarga/psikososial/game/lainnya), detail, dan langkah korektif KFKoordinator dapat memperbarui status penanganan stagnasi: proses → dipantau → selesai 04.3 KFSistem menampilkan riwayat catatan stagnasi per santri secara kronologis 04.4 KFSistem menampilkan notifikasi real-time ke koordinator saat pengampu menandai santri baru 04.5 sebagai stagnant 

## **KU-05 — Koordinator dapat mereview dan memutuskan hasil Ujian Kenaikan Juz (UKJ)** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan daftar semua hasil UKJ dari seluruh halaqah yang masih berstatus 05.1 pending (belum direview) Sistem menampilkan informasi lengkap setiap UKJ pending: nama santri, halaqah, juz yang KFdiuji, tanggal ujian, jumlah kesalahan, status lulus/mengulang yang ditentukan pengampu, 05.2 dan grade 1-5 dari pengampu 

KFKoordinator dapat menyetujui hasil UKJ yang dinilai pengampu sudah sesuai 05.3 

## **Kode Kebutuhan Fungsional** 

KFKoordinator dapat menolak hasil UKJ dengan mengisi catatan alasan penolakan 05.4 KFSaat koordinator menyetujui UKJ, sistem mengirimkan notifikasi ke pengampu halaqah 05.5 terkait bahwa UKJ telah disetujui beserta informasi hasilnya KFSaat koordinator menolak UKJ, sistem mengirimkan notifikasi ke pengampu beserta catatan 05.6 alasan penolakan agar pengampu dapat menginput ulang KFSistem memperbarui status approved_by_koordinator menjadi true pada UKJ yang disetujui 05.7 KFSistem menampilkan badge jumlah UKJ pending pada ikon menu UKJ di sidebar sebagai 05.8 pengingat KFSistem menampilkan riwayat UKJ yang sudah disetujui dari semua halaqah 05.9 KF05.10[Koordinator dapat memfilter daftar UKJ berdasarkan halaqah, status, atau juz tertentu ] 

|**KU-06**|**— Koordinator dapat mengaktfan dan mengelola penilaian akhlaq**|
|---|---|
|**Kode**|**Kebutuhan Fungsional**|
|KF-|Koordinator dapat mengaktfan atau menonaktfan ftur input nilai akhlaq untuk semua|
|06.1|pengampu melalui toggle di dashboard|
|KF-<br>06.2|Saat toggle diaktfan, sistem memperbarui akhlaq_input_aktf = true di tabel system_confg|
|KF-|Koordinator dapat menetapkan label semester yang sedang aktf untuk penilaian akhlaq|
|06.3|(contoh: "Ganjil 2025/2026")|
|KF-|Label semester akhlaq disimpan ke akhlaq_semester_aktf di tabel system_confg dan|
|06.4|digunakan oleh semua pengampu sebagai acuan input|
|KF-<br>06.5|Jika toggle dinonaktfan, panel nilai akhlaq di dashboard pengampu tdak dapat diakses|



**KU-07 — Koordinator dapat menjadwalkan Pekan Murajaah Massal** 

## **Kode Kebutuhan Fungsional** 

Koordinator dapat membuat jadwal Pekan Murajaah Massal baru dengan mengisi tanggal KFmulai, tanggal selesai, materi ujian per kelas (kelas 7/8/9), batas kesalahan, dan deadline 07.1 akses KFSistem menyimpan jadwal Pekan Murajaah ke tabel jadwal_ujian dengan status aktif 07.2 KFSistem mengirimkan notifikasi real-time ke semua pengampu saat jadwal Pekan Murajaah 07.3 baru diaktifkan KFKoordinator dapat menghentikan jadwal Pekan Murajaah yang sedang berjalan sebelum 07.4 tanggal selesai 

KFSistem mengirimkan notifikasi real-time ke semua pengampu saat Pekan Murajaah 07.5 dihentikan 

KFSistem menampilkan daftar semua jadwal Pekan Murajaah beserta statusnya (aktif/selesai) 07.6 

## **KU-08 — Koordinator dapat mengelola hari libur dan tanggal merah** 

## **Kode Kebutuhan Fungsional** 

Koordinator dapat menambahkan hari libur baru dengan mengisi nama, tanggal mulai, KFtanggal selesai, jenis (libur nasional/libur semester/libur tahfiz mendadak), dan keterangan 08.1 opsional 

KFKoordinator dapat mengedit data hari libur yang sudah tersimpan 08.2 KFKoordinator dapat menghapus hari libur dengan konfirmasi terlebih dahulu 08.3 KFSistem menampilkan daftar semua hari libur yang sudah terdaftar dalam tabel 08.4 KFData hari libur digunakan oleh sistem rekap semester untuk mengecualikan hari-hari libur 08.5 dari perhitungan hari kerja dan target baris 

## **KU-09 — Koordinator dapat mengelola periode Syahrul Quran** 

## **Kode Kebutuhan Fungsional** 

KFKoordinator dapat menambahkan periode Syahrul Quran baru dengan mengisi nama 09.1 periode, tanggal mulai, tanggal selesai, dan target baris per grade 

## **Kode Kebutuhan Fungsional** 

|KF-<br>09.2|Koordinator dapat mengatur target baris harian khusus selama Syahrul Quran per grade:<br>Tahfz (default 30 baris/hari), Takmil (default 15 baris/hari), Tahsin (opsional: jika dikosongkan<br>maka menggunakan target baris individu santri)|
|---|---|
|KF-<br>09.3|Koordinator dapat mengedit periode Syahrul Quran yang sudah tersimpan|
|KF-<br>09.4|Koordinator dapat menghapus periode Syahrul Quran dengan konfrmasi terlebih dahulu|
|KF-<br>09.5|Sistem menampilkan dafar semua periode Syahrul Quran yang sudah terdafar dalam tabel|
|KF-|Selama periode Syahrul Quran berlaku, setoran Manzil tdak diperhitungkan dalam rekap dan|
|09.6|target baris menggunakan nilai yang dikonfgurasi koordinator|
|KF-|Pekan yang masuk dalam periode Syahrul Quran diberi tanda★pada rekap semester di|
|09.7|semua dashboard|



|**KU-10**|**— Koordinator dapat melihat rekap setoran semester seluruh santri**|
|---|---|
|**Kode**|**Kebutuhan Fungsional**|
|KF-<br>10.1|Koordinator dapat memilih semester (Ganjil/Genap) untuk melihat rekap setoran|
|KF-<br>10.2|Sistem menampilkan peringatan jika tanggal semester belum dikonfgurasi Staf TU|
|KF-|Koordinator dapat memflter rekap berdasarkan halaqah tertentu atau melihat semua|
|10.3|halaqah sekaligus|
|KF-<br>10.4|Sistem dapat menghasilkan preview rekap sebelum export untuk verifkasi data|
|KF-|Rekap dikelompokkan per pekan dengan label range tanggal dan setap santri ditampilkan|
|10.5|dalam 4 baris: Sabak, Sabki, Manzil, dan Target Tidak Tercapai|
|KF-|Setap pekan hanya menghitung hari kerja aktual: Senin-Jumat dikurangi hari libur dari tabel|
|10.6|hari_libur|
|KF-|Kolom Target Tidak Tercapai per pekan berisi jumlah hari kerja di mana baris Sabak santri|
|10.7|tdak mencapai target harian|
|KF-|Pekan yang masuk periode Syahrul Quran diberi tanda★dan kolom Manzil menampilkan "-|
|10.8|"|



## **Kode Kebutuhan Fungsional** 

KFHasil rekap dikelompokkan per halaqah dalam file Excel dengan pemisah antar halaqah yang 10.9 jelas KF10.10[Sistem menghasilkan file Excel (.xlsx) yang dapat langsung diunduh ] 

## **KU-11 — Koordinator dapat melihat nilai akhir semester seluruh santri** 

## **Kode Kebutuhan Fungsional** 

KFKoordinator dapat memilih semester untuk melihat nilai akhir seluruh santri 11.1 KFKoordinator dapat memfilter tampilan berdasarkan halaqah tertentu atau melihat semua 11.2 halaqah KFSistem menghitung nilai akhir secara real-time dari 4 komponen: setoran (40%), UAS (40%), 11.3 akhlaq (10%), kehadiran (10%) KFHasil ditampilkan dikelompokkan per halaqah dengan header pembatas antar halaqah 11.4 KFSistem menampilkan breakdown lengkap per komponen dalam kartu per santri 11.5 KFSistem menampilkan badge status nilai akhir dengan warna: ≥85 Sangat Baik, 75-84 Baik, 6011.6 74 Cukup, <60 Perlu Perhatian KFSistem menampilkan peringatan pada santri yang UAS atau nilai akhlaqnya belum diinput 11.7 KFKoordinator dapat mengekspor nilai akhir seluruh santri ke file Excel yang dikelompokkan 11.8 per halaqah 

## **KU-12 — Koordinator dapat menganalisis perkembangan program tahfiz** 

## **Kode Kebutuhan Fungsional** 

KF-12.1 Sistem menampilkan grafik perbandingan rata-rata baris setoran antar halaqah 

KF-12.2 Sistem menampilkan grafik tren setoran per bulan untuk seluruh program KF-12.3 Sistem menampilkan perbandingan jumlah santri lulus UKJ antar halaqah KF-12.4 Sistem menampilkan distribusi grade santri (Tahsin/Takmil/Tahfiz) saat ini 

## **Kode Kebutuhan Fungsional** 

KF-12.5 Koordinator dapat memfilter analitik berdasarkan halaqah atau periode waktu tertentu 

## **Ringkasan** 

Aktor       : Koordinator Tahfiz 

Kebutuhan   : 12 kebutuhan user 

Total KF    : 71 kebutuhan fungsional 

KU-01  Akses sistem                          →  5 KF KU-02  Ringkasan kondisi program             →  7 KF KU-03  Manajemen grade santri                →  8 KF KU-04  Manajemen stagnasi santri             →  5 KF KU-05  Review & keputusan UKJ               → 10 KF KU-06  Kelola penilaian akhlaq              →  5 KF KU-07  Jadwal Pekan Murajaah                →  6 KF KU-08  Kelola hari libur                     →  5 KF KU-09  Kelola periode Syahrul Quran         →  7 KF KU-10  Rekap semester semua santri           → 10 KF KU-11  Nilai akhir semester semua santri     →  8 KF KU-12  Analitik program                      →  5 KF 

## **Kebutuhan Fungsional — Aktor: Kepala Sekolah & Komite** 

## **KU-01 — Kepala Sekolah dapat mengakses sistem dengan kredensial yang diberikan Staff TU** 

## **Kode Kebutuhan Fungsional** 

KFSistem menyediakan mode login "Staff/Guru" dengan input email dan password 01.1 

KFSistem mengarahkan Kepala Sekolah ke dashboard /kepalasekolah setelah login berhasil 01.2 

KFSistem menerapkan rate limiting: 3 kali gagal login → dikunci sementara dengan countdown 01.3 eksponensial 

## **Kode Kebutuhan Fungsional** 

KFKepala Sekolah dapat meminta reset password melalui fitur "Lupa Password" yang mengirim 01.4 link ke email terdaftar KFSistem memvalidasi password baru: minimal 8 karakter, mengandung huruf dan angka 01.5 

## **KU-02 — Kepala Sekolah dapat melihat ringkasan eksekutif kondisi program tahfiz** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan sambutan personal dengan nama Kepala Sekolah yang sedang login 02.1 KFSistem menampilkan total santri aktif dari seluruh halaqah 02.2 KFSistem menampilkan jumlah santri yang berstatus stagnant saat ini 02.3 KFSistem menampilkan jumlah UKJ yang sudah lulus dan disetujui koordinator 02.4 KFSistem menampilkan total setoran yang telah tercatat dalam sistem 02.5 KFSistem menampilkan jumlah modul ajar yang tersedia di sistem 02.6 KFSistem menampilkan popup pengumuman secara otomatis saat login jika ada pengumuman 02.7 baru yang ditujukan ke role kepala_sekolah KFSistem mencatat status sudah-dibaca per Kepala Sekolah per pengumuman sehingga popup 02.8 tidak muncul ulang untuk pengumuman yang sama 

## **KU-03 — Kepala Sekolah dapat memantau perkembangan seluruh santri** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan daftar lengkap semua santri dari seluruh halaqah beserta informasi 03.1 grade, kelas, status aktif/stagnant, dan halaqah KFKepala Sekolah dapat memfilter daftar santri berdasarkan halaqah tertentu 03.2 KFKepala Sekolah dapat memfilter daftar santri berdasarkan status: aktif atau stagnant 03.3 

## **Kode Kebutuhan Fungsional** 

KFKepala Sekolah dapat memfilter daftar santri berdasarkan grade: Tahsin, Takmil, atau Tahfiz 03.4 KFSistem menampilkan informasi stagnasi santri jika ada: penyebab dan status penanganan 03.5 KFTampilan pemantauan bersifat read-only; Kepala Sekolah tidak dapat mengubah data santri 03.6 

## **KU-04 — Kepala Sekolah dapat menganalisis perkembangan program tahfiz secara mendalam** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan grafik perbandingan rata-rata baris setoran antar halaqah 04.1 menggunakan data historis keseluruhan (tidak dibatasi 30 hari) KFSistem menampilkan grafik tren setoran per bulan untuk seluruh program secara agregat 04.2 KFSistem menampilkan distribusi grade santri (Tahsin/Takmil/Tahfiz) dalam bentuk visual 04.3 KFSistem menampilkan perbandingan jumlah santri lulus UKJ antar halaqah 04.4 KFKepala Sekolah dapat memfilter analitik berdasarkan halaqah atau unit (Putra/Putri) 04.5 KFTampilan analitik bersifat read-only; Kepala Sekolah tidak dapat mengubah data apapun 04.6 

## **KU-05 — Kepala Sekolah dapat mengakses dan mengunduh modul ajar** 

## **Kode Kebutuhan Fungsional** 

KFSistem menampilkan daftar semua modul ajar yang tersedia di sistem beserta judul, ukuran 05.1 file, dan versi KFKepala Sekolah dapat mengunduh modul ajar yang tersedia 05.2 KFSistem mencatat setiap unduhan modul ke tabel log_unduh_modul dengan informasi: modul 05.3 yang diunduh, user yang mengunduh, dan waktu unduh KFSistem hanya menampilkan modul yang memiliki akses role kepala_sekolah 05.4 

## **KU-06 — Kepala Sekolah dapat mengelola dan mengunduh laporan program** 

## **Kode Kebutuhan Fungsional** 

|KF-|Sistem menampilkan dafar laporan yang sudah dibuat beserta judul, tpe|
|---|---|
|06.1|(mingguan/bulanan/semesteran/tahunan), periode, dan status (draf/divalidasi/diarsip)|
|KF-<br>06.2|Kepala Sekolah dapat mengunduh laporan yang sudah tersedia|
|KF-|Kepala Sekolah dapat memvalidasi laporan dengan mengubah status dari draf menjadi|
|06.3|divalidasi|
|KF-|Kepala Sekolah dapat mengarsipkan laporan yang sudah divalidasi dengan mengubah status|
|06.4|menjadi diarsip|
|KF-<br>06.5|Sistem mencatat nama Kepala Sekolah dan waktu validasi pada laporan yang divalidasi|
|KF-<br>06.6|Kepala Sekolah dapat memflter dafar laporan berdasarkan tpe atau status|



## **KU-07 — Kepala Sekolah dapat melihat rekap setoran semester seluruh santri** 

|**Kode**|**Kebutuhan Fungsional**|
|---|---|
|KF-<br>07.1|Kepala Sekolah dapat memilih semester (Ganjil/Genap) untuk melihat rekap setoran|
|KF-<br>07.2|Sistem menampilkan peringatan jika tanggal semester belum dikonfgurasi Staf TU|
|KF-|Kepala Sekolah dapat memflter rekap berdasarkan halaqah tertentu atau melihat semua|
|07.3|halaqah sekaligus|
|KF-<br>07.4|Sistem dapat menghasilkan preview rekap sebelum export untuk verifkasi data|
|KF-|Rekap dikelompokkan per pekan dengan label range tanggal dan setap santri ditampilkan|
|07.5|dalam 4 baris: Sabak, Sabki, Manzil, dan Target Tidak Tercapai|
|KF-|Setap pekan hanya menghitung hari kerja aktual: Senin-Jumat dikurangi hari libur dari tabel|
|07.6|hari_libur|
|KF-|Kolom Target Tidak Tercapai per pekan berisi jumlah hari kerja di mana baris Sabak santri|
|07.7|tdak mencapai target harian|



## **Kode Kebutuhan Fungsional** 

|KF-|Pekan yang masuk periode Syahrul Quran diberi tanda★dan kolom Manzil menampilkan "-|
|---|---|
|07.8|"|
|KF-|Hasil rekap dikelompokkan per halaqah dalam fle Excel dengan pemisah antar halaqah yang|
|07.9|jelas|
|KF-<br>07.10|Sistem menghasilkan fle Excel (.xlsx) yang dapat langsung diunduh|



## **KU-08 — Kepala Sekolah dapat melihat nilai akhir semester seluruh santri** 

## **Kode Kebutuhan Fungsional** 

|KF-<br>08.1|Kepala Sekolah dapat memilih semester untuk melihat nilai akhir seluruh santri|
|---|---|
|KF-|Kepala Sekolah dapat memflter tampilan berdasarkan halaqah tertentu atau melihat semua|
|08.2|halaqah|
|KF-|Sistem menghitung nilai akhir secara real-tme dari 4 komponen: setoran (40%), UAS (40%),|
|08.3|akhlaq (10%), kehadiran (10%)|
|KF-<br>08.4|Hasil ditampilkan dikelompokkan per halaqah dengan header pembatas antar halaqah|
|KF-<br>08.5|Sistem menampilkan breakdown lengkap per komponen nilai dalam kartu per santri|
|KF-|Sistem menampilkan badge status nilai akhir dengan warna: ≥85 Sangat Baik, 75-84 Baik, 60-|
|08.6|74 Cukup, <60 Perlu Perhatan|
|KF-<br>08.7|Sistem menampilkan peringatan pada santri yang UAS atau nilai akhlaqnya belum diinput|
|KF-|Kepala Sekolah dapat mengekspor nilai akhir seluruh santri ke fle Excel yang dikelompokkan|
|08.8|per halaqah|
|KF-|Tampilan nilai akhir bersifat read-only; Kepala Sekolah tdak dapat mengubah komponen|
|08.9|nilai apapun|



## **Ringkasan** 

Aktor       : Kepala Sekolah & Komite 

Kebutuhan   : 8 kebutuhan user 

Total KF    : 52 kebutuhan fungsional 

KU-01  Akses sistem                          →  5 KF KU-02  Ringkasan eksekutif                   →  8 KF KU-03  Pemantauan seluruh santri             →  6 KF KU-04  Analitik program tahfiz               →  6 KF KU-05  Akses modul ajar                      →  4 KF KU-06  Kelola dan unduh laporan              →  6 KF KU-07  Rekap semester semua santri           → 10 KF KU-08  Nilai akhir semester semua santri     →  9 KF 

## Catatan: 

Kepala Sekolah adalah aktor monitoring eksklusif. 

Dari 52 KF, hanya 2 yang bersifat write: 

- KF-06.3 (validasi laporan) 

- KF-06.4 (arsipkan laporan) 

## Kebutuhan Fungsional — Aktor: Staff Tata Usaha (TU)

---

### KU-01 — Staff TU dapat mengakses sistem dengan kredensial yang telah ditetapkan

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-01.1 | Sistem menyediakan mode login "Staff/Guru" dengan input email dan password |
| KF-01.2 | Sistem mengarahkan Staff TU ke layar utama Staff TU setelah login berhasil |
| KF-01.3 | Sistem menerapkan rate limiting: 3 kali gagal login → dikunci sementara dengan countdown timer eksponensial yang ditampilkan di layar login aplikasi |
| KF-01.4 | Staff TU dapat meminta reset password melalui fitur "Lupa Password" yang mengirim link ke email terdaftar |
| KF-01.5 | Sistem memvalidasi password baru: minimal 8 karakter, mengandung huruf dan angka |
| KF-01.6 | Staff TU tetap dapat mengakses sistem saat Maintenance Mode aktif; semua role lain tidak dapat masuk |

---

### KU-02 — Staff TU dapat melihat ringkasan statistik sistem secara keseluruhan

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-02.1 | Sistem menampilkan sambutan personal dengan nama Staff TU yang sedang login |
| KF-02.2 | Sistem menampilkan total santri yang terdaftar di sistem |
| KF-02.3 | Sistem menampilkan total halaqah aktif yang sedang berjalan |
| KF-02.4 | Sistem menampilkan total pengguna yang terdaftar di sistem dari semua role |
| KF-02.5 | Sistem menampilkan total setoran yang tercatat dalam 30 hari terakhir |
| KF-02.6 | Sistem menampilkan informasi database dan platform backend yang digunakan sistem |
| KF-02.7 | Sistem menampilkan informasi backup terakhir (simulasi; backup nyata dikelola otomatis oleh Supabase) |

---

### KU-03 — Staff TU dapat mengelola data santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-03.1 | Sistem menampilkan daftar semua santri yang terdaftar beserta informasi nama, NIS, kelas, grade, halaqah, dan status |
| KF-03.2 | Staff TU dapat mencari santri berdasarkan nama atau NIS menggunakan fitur pencarian |
| KF-03.3 | Staff TU dapat memfilter daftar santri berdasarkan halaqah tertentu |
| KF-03.4 | Staff TU dapat menambahkan santri baru secara manual dengan mengisi: nama, NIS (opsional), kelas, grade, target baris, halaqah, nama orang tua, dan nomor HP orang tua |
| KF-03.5 | Staff TU dapat mengedit data santri yang sudah terdaftar |
| KF-03.6 | Staff TU dapat menghapus data santri dengan konfirmasi terlebih dahulu |
| KF-03.7 | Sistem mencatat penghapusan santri ke audit_log dengan aksi HAPUS_SANTRI beserta detail nama santri yang dihapus |
| KF-03.8 | Sistem menampilkan dialog pengumuman secara otomatis saat Staff TU masuk ke layar utama jika ada pengumuman baru yang ditujukan ke role tata_usaha |

> **Catatan Operasional:** Penginputan data santri secara massal di awal tahun ajaran dilakukan melalui Supabase Dashboard menggunakan fitur CSV import bawaan Supabase oleh administrator teknis. Fitur import massal tidak disediakan melalui antarmuka aplikasi.

---

### KU-04 — Staff TU dapat mengelola data halaqah

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-04.1 | Sistem menampilkan daftar semua halaqah aktif beserta nama, unit (Putra/Putri), nama pengampu, dan jumlah santri |
| KF-04.2 | Staff TU dapat menambahkan halaqah baru dengan mengisi nama, unit, dan memilih pengampu dari daftar akun pengampu yang terdaftar |
| KF-04.3 | Staff TU dapat mengedit nama, unit, atau pengampu dari halaqah yang sudah ada |
| KF-04.4 | Staff TU dapat menonaktifkan halaqah yang sudah tidak digunakan |
| KF-04.5 | Sistem hanya menampilkan akun dengan role pengampu sebagai pilihan saat menentukan pengampu halaqah |

---

### KU-05 — Staff TU dapat mengelola akun pengguna sistem

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-05.1 | Sistem menampilkan daftar semua pengguna terdaftar beserta nama, email, nomor HP, role, dan status aktif/nonaktif |
| KF-05.2 | Staff TU dapat mencari pengguna berdasarkan nama atau email menggunakan fitur pencarian |
| KF-05.3 | Staff TU dapat membuat akun pengampu baru dengan mengisi nama lengkap, nomor HP (opsional), dan email (opsional; jika tidak diisi sistem auto-generate dari nama) |
| KF-05.4 | Staff TU dapat membuat akun wali santri baru dengan mengisi nama lengkap dan nomor HP (wajib) |
| KF-05.5 | Saat membuat akun wali, sistem secara otomatis mengonstruksi email dengan format {nomor_hp}@jamilurrahman.sch.id dan menggunakan nomor HP yang sama sebagai password default |
| KF-05.6 | Sistem menampilkan info box secara live yang menunjukkan email dan password yang akan digunakan wali untuk login saat Staff TU mengisi nomor HP |
| KF-05.7 | Sistem menyimpan nomor HP wali ke kolom no_hp di tabel users sebagai referensi |
| KF-05.8 | Staff TU dapat mengaktifkan atau menonaktifkan akun pengguna tertentu |
| KF-05.9 | Staff TU dapat menetapkan password baru untuk akun pengampu atau Staff/Guru secara langsung dengan menginput password baru (minimal 8 karakter) tanpa memerlukan alur email |
| KF-05.10 | Staff TU dapat mereset password akun wali santri kembali ke nomor HP terdaftarnya |
| KF-05.11 | Sistem menampilkan kolom nomor HP di tabel daftar pengguna dan menampilkan label "Login via HP" untuk akun wali yang memiliki nomor HP terdaftar |
| KF-05.12 | Sistem menampilkan konfirmasi sebelum Staff TU melakukan reset password akun wali |

---

### KU-06 — Staff TU dapat mengelola relasi antara akun wali dan data santri

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-06.1 | Sistem menampilkan daftar semua santri beserta status relasi orang tua: sudah terhubung atau belum |
| KF-06.2 | Staff TU dapat menghubungkan santri ke akun wali yang sudah terdaftar |
| KF-06.3 | Satu akun wali dapat dihubungkan ke lebih dari satu santri untuk mengakomodasi wali yang memiliki lebih dari satu anak di sekolah |
| KF-06.4 | Staff TU dapat memutuskan relasi antara santri dan akun wali jika diperlukan |
| KF-06.5 | Sistem memperbarui kolom parent_user_id di tabel santri saat relasi dibuat atau diputuskan |
| KF-06.6 | Sistem hanya menampilkan akun dengan role orangtua sebagai pilihan saat menghubungkan santri ke wali |

---

### KU-07 — Staff TU dapat mengelola konfigurasi sistem

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-07.1 | Staff TU dapat mengaktifkan Maintenance Mode melalui toggle di layar Konfigurasi Sistem |
| KF-07.2 | Sistem menampilkan dialog konfirmasi sebelum Maintenance Mode diaktifkan, menjelaskan bahwa semua pengguna selain Staff TU tidak akan dapat mengakses aplikasi |
| KF-07.3 | Saat Maintenance Mode diaktifkan, sistem memperbarui maintenance_mode = true di tabel system_config dan route guard Flutter secara otomatis menampilkan layar maintenance serta memblokir seluruh navigasi bagi semua role selain tata_usaha |
| KF-07.4 | Layar maintenance melakukan pengecekan status secara berkala dan mengarahkan pengguna kembali ke layar login saat Maintenance Mode dimatikan |
| KF-07.5 | Staff TU dapat menonaktifkan Maintenance Mode melalui toggle yang sama |
| KF-07.6 | Sistem mencatat aktivasi dan deaktivasi Maintenance Mode ke audit_log dengan aksi MAINTENANCE_ON dan MAINTENANCE_OFF |
| KF-07.7 | Staff TU dapat mengatur tanggal mulai dan tanggal selesai Semester Ganjil |
| KF-07.8 | Staff TU dapat mengatur tanggal mulai dan tanggal selesai Semester Genap |
| KF-07.9 | Sistem menyimpan keempat tanggal semester ke tabel system_config dengan keys: semester_ganjil_mulai, semester_ganjil_selesai, semester_genap_mulai, semester_genap_selesai |
| KF-07.10 | Sistem memvalidasi bahwa tanggal selesai semester harus setelah tanggal mulai sebelum menyimpan |
| KF-07.11 | Konfigurasi tanggal semester digunakan oleh fitur Rekap Semester dan Nilai Akhir di semua layar dashboard |

---

### KU-08 — Staff TU dapat melakukan koreksi data setoran yang salah diinput

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-08.1 | Staff TU dapat mencari setoran berdasarkan kombinasi nama santri dan tanggal |
| KF-08.2 | Sistem menampilkan hasil pencarian setoran dalam tabel: tipe (Sabak/Sabki/Manzil), surah, jumlah baris, kesalahan, dan status |
| KF-08.3 | Staff TU dapat menghapus setoran yang salah diinput dengan konfirmasi terlebih dahulu |
| KF-08.4 | Fitur koreksi setoran hanya digunakan untuk menghapus data entry yang salah, bukan untuk memanipulasi nilai |

---

### KU-09 — Staff TU dapat memantau riwayat aktivitas pengguna di sistem

| Kode | Kebutuhan Fungsional |
|------|----------------------|
| KF-09.1 | Sistem menampilkan seluruh riwayat aktivitas penting dari semua pengguna yang tercatat di tabel audit_log |
| KF-09.2 | Setiap entri riwayat menampilkan informasi: waktu kejadian, nama pengguna, jenis aksi, tabel yang menjadi target, dan detail tambahan dalam format yang mudah dibaca |
| KF-09.3 | Jenis aksi ditampilkan dalam format yang ramah pembaca (contoh: APPROVE_UKJ ditampilkan sebagai "✓ Approve UKJ") |
| KF-09.4 | Staff TU dapat memfilter riwayat berdasarkan nama pengguna |
| KF-09.5 | Staff TU dapat memfilter riwayat berdasarkan jenis aksi dari daftar dropdown |
| KF-09.6 | Staff TU dapat memfilter riwayat berdasarkan rentang tanggal (dari tanggal hingga tanggal) |
| KF-09.7 | Staff TU dapat mereset semua filter ke kondisi awal dengan satu ketukan |
| KF-09.8 | Sistem menampilkan total jumlah entri yang sesuai filter dan informasi halaman yang sedang ditampilkan |
| KF-09.9 | Sistem menerapkan pagination dengan 20 entri per halaman untuk menjaga performa |
| KF-09.10 | Staff TU dapat berpindah antar halaman menggunakan tombol navigasi halaman |

---

**Ringkasan Aktor Staff Tata Usaha (TU)**

| | |
|-|-|
| Aktor | Staff Tata Usaha (TU) |
| Kebutuhan | 9 kebutuhan user |
| Total KF | 69 kebutuhan fungsional |

| Kebutuhan User | Deskripsi | Jumlah KF |
|----------------|-----------|-----------|
| KU-01 | Akses sistem | 6 KF |
| KU-02 | Ringkasan statistik sistem | 7 KF |
| KU-03 | Manajemen data santri | 8 KF |
| KU-04 | Manajemen halaqah | 5 KF |
| KU-05 | Manajemen akun pengguna | 12 KF |
| KU-06 | Relasi wali dan santri | 6 KF |
| KU-07 | Konfigurasi sistem | 11 KF |
| KU-08 | Koreksi data setoran | 4 KF |
| KU-09 | Riwayat aktivitas audit log | 10 KF |

> **Catatan:** Staff TU adalah aktor dengan akses write terluas di sistem dan satu-satunya aktor yang dapat mengaktifkan Maintenance Mode, membuat dan mereset akun pengguna, mengonfigurasi tanggal semester, mengakses sistem saat Maintenance Mode aktif, serta menghapus data setoran untuk keperluan koreksi.

## **4. Kebutuhan Non-Fungsional (Non-Functional Requirements)** 

## 4. Kebutuhan Non-Fungsional

---

### 4.1 Kebutuhan Performa

Kebutuhan performa mendefinisikan batas waktu respons dan kapasitas yang harus dipenuhi sistem agar dapat digunakan secara nyaman oleh seluruh pengguna.

#### 4.1.1 Waktu Respons Antarmuka

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-01.1 | Layar login aplikasi harus siap digunakan dalam waktu tidak lebih dari 3 detik pada koneksi internet dengan kecepatan minimal 5 Mbps |
| KNF-01.2 | Perpindahan antar layar di dalam aplikasi harus selesai dalam waktu tidak lebih dari 1 detik |
| KNF-01.3 | Operasi simpan setoran harian (insert/update ke Supabase) harus memberikan respons konfirmasi kepada pengampu dalam waktu tidak lebih dari 3 detik |
| KNF-01.4 | Query data santri dan setoran untuk keperluan tampilan layar utama harus selesai dalam waktu tidak lebih dari 5 detik meskipun jumlah santri telah mencapai 200 orang |
| KNF-01.5 | Notifikasi real-time in-app (konfirmasi Manzil, selesai Tikrar) harus diterima oleh pihak yang dituju dalam waktu tidak lebih dari 5 detik setelah aksi dipicu, dalam kondisi koneksi internet stabil |

#### 4.1.2 Performa Ekspor File

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-01.6 | Proses generate file Excel rekap semester untuk satu halaqah (maksimal 20 santri, satu semester) hingga siap disimpan atau dibagikan harus selesai dalam waktu tidak lebih dari 10 detik |
| KNF-01.7 | Proses generate file Excel nilai akhir semester untuk satu halaqah hingga siap disimpan atau dibagikan harus selesai dalam waktu tidak lebih dari 10 detik |
| KNF-01.8 | Proses generate file PDF laporan setoran harian hingga siap disimpan atau dibagikan harus selesai dalam waktu tidak lebih dari 8 detik |
| KNF-01.9 | Proses kalkulasi nilai akhir semester secara real-time untuk seluruh santri satu halaqah (maksimal 20 santri) harus selesai dalam waktu tidak lebih dari 15 detik |

#### 4.1.3 Kapasitas Sistem

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-01.10 | Sistem harus mampu menangani minimal 20 pengguna yang mengakses secara bersamaan tanpa penurunan performa yang signifikan |
| KNF-01.11 | Sistem harus mampu menyimpan data setoran kumulatif hingga 3 tahun operasional (estimasi: ±50.000 record setoran) tanpa penurunan performa query |
| KNF-01.12 | Sistem harus mampu menyimpan file tanda tangan digital hingga 10.000 file gambar di Supabase Storage tanpa mempengaruhi performa sistem |

#### 4.1.4 Performa Offline dan Push Notification

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-01.13 | Sinkronisasi data offline ke server harus selesai dalam waktu tidak lebih dari 10 detik setelah koneksi internet tersedia kembali, untuk data setoran dan absensi yang tersimpan secara lokal di perangkat |
| KNF-01.14 | Push notification harus diterima perangkat dalam waktu tidak lebih dari 10 detik setelah aksi dipicu di server, dalam kondisi koneksi internet stabil |

---

### 4.2 Kebutuhan Keamanan

Kebutuhan keamanan mendefinisikan mekanisme perlindungan data dan akses yang harus diterapkan sistem untuk menjaga kerahasiaan, integritas, dan ketersediaan data.

#### 4.2.1 Autentikasi

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-02.1 | Sistem harus menggunakan mekanisme autentikasi berbasis Supabase Auth dengan JWT (JSON Web Token) untuk semua role pengguna |
| KNF-02.2 | Token autentikasi (access token dan refresh token) harus disimpan menggunakan flutter_secure_storage yang memanfaatkan Keystore Android untuk enkripsi di level perangkat; token tidak boleh disimpan di SharedPreferences atau memori yang tidak terenkripsi |
| KNF-02.3 | Sesi login harus kedaluwarsa secara otomatis setelah periode tidak aktif sesuai konfigurasi Supabase Auth |
| KNF-02.4 | Sistem harus menerapkan rate limiting login: pengguna yang gagal login sebanyak 3 kali berturut-turut dikunci sementara dengan durasi yang meningkat secara eksponensial (30 detik, 60 detik, 120 detik, dst.) |
| KNF-02.5 | Password pengguna baru atau hasil reset harus memenuhi syarat minimum: panjang minimal 8 karakter, mengandung minimal 1 huruf dan 1 angka |

#### 4.2.2 Otorisasi dan Kontrol Akses

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-02.6 | Sistem harus menerapkan Role-Based Access Control (RBAC) melalui route guard di Flutter yang memverifikasi role pengguna dari flutter_secure_storage sebelum setiap perpindahan layar |
| KNF-02.7 | Sistem harus menerapkan Row Level Security (RLS) di seluruh tabel Supabase sehingga akses data di level database pun dibatasi berdasarkan role pengguna yang terautentikasi |
| KNF-02.8 | Pengguna yang tidak memiliki sesi aktif harus secara otomatis diarahkan ke layar login saat mencoba mengakses layar yang membutuhkan autentikasi |
| KNF-02.9 | Pengguna yang sudah login namun mencoba mengakses layar role lain harus secara otomatis diarahkan ke layar utama role-nya sendiri |
| KNF-02.10 | Selama Maintenance Mode aktif, route guard Flutter harus memblokir akses seluruh role kecuali tata_usaha dan menampilkan layar maintenance |

#### 4.2.3 Keamanan Data

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-02.11 | Seluruh komunikasi antara aplikasi Flutter dan server harus menggunakan protokol HTTPS/TLS; sistem tidak boleh beroperasi melalui HTTP biasa di environment production |
| KNF-02.12 | Nomor HP orang tua yang berfungsi sebagai kredensial login tidak boleh ditampilkan secara lengkap di antarmuka manapun selain saat proses pembuatan akun oleh Staff TU |
| KNF-02.13 | File tanda tangan digital yang diunggah ke Supabase Storage harus hanya dapat diakses oleh pengguna yang terautentikasi; bucket tidak boleh bersifat public |
| KNF-02.14 | Nilai sensitif seperti Supabase URL dan Supabase Anon Key tidak boleh di-hardcode dalam kode sumber; nilai tersebut harus disimpan sebagai environment variable saat build menggunakan --dart-define dan tidak boleh dicommit ke repositori GitHub |
| KNF-02.15 | File konfigurasi yang mengandung API key dan URL Supabase harus terdaftar dalam .gitignore dan tidak boleh pernah masuk ke repositori publik |
| KNF-02.16 | FCM Server Key yang digunakan untuk mengirim push notification harus disimpan di sisi Supabase Edge Function; tidak boleh disertakan dalam kode aplikasi Flutter yang dapat di-decompile |

#### 4.2.4 Audit dan Keterlacakan

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-02.17 | Seluruh aksi kritis di sistem (ubah grade, hapus santri, approve/tolak UKJ, aktivasi maintenance mode) harus dicatat ke tabel audit_log dengan informasi: user yang melakukan, waktu kejadian, aksi, dan detail perubahan |
| KNF-02.18 | Data audit_log bersifat append-only; tidak boleh ada mekanisme edit atau hapus entri audit_log melalui antarmuka sistem manapun |
| KNF-02.19 | Entri audit_log harus menyimpan nama pengguna secara eksplisit (bukan hanya UUID) untuk kemudahan pembacaan riwayat tanpa perlu join ke tabel users |

---

### 4.3 Kebutuhan Ketersediaan dan Keandalan

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-03.1 | Sistem harus mengikuti Service Level Agreement (SLA) ketersediaan Supabase sebagai platform backend yang digunakan; target uptime minimal 99% per bulan |
| KNF-03.2 | Sistem harus menampilkan pesan error yang informatif dan ramah pengguna saat terjadi kegagalan koneksi ke Supabase, bukan menampilkan pesan teknis mentah |
| KNF-03.3 | Kegagalan pengiriman notifikasi real-time (misalnya karena koneksi WebSocket terputus) tidak boleh menyebabkan kegagalan pada operasi utama seperti penyimpanan setoran atau absensi; notifikasi bersifat best-effort |
| KNF-03.4 | Kegagalan insert notifikasi Alpha ke tabel notifikasi tidak boleh membatalkan penyimpanan data absensi yang sudah berhasil; keduanya harus ditangani secara independen |
| KNF-03.5 | Sistem harus menyimpan data secara persisten di Supabase PostgreSQL; tidak ada data kritis yang hanya disimpan di memori aplikasi yang dapat hilang saat aplikasi ditutup |
| KNF-03.6 | Data setoran dan absensi yang tersimpan secara offline di lokal perangkat tidak boleh hilang meskipun aplikasi ditutup paksa atau perangkat dimatikan; Drift (SQLite) harus memastikan persistensi data lokal hingga berhasil disinkronisasi ke server |
| KNF-03.7 | Fitur Maintenance Mode harus dapat diaktifkan oleh Staff TU kapan saja tanpa downtime tambahan; aplikasi tetap dapat diakses Staff TU selama maintenance berlangsung |
| KNF-03.8 | Backup database dilakukan secara otomatis oleh infrastruktur Supabase; sistem tidak perlu menyediakan mekanisme backup mandiri namun Staff TU harus mendapat informasi cara mengakses backup melalui Supabase Dashboard |

---

### 4.4 Kebutuhan Kemudahan Penggunaan (Usability)

#### 4.4.1 Kemudahan Umum

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-04.1 | Antarmuka aplikasi harus dapat digunakan oleh pengampu baru tanpa pelatihan formal lebih dari 30 menit; navigasi antar layar harus intuitif dan konsisten di seluruh bagian aplikasi |
| KNF-04.2 | Setiap aksi yang berhasil (simpan setoran, hapus data, ubah status) harus memberikan konfirmasi visual kepada pengguna dalam bentuk notifikasi toast yang muncul otomatis |
| KNF-04.3 | Setiap aksi yang gagal harus menampilkan pesan error yang menjelaskan penyebab kegagalan dalam bahasa Indonesia yang dapat dipahami pengguna non-teknis |
| KNF-04.4 | Setiap aksi yang bersifat destruktif (hapus santri, hapus UKJ, nonaktifkan akun) harus meminta konfirmasi eksplisit dari pengguna sebelum dieksekusi |
| KNF-04.5 | Sistem harus memberikan indikator loading yang jelas (spinner atau skeleton) saat proses pengambilan data berlangsung sehingga pengguna mengetahui sistem sedang bekerja |
| KNF-04.6 | Aplikasi harus mendukung tampilan gelap (dark mode) dan terang (light mode) yang dapat mengikuti pengaturan sistem perangkat Android; implementasi menggunakan ThemeMode Flutter |
| KNF-04.7 | Aplikasi harus menampilkan indikator status koneksi yang jelas ketika perangkat dalam mode offline, beserta informasi data mana yang tersimpan secara lokal dan belum tersinkronisasi ke server |
| KNF-04.8 | Aplikasi harus mendukung berbagai ukuran layar perangkat Android dari smartphone 5 inci hingga tablet 10 inci tanpa perbedaan fungsionalitas |

#### 4.4.2 Kemudahan Khusus untuk Orang Tua

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-04.9 | Layar login aplikasi harus menampilkan mode "Wali Santri" secara jelas dan terpisah dari mode login Staff/Guru, sehingga orang tua tidak bingung dengan form login standar |
| KNF-04.10 | Proses login orang tua hanya memerlukan satu input (nomor HP) tanpa perlu mengingat email atau password terpisah |
| KNF-04.11 | Widget tanda tangan digital untuk validasi Manzil harus responsif terhadap sentuhan jari pada layar smartphone dan tidak memerlukan stylus khusus; implementasi menggunakan Flutter touch widget |
| KNF-04.12 | Ukuran teks dan elemen interaktif (tombol, input) di antarmuka orang tua harus cukup besar untuk dioperasikan dengan jari pada layar smartphone berukuran minimal 5 inci |

#### 4.4.3 Kemudahan Khusus untuk Pengampu

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-04.13 | Form input setoran harian harus dapat diselesaikan pengampu dalam waktu tidak lebih dari 2 menit per santri |
| KNF-04.14 | Sistem harus menampilkan status setoran hari ini per santri secara visual di daftar santri (badge warna) sehingga pengampu dapat langsung melihat siapa yang sudah dan belum setor tanpa perlu membuka setiap profil santri |
| KNF-04.15 | Jika setoran sudah diinput hari ini, form harus secara otomatis beralih ke mode Edit dan menampilkan data yang sudah ada, sehingga pengampu tidak perlu mencari tombol edit secara manual |

---

### 4.5 Kebutuhan Kompatibilitas

#### 4.5.1 Kompatibilitas Platform Android

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-05.1 | Aplikasi harus kompatibel dengan perangkat Android versi 5.0 (API Level 21) ke atas |
| KNF-05.2 | Aplikasi harus kompatibel dengan berbagai ukuran layar dan densitas piksel perangkat Android yang beragam |
| KNF-05.3 | Aplikasi harus menggunakan SafeArea Flutter untuk memastikan konten tidak tertutup oleh notch, status bar, atau navigation bar perangkat Android |
| KNF-05.4 | Fitur push notification menggunakan FCM harus kompatibel dengan perangkat Android yang memiliki Google Play Services terinstal |

#### 4.5.2 Kompatibilitas Format File

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-05.5 | File ekspor rekap dan nilai akhir harus menggunakan format .xlsx yang kompatibel dengan Microsoft Excel 2013 ke atas dan Google Sheets |
| KNF-05.6 | File ekspor laporan harian harus menggunakan format .pdf yang dapat dibuka pada semua PDF reader standar di Android |

Ini Bab 4 (lanjutan 4.6–4.9) dan Bab 5 lengkap yang sudah diperbarui, siap copas:

---

```markdown
### 4.6 Kebutuhan Skalabilitas

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-06.1 | Arsitektur sistem harus mampu mengakomodasi penambahan jumlah santri hingga 500 santri tanpa perubahan struktural pada skema database |
| KNF-06.2 | Arsitektur sistem harus mampu mengakomodasi penambahan halaqah baru tanpa perubahan kode; penambahan halaqah cukup dilakukan melalui antarmuka manajemen halaqah oleh Staff TU |
| KNF-06.3 | Sistem harus dirancang agar penambahan role pengguna baru di masa mendatang dapat dilakukan melalui perubahan minimal pada route guard Flutter dan tidak memerlukan perombakan arsitektur |
| KNF-06.4 | Skema database harus menggunakan UUID sebagai primary key di seluruh tabel untuk mengantisipasi kebutuhan skalabilitas dan menghindari konflik ID saat migrasi data |

---

### 4.7 Kebutuhan Pemeliharaan (Maintainability)

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-07.1 | Seluruh model data Dart harus didefinisikan sebagai class terpusat di direktori `lib/models/` lengkap dengan method `fromJson()` dan `toJson()`; tidak boleh ada duplikasi definisi model di file widget manapun |
| KNF-07.2 | Setiap layar role harus dipecah menjadi widget fitur yang terpisah sehingga perubahan pada satu fitur tidak mempengaruhi fitur lain dalam layar yang sama |
| KNF-07.3 | Logika kalkulasi akademik yang kompleks (perhitungan hari kerja, rekap semester, nilai akhir) harus dipisahkan ke dalam file utilitas tersendiri di direktori `lib/utils/` dan tidak boleh dituliskan langsung di dalam widget |
| KNF-07.4 | Konfigurasi yang dapat berubah sesuai kebijakan sekolah (tanggal semester, status maintenance, status akhlaq aktif, label semester akhlaq) harus disimpan di tabel `system_config` dan tidak boleh di-hardcode di dalam kode |
| KNF-07.5 | Repositori kode harus disimpan di GitHub dengan branching strategy yang jelas; build APK production dilakukan menggunakan `flutter build apk --release` dengan signing key yang sudah disiapkan |
| KNF-07.6 | Setiap widget yang digunakan di lebih dari satu layar harus ditempatkan di direktori `lib/widgets/shared/` sebagai shared widget dan tidak boleh diduplikasi |

---

### 4.8 Kebutuhan Lokalisasi

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-08.1 | Seluruh teks antarmuka, pesan error, pesan sukses, dan label form harus menggunakan Bahasa Indonesia |
| KNF-08.2 | Format tanggal yang ditampilkan kepada pengguna harus menggunakan format Indonesia (contoh: "Senin, 2 Juni 2025") menggunakan package `intl` Flutter dengan `DateFormat('EEEE, d MMMM yyyy', 'id_ID')` |
| KNF-08.3 | Format angka dalam rekap dan laporan harus menggunakan format Indonesia (koma sebagai desimal jika diperlukan) |
| KNF-08.4 | Nama bulan dan hari yang ditampilkan di seluruh antarmuka dan file ekspor harus menggunakan Bahasa Indonesia |

---

### 4.9 Kebutuhan Portabilitas

| Kode | Kebutuhan Non-Fungsional |
|------|--------------------------|
| KNF-09.1 | Sistem harus dapat dimigrasikan ke akun Supabase yang berbeda (misalnya dari akun pengembang ke akun resmi sekolah) hanya dengan mengubah nilai `--dart-define=SUPABASE_URL` dan `--dart-define=SUPABASE_ANON_KEY` saat build tanpa perubahan kode |
| KNF-09.2 | APK yang didistribusikan harus dapat diinstal ulang di perangkat manapun tanpa memerlukan konfigurasi tambahan dari sisi pengguna selain memberikan izin instalasi dari sumber tidak dikenal |
| KNF-09.3 | Skema database harus didokumentasikan dalam bentuk SQL migration script sehingga dapat direplikasi di instance Supabase manapun jika diperlukan |
| KNF-09.4 | Codebase Flutter yang sama dapat dikompilasi untuk platform iOS di masa mendatang tanpa perubahan logika bisnis; hanya diperlukan konfigurasi platform dan signing certificate iOS |

---

### Ringkasan Kebutuhan Non-Fungsional

```
KNF-01  Performa          → 14 KNF
KNF-02  Keamanan          → 19 KNF
KNF-03  Ketersediaan      →  8 KNF
KNF-04  Usability         → 15 KNF
KNF-05  Kompatibilitas    →  6 KNF
KNF-06  Skalabilitas      →  4 KNF
KNF-07  Pemeliharaan      →  6 KNF
KNF-08  Lokalisasi        →  4 KNF
KNF-09  Portabilitas      →  4 KNF

────────────────────────────────────
Total                     → 80 KNF
```

---

### Matriks Prioritas Kebutuhan Non-Fungsional

| Kategori | Prioritas | Alasan |
|----------|-----------|--------|
| Keamanan (KNF-02) | Kritis | Menyangkut data pribadi santri dan orang tua; kegagalan keamanan dapat merusak kepercayaan sekolah |
| Ketersediaan (KNF-03) | Kritis | Sistem digunakan setiap hari kerja oleh pengampu; downtime langsung mengganggu operasional sekolah |
| Usability (KNF-04) | Kritis | Pengampu dan orang tua adalah pengguna nonteknis yang paling sering berinteraksi; usability buruk menyebabkan sistem tidak digunakan |
| Performa (KNF-01) | Tinggi | Pengampu menginput setoran dengan smartphone di sela-sela kegiatan; respons lambat menurunkan produktivitas |
| Kompatibilitas Android (KNF-05) | Tinggi | Pengguna menggunakan beragam perangkat Android; kompatibilitas buruk mengecualikan sebagian pengguna |
| Pemeliharaan (KNF-07) | Menengah | Penting untuk keberlanjutan sistem jangka panjang setelah diserahkan ke sekolah |
| Lokalisasi (KNF-08) | Menengah | Penting untuk adopsi; pengguna tidak terbiasa dengan antarmuka berbahasa Inggris |
| Portabilitas (KNF-09) | Menengah | Dibutuhkan saat migrasi ke akun resmi sekolah sebelum go-live dan saat distribusi APK ulang |
| Skalabilitas (KNF-06) | Rendah | MTs TQ Jamilurrahman adalah sekolah dengan skala terbatas; skalabilitas ekstrem tidak diperlukan dalam waktu dekat |

---

## 5. Batasan Desain dan Implementasi

---

### 5.1 Batasan Teknologi

Batasan teknologi mendefinisikan pilihan-pilihan teknis yang telah ditetapkan dan tidak dapat diubah selama proses pengembangan SI-Tahfiz. Seluruh keputusan desain dan implementasi harus selaras dengan batasan-batasan berikut.

#### 5.1.1 Tumpukan Teknologi yang Ditetapkan

| Lapisan | Teknologi | Keterangan |
|---------|-----------|------------|
| Framework Mobile | Flutter (versi stabil terkini) | Cross-platform; target utama Android |
| Bahasa Pemrograman | Dart | Seluruh file `.dart`; tidak menggunakan bahasa lain |
| State Management | Riverpod | Satu-satunya library state management yang digunakan |
| Database Lokal | Drift (SQLite) | Untuk penyimpanan data offline sementara sebelum sinkronisasi |
| Backend | Supabase | PostgreSQL + Auth + Storage + Realtime |
| Push Notification | Firebase Cloud Messaging (FCM) | Untuk notifikasi ke perangkat Android |
| Token Storage | flutter_secure_storage | Penyimpanan token autentikasi terenkripsi |
| Grafik | fl_chart | Tidak menggunakan library chart lain |
| Share File | share_plus | Untuk share sheet native Android |
| Akses Storage | path_provider | Untuk akses direktori penyimpanan perangkat |
| File Picker | file_picker | Untuk memilih file dari penyimpanan perangkat |
| Lokalisasi Tanggal | intl | Untuk format tanggal dan angka Bahasa Indonesia |
| Distribusi | APK langsung | Tidak menggunakan Google Play Store |

#### 5.1.2 Batasan Framework Flutter

| Kode | Batasan |
|------|---------|
| BTD-01.1 | Seluruh model data harus didefinisikan sebagai Dart class terpusat di direktori `lib/models/` dengan method `fromJson()` dan `toJson()`; tidak boleh ada duplikasi definisi model di file widget manapun |
| BTD-01.2 | Struktur direktori menggunakan pendekatan berbasis fitur: `lib/features/[role]/` untuk widget dan logika per role; `lib/widgets/shared/` untuk widget yang digunakan lintas role |
| BTD-01.3 | Tidak boleh menggunakan SharedPreferences untuk menyimpan data sensitif seperti token autentikasi atau data pengguna; seluruh data sensitif dikelola melalui flutter_secure_storage |
| BTD-01.4 | Riverpod adalah satu-satunya library state management yang digunakan; tidak boleh menggunakan Provider, GetX, BLoC, atau setState untuk state global lintas widget |
| BTD-01.5 | Widget yang digunakan di lebih dari satu layar harus ditempatkan di `lib/widgets/shared/`; widget spesifik satu role ditempatkan di `lib/features/[role]/widgets/` |
| BTD-01.6 | File utilitas non-UI (kalkulasi hari kerja, rekap semester, nilai akhir) harus ditempatkan di `lib/utils/` dan tidak boleh mengandung import Flutter widget apapun |
| BTD-01.7 | Enum Dart wajib digunakan untuk mendefinisikan menu aktif dan navigasi antar layar; tidak boleh menggunakan String generik untuk navigasi |

#### 5.1.3 Batasan Backend Supabase

| Kode | Batasan |
|------|---------|
| BTD-01.8 | Seluruh interaksi dengan database harus melalui package `supabase_flutter`; tidak boleh menggunakan koneksi PostgreSQL langsung |
| BTD-01.9 | Seluruh tabel harus mengaktifkan Row Level Security (RLS); tidak boleh ada tabel yang beroperasi tanpa RLS di environment production |
| BTD-01.10 | Seluruh primary key tabel harus menggunakan UUID dengan `uuid_generate_v4()` sebagai default; tidak boleh menggunakan auto-increment integer |
| BTD-01.11 | File tanda tangan digital harus disimpan di Supabase Storage bucket `signatures`; kolom `parent_signature` di tabel `setoran` menyimpan URL (bukan base64) |
| BTD-01.12 | Fitur real-time in-app menggunakan Supabase Realtime channel; setiap channel harus di-unsubscribe saat widget dispose untuk mencegah memory leak |
| BTD-01.13 | Konfigurasi sistem yang dapat berubah tanpa build ulang APK harus disimpan di tabel `system_config` dengan struktur key-value; tidak boleh di-hardcode di dalam kode aplikasi |

#### 5.1.4 Batasan Push Notification FCM

| Kode | Batasan |
|------|---------|
| BTD-01.14 | FCM device token harus disimpan ke tabel `fcm_tokens` di Supabase setiap kali pengguna login atau token diperbarui oleh FCM; token yang lama harus diperbarui, bukan ditambah sebagai record baru |
| BTD-01.15 | Seluruh pengiriman push notification ke FCM harus dilakukan melalui Supabase Edge Function; tidak boleh ada pemanggilan FCM API langsung dari kode Flutter |
| BTD-01.16 | FCM Server Key hanya boleh tersimpan di environment variable Supabase Edge Function; tidak boleh disertakan dalam kode aplikasi Flutter yang dapat di-decompile |

---

### 5.2 Batasan Struktur Database

Batasan ini mendefinisikan aturan-aturan yang harus diikuti dalam perancangan dan modifikasi skema database SI-Tahfiz.

#### 5.2.1 Struktur Tabel

| Kode | Batasan |
|------|---------|
| BTD-02.1 | Database terdiri dari 26 tabel yang telah ditetapkan (termasuk tabel `fcm_tokens` yang ditambahkan untuk kebutuhan push notification); penambahan tabel baru memerlukan pembaruan pada dokumen ini, migrasi SQL, dan pembaruan RLS policy yang sesuai |
| BTD-02.2 | Seluruh tabel transaksi (setoran, absensi, tikrar, ujian_juz, ujian_semester, nilai_akhlaq, hafalan_juz) harus memiliki kolom `created_at TIMESTAMPTZ DEFAULT NOW()` |
| BTD-02.3 | Tabel yang datanya dapat diubah (santri, halaqah, catatan_stagnasi, nilai_akhlaq, ujian_semester) harus memiliki kolom `updated_at TIMESTAMPTZ DEFAULT NOW()` |
| BTD-02.4 | Relasi antar tabel menggunakan foreign key yang eksplisit; tidak boleh menyimpan UUID referensi tanpa foreign key constraint |
| BTD-02.5 | Constraint UNIQUE harus diterapkan pada kombinasi kolom yang secara bisnis hanya boleh ada satu record: `(santri_id, tanggal)` di `absensi`, `(santri_id, semester)` di `nilai_akhlaq` dan `ujian_semester` |

#### 5.2.2 Tabel fcm_tokens

| Kode | Batasan |
|------|---------|
| BTD-02.6 | Tabel `fcm_tokens` harus memiliki kolom minimal: `id (UUID PK)`, `user_id (UUID FK ke users)`, `token (TEXT)`, `updated_at (TIMESTAMPTZ)`; constraint UNIQUE harus diterapkan pada `user_id` karena satu pengguna hanya memiliki satu token aktif |
| BTD-02.7 | RLS pada tabel `fcm_tokens` harus membatasi akses: pengguna hanya dapat membaca dan memperbarui token miliknya sendiri; Supabase Edge Function menggunakan service role untuk membaca semua token saat mengirim push notification |

#### 5.2.3 Tabel system_config

| Kode | Batasan |
|------|---------|
| BTD-02.8 | Tabel `system_config` menggunakan struktur key-value dengan kolom `key (TEXT PRIMARY KEY)` dan `value (TEXT)`; semua konfigurasi operasional tersimpan di sini |
| BTD-02.9 | Keys yang wajib tersedia di tabel `system_config` dan tidak boleh dihapus adalah: `maintenance_mode`, `akhlaq_input_aktif`, `akhlaq_semester_aktif`, `semester_ganjil_mulai`, `semester_ganjil_selesai`, `semester_genap_mulai`, `semester_genap_selesai` |
| BTD-02.10 | Nilai pada `system_config` selalu bertipe TEXT; konversi ke boolean atau tipe lain dilakukan di sisi aplikasi Flutter (contoh: `value == 'true'` untuk boolean) |

#### 5.2.4 Tabel audit_log

| Kode | Batasan |
|------|---------|
| BTD-02.11 | Tabel `audit_log` bersifat append-only; tidak boleh ada operasi UPDATE atau DELETE pada tabel ini melalui mekanisme apapun di dalam aplikasi |
| BTD-02.12 | Kolom `nama_user` di `audit_log` harus diisi secara eksplisit dengan nama lengkap pengguna (bukan UUID) pada saat pencatatan, untuk kemudahan pembacaan tanpa perlu join |
| BTD-02.13 | Kolom `detail` di `audit_log` bertipe JSONB dan harus berisi informasi yang cukup untuk memahami perubahan yang terjadi tanpa perlu melihat tabel lain; minimal berisi nilai lama dan nilai baru untuk operasi perubahan data |
| BTD-02.14 | Helper function `logAudit()` di `lib/utils/audit_log.dart` adalah satu-satunya mekanisme yang diizinkan untuk insert ke tabel `audit_log`; tidak boleh ada insert langsung ke tabel ini di luar helper tersebut |

---

### 5.3 Batasan Keamanan Implementasi

| Kode | Batasan |
|------|---------|
| BTD-03.1 | Token autentikasi (access token, refresh token, dan user role) wajib disimpan menggunakan `flutter_secure_storage` yang memanfaatkan Keystore Android; tidak boleh disimpan di SharedPreferences, memori tidak terenkripsi, atau file lokal tanpa enkripsi |
| BTD-03.2 | Token autentikasi dan data role pengguna yang tersimpan di `flutter_secure_storage` wajib dihapus seluruhnya saat pengguna logout; tidak boleh ada sisa data sesi setelah logout |
| BTD-03.3 | Route guard di Flutter adalah satu-satunya mekanisme penegak RBAC di level navigasi; tidak boleh ada logika RBAC yang tersebar di masing-masing widget layar |
| BTD-03.4 | File route guard Flutter tidak boleh dimodifikasi tanpa review menyeluruh karena perubahan yang salah dapat memberikan akses tidak sah ke seluruh layar atau mengunci semua pengguna |
| BTD-03.5 | Supabase Anon Key boleh ada dalam kode Flutter karena sifatnya memang public-facing; yang tidak boleh ada dalam kode Flutter adalah Supabase Service Role Key dan FCM Server Key karena keduanya memberikan akses penuh ke database dan layanan notifikasi |
| BTD-03.6 | Rate limiting login diimplementasikan di sisi Flutter menggunakan penyimpanan lokal; mekanisme ini bersifat client-side dan tidak dapat diandalkan sebagai satu-satunya lapisan keamanan, namun cukup untuk mencegah brute-force dari pengguna awam |

---

### 5.4 Batasan Antarmuka Pengguna

#### 5.4.1 Konsistensi Visual

| Kode | Batasan |
|------|---------|
| BTD-04.1 | Setiap layar role memiliki warna aksen utama yang berbeda dan harus konsisten di seluruh widget layar tersebut; warna didefinisikan sebagai konstanta Dart: Pengampu (emerald/hijau), Koordinator (indigo/nila), Kepala Sekolah (amber/kuning), Staff TU (violet/ungu), Orang Tua (teal/hijau-biru) |
| BTD-04.2 | Semua card utama menggunakan shared widget `AppCard` yang didefinisikan di `lib/widgets/shared/app_card.dart` dengan `BorderRadius.circular(16)`, `BoxDecoration` warna sesuai ThemeData, dan BoxShadow ringan; tidak boleh mendefinisikan dekorasi card secara inline di masing-masing widget |
| BTD-04.3 | Ukuran teks menggunakan nilai fontSize Flutter yang konsisten: konten menggunakan 12.0, label dan badge menggunakan 10.0, judul panel menggunakan 14.0 dengan FontWeight.bold |
| BTD-04.4 | Seluruh tombol aksi utama (simpan, submit) menggunakan `ElevatedButton` dengan warna aksen role masing-masing; tombol sekunder (batal, kembali) menggunakan `OutlinedButton` atau `TextButton` dengan warna netral |

#### 5.4.2 Navigasi

| Kode | Batasan |
|------|---------|
| BTD-04.5 | Navigasi utama seluruh layar menggunakan `NavigationBar` atau `BottomNavigationBar` Flutter; tidak ada sidebar karena aplikasi hanya menarget perangkat mobile |
| BTD-04.6 | Menu yang memiliki lebih dari 4 item harus menggunakan drawer tambahan yang dapat dibuka dari bottom navigation, bukan menjejalkan semua item di navigation bar |
| BTD-04.7 | Enum Dart wajib digunakan untuk mendefinisikan state menu aktif; tidak boleh menggunakan String generik untuk menghindari typo nama menu |

#### 5.4.3 Penanganan Status dan Loading

| Kode | Batasan |
|------|---------|
| BTD-04.8 | Setiap widget yang melakukan query Supabase harus memiliki state loading dan menampilkan indikator yang sesuai (CircularProgressIndicator atau Shimmer); tidak boleh ada query yang berjalan tanpa feedback visual kepada pengguna |
| BTD-04.9 | Error dari Supabase harus ditangkap dengan try-catch; tidak boleh ada unhandled exception yang menyebabkan aplikasi crash; error harus ditampilkan kepada pengguna dalam bahasa Indonesia yang mudah dipahami |
| BTD-04.10 | Seluruh layar wajib dibungkus dengan widget `SafeArea` untuk memastikan konten tidak tertutup oleh notch, status bar, atau navigation bar perangkat Android |
| BTD-04.11 | Widget yang menampilkan daftar panjang (setoran, santri, audit log) wajib menggunakan `ListView.builder` atau mekanisme lazy-loading lain; tidak boleh merender seluruh list sekaligus untuk menjaga performa |

---

### 5.5 Batasan Logika Bisnis Akademik

Batasan ini mendefinisikan aturan-aturan bisnis domain tahfiz yang bersifat tetap dan tidak dapat dikonfigurasi melalui antarmuka sistem kecuali disebutkan sebaliknya.

#### 5.5.1 Setoran Harian

| Kode | Batasan |
|------|---------|
| BTD-05.1 | Dalam satu hari, satu santri hanya boleh memiliki maksimal satu record setoran per tipe (satu Sabak, satu Sabki, satu Manzil); input kedua pada hari yang sama harus mengupdate record yang sudah ada, bukan membuat record baru |
| BTD-05.2 | Penentuan status setoran lulus atau mengulang dilakukan sepenuhnya oleh pengampu; sistem tidak menentukan status secara otomatis berdasarkan jumlah kesalahan |
| BTD-05.3 | Tipe setoran harus salah satu dari: `'sabak'`, `'sabki'`, `'manzil'`; tidak boleh ada tipe lain yang dimasukkan ke tabel `setoran` |
| BTD-05.4 | Setoran yang ditandai sebagai bagian dari Pekan Murajaah harus memiliki prefix `[Pekan Muraja'ah]` pada kolom `catatan` untuk membedakannya dari setoran harian biasa dalam kalkulasi rekap |

#### 5.5.2 Tikrar

| Kode | Batasan |
|------|---------|
| BTD-05.5 | Alur status Tikrar bersifat linear dan satu arah: `wajib_sekolah` → `selesai_sekolah` → `wajib_rumah` → `selesai_rumah`; tidak boleh ada perpindahan status yang melompat atau mundur |
| BTD-05.6 | Insert Tikrar baru harus memeriksa keberadaan Tikrar dengan kombinasi `(santri_id, tanggal, surah)` yang sama terlebih dahulu; jika sudah ada, insert baru tidak dilakukan untuk mencegah duplikasi kewajiban Tikrar |

#### 5.5.3 Ujian Kenaikan Juz (UKJ)

| Kode | Batasan |
|------|---------|
| BTD-05.7 | Pengampu adalah satu-satunya pihak yang berwenang menginput hasil UKJ termasuk menentukan status lulus atau mengulang dan memberikan grade 1-5 |
| BTD-05.8 | UKJ yang sudah diapprove koordinator tidak dapat diubah oleh pengampu; hanya koordinator yang dapat mengubah keputusannya |
| BTD-05.9 | UKJ yang ditolak koordinator dapat diinput ulang oleh pengampu dengan data yang diperbaiki; record UKJ yang ditolak tetap tersimpan sebagai riwayat |

#### 5.5.4 Ujian Akhir Semester (UAS)

| Kode | Batasan |
|------|---------|
| BTD-05.10 | Jumlah juz yang dapat dipilih untuk UAS maksimal 3 juz per santri; jika hafalan ≤ 3 juz maka seluruh hafalan wajib diujikan tanpa pengecualian |
| BTD-05.11 | Nilai akhir UAS dihitung sebagai rata-rata aritmatika dari seluruh nilai per juz; pembulatan menggunakan 1 angka desimal dengan formula Dart: `(nilai * 10).round() / 10` |
| BTD-05.12 | Nilai akhir UAS hanya dapat dihitung jika seluruh juz yang dipilih sudah memiliki nilai; jika ada satu saja yang kosong maka `nilai_akhir = null` |

#### 5.5.5 Absensi

| Kode | Batasan |
|------|---------|
| BTD-05.13 | Model absensi exception-based harus dipertahankan: tidak adanya record absensi untuk santri pada hari tertentu berarti santri tersebut hadir; tidak boleh ada insert record dengan status `'hadir'` |
| BTD-05.14 | Notifikasi Alpha hanya dikirim untuk status `'alpha'`; status `'sakit'` dan `'izin'` tidak memicu notifikasi apapun ke orang tua |
| BTD-05.15 | Jika orang tua tidak memiliki akun (`parentUserId = null`), penyimpanan absensi tetap berhasil tanpa error; kegagalan insert notifikasi tidak boleh membatalkan penyimpanan absensi |

#### 5.5.6 Formula Nilai Akhir Semester

| Kode | Batasan |
|------|---------|
| BTD-05.16 | Formula nilai akhir semester bersifat tetap dengan komposisi: Setoran Harian 40% + UAS 40% + Akhlaq 10% + Kehadiran 10%; tidak dapat dikonfigurasi melalui antarmuka |
| BTD-05.17 | Dalam komponen Setoran Harian (40%), bobot masing-masing tipe setoran adalah: Sabak 30% + Sabki 30% + Manzil 40% dari total bobot setoran |
| BTD-05.18 | Nilai setiap komponen dihitung menggunakan basis jumlah baris: `(total_baris_aktual / total_baris_target) × 100`; seluruh komponen di-cap pada nilai maksimal 100 |
| BTD-05.19 | Komponen nilai kehadiran hanya memperhitungkan hari Alpha sebagai pengurang; ketidakhadiran karena Sakit atau Izin tidak mengurangi nilai kehadiran |
| BTD-05.20 | Target baris Manzil semester mengecualikan hari-hari yang masuk dalam periode Syahrul Quran karena tidak ada setoran Manzil selama periode tersebut |
| BTD-05.21 | Nilai akhir semester dibulatkan menggunakan 1 angka desimal; tidak menggunakan pembulatan ke bilangan bulat |

#### 5.5.7 Rekap Semester

| Kode | Batasan |
|------|---------|
| BTD-05.22 | Hari kerja didefinisikan sebagai Senin sampai Jumat (DateTime.weekday >= 1 && <= 5 dalam Dart) dikurangi tanggal-tanggal yang terdaftar di tabel `hari_libur`; Sabtu dan Ahad selalu dianggap bukan hari kerja |
| BTD-05.23 | Pengelompokan pekan dalam rekap menggunakan Senin sebagai awal pekan dan Jumat sebagai akhir pekan; label pekan menampilkan range tanggal aktual (contoh: "2-6 Jun") |
| BTD-05.24 | Pekan yang sebagian atau seluruhnya masuk dalam periode Syahrul Quran diberi label dengan prefix ★; kolom Manzil pada pekan tersebut menampilkan tanda "-" |
| BTD-05.25 | Fungsi `generatePekanList()`, `hitungRekapSantri()`, dan `getTargetHarian()` di `lib/utils/rekap_utils.dart` adalah sumber kebenaran tunggal untuk kalkulasi rekap; tidak boleh ada logika kalkulasi rekap yang diduplikasi di widget manapun |

---

### 5.6 Batasan Pengembangan dan Deployment

#### 5.6.1 Repositori dan Versi Kontrol

| Kode | Batasan |
|------|---------|
| BTD-06.1 | Kode sumber harus disimpan di repositori GitHub; build APK production dilakukan secara lokal menggunakan `flutter build apk --release` dengan signing key yang sudah disiapkan; tidak menggunakan platform hosting atau CI/CD otomatis |
| BTD-06.2 | File konfigurasi yang mengandung nilai sensitif (Supabase URL, Supabase Anon Key, konfigurasi Firebase) harus selalu terdaftar dalam `.gitignore`; tidak boleh ada commit yang mengandung nilai konfigurasi sensitif |
| BTD-06.3 | Setiap milestone fitur yang selesai dan sudah diuji harus di-commit ke GitHub sebelum memulai fitur berikutnya; tidak boleh menggabungkan perubahan besar tanpa testing terlebih dahulu |

#### 5.6.2 Pengujian Sebelum Commit

| Kode | Batasan |
|------|---------|
| BTD-06.4 | Setiap fitur baru harus diuji secara manual menggunakan `flutter run` di emulator Android atau device fisik sebelum di-commit; pengujian minimum mencakup: happy path, edge case null/kosong, dan pengecekan data di Supabase Dashboard |
| BTD-06.5 | Seluruh kode harus bebas dari warning dan error analisis sebelum commit; jalankan `flutter analyze` dan pastikan tidak ada issue yang diabaikan |
| BTD-06.6 | Fitur yang mempengaruhi route guard atau autentikasi Flutter harus diuji dengan semua role pengguna sebelum di-commit untuk memastikan tidak ada role yang terkunci atau salah diarahkan |

---

### 5.7 Batasan Migrasi dan Go-Live

| Kode | Batasan |
|------|---------|
| BTD-07.1 | Migrasi dari Supabase akun pengembang ke Supabase akun resmi sekolah harus dilakukan sebelum input data nyata pertama kali; migrasi setelah ada data nyata jauh lebih kompleks |
| BTD-07.2 | Seluruh data dummy yang digunakan selama pengembangan harus dihapus sepenuhnya sebelum sistem diserahkan ke sekolah dan digunakan dengan data nyata |
| BTD-07.3 | Skema database (DDL) harus didokumentasikan sebagai SQL script yang dapat dijalankan ulang di instance Supabase baru jika diperlukan |
| BTD-07.4 | Sebelum go-live, Staff TU harus mengisi konfigurasi wajib berikut melalui panel Sistem: tanggal Semester Ganjil (mulai dan selesai) serta tanggal Semester Genap (mulai dan selesai); fitur Rekap Semester dan Nilai Akhir tidak akan berfungsi tanpa konfigurasi ini |
| BTD-07.5 | Password default akun wali (nomor HP) harus dikomunikasikan ke masing-masing orang tua secara langsung oleh Staff TU atau koordinator; sistem tidak mengirim notifikasi otomatis tentang kredensial login |
| BTD-07.6 | File APK release harus di-build menggunakan `flutter build apk --release` dengan signing key yang sudah disiapkan sebelum distribusi; APK debug tidak boleh didistribusikan kepada pengguna nyata |
| BTD-07.7 | APK yang akan didistribusikan harus diuji terlebih dahulu di minimal 2 tipe perangkat Android berbeda (low-end dan mid-range) untuk memastikan kompatibilitas sebelum diserahkan ke sekolah |

---

### Ringkasan Batasan Desain dan Implementasi

```
BTD-01  Batasan Teknologi              → 16 batasan
BTD-02  Batasan Struktur Database      → 14 batasan
BTD-03  Batasan Keamanan Implementasi  →  6 batasan
BTD-04  Batasan Antarmuka Pengguna     → 11 batasan
BTD-05  Batasan Logika Bisnis          → 25 batasan
BTD-06  Batasan Pengembangan           →  6 batasan
BTD-07  Batasan Migrasi dan Go-Live    →  7 batasan

─────────────────────────────────────────────────────
Total                                  → 85 batasan
```

---

### Hierarki Kekritisan Batasan

```
TIDAK BOLEH DILANGGAR (mengakibatkan kerusakan sistem atau celah keamanan):
BTD-02.11 (audit_log append-only)
BTD-03.1  (flutter_secure_storage wajib untuk token)
BTD-03.2  (token wajib dihapus saat logout)
BTD-03.3  (route guard sebagai satu-satunya RBAC)
BTD-03.4  (route guard tidak boleh diubah sembarangan)
BTD-03.5  (FCM Server Key dan Service Role Key tidak boleh di kode Flutter)
BTD-01.9  (RLS harus aktif di semua tabel)
BTD-01.11 (tanda tangan sebagai URL, bukan base64)
BTD-01.15 (pengiriman push notification hanya melalui Edge Function)
BTD-01.16 (FCM Server Key hanya di Edge Function)

HARUS DIIKUTI (mengakibatkan inkonsistensi data atau bug):
BTD-01.1  (Dart model class terpusat di lib/models/)
BTD-05.1  (anti-duplikasi setoran)
BTD-05.13 (model absensi exception-based)
BTD-05.22 (definisi hari kerja)
BTD-06.2  (tidak commit file konfigurasi sensitif)
BTD-07.1  (migrasi sebelum data nyata)

SANGAT DIANJURKAN (mengakibatkan hutang teknis jika diabaikan):
BTD-01.6  (utilitas kalkulasi di lib/utils/ tanpa Flutter import)
BTD-01.4  (Riverpod sebagai satu-satunya state management)
BTD-04.1  (konsistensi warna per role)
BTD-04.10 (SafeArea di semua layar)
BTD-06.5  (flutter analyze bersih sebelum commit)
```

---

*Batasan-batasan dalam bab ini bersifat mengikat selama masa pengembangan SI-Tahfiz. Setiap pengecualian terhadap batasan yang ada harus didokumentasikan beserta alasannya dan disetujui oleh tim pengembang sebelum diimplementasikan.*

---

Dokumen SKPL SI-Tahfiz Mobile kini sudah lengkap dengan 5 bab:

```
Bab 1  Pendahuluan
Bab 2  Deskripsi Umum Sistem
Bab 3  Kebutuhan Fungsional (49 KU, ~303 KF, 5 aktor)
Bab 4  Kebutuhan Non-Fungsional (80 KNF, 9 kategori)
Bab 5  Batasan Desain & Implementasi (85 batasan, 7 kategori)
```
```

---

Selesai semua! Bab 3 aktor Koordinator dan Kepala Sekolah belum aku buatkan versi barunya — mau dilanjut sekarang atau ada yang perlu direvisi dulu dari yang sudah ada?