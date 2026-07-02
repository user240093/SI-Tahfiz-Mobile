---

## Color Palette

| Nama | HEX | Digunakan untuk |
|------|-----|-----------------|
| **Primary** | `#10B981` | Warna utama, tombol primary, ikon aktif, highlight |
| **Primary Dark** | `#059669` | Pressed state tombol primary, sidebar aktif |
| **Primary Light** | `#D1FAE5` | Background badge, highlight ringan |
| **Secondary** | `#6B7280` | Teks sekunder, ikon nonaktif, border |
| **Orange Accent** | `#F97316` | Ikon aksen tertentu, badge notifikasi |
| **Warning** | `#F59E0B` | Peringatan, status pending |
| **Success** | `#10B981` | Konfirmasi berhasil (sama dengan primary) |
| **Danger** | `#EF4444` | Hapus, error, status ditolak |
| **Background** | `#FFFFFF` | Background utama semua halaman |
| **Surface** | `#F9FAFB` | Background card, tabel, input |
| **Border** | `#E5E7EB` | Garis tepi card, input, tabel |
| **Text Primary** | `#111827` | Teks utama |
| **Text Secondary** | `#6B7280` | Teks pendukung, placeholder |
| **Text Disabled** | `#D1D5DB` | Teks nonaktif |

---

## Tipografi

**Font Family:** `Inter` — di Flutter menggunakan package `google_fonts` (`GoogleFonts.inter()`)

| Elemen | Ukuran | Weight | Keterangan |
|--------|--------|--------|------------|
| H1 | 30px | 700 | Judul halaman utama |
| H2 | 24px | 700 | Judul section |
| H3 | 20px | 600 | Sub-judul |
| H4 | 18px | 600 | Judul card |
| H5 | 16px | 600 | Label penting |
| H6 | 14px | 600 | Label kecil |
| Body | 14px | 400 | Teks umum |
| Body Small | 12px | 400 | Teks pendukung, caption |
| Label | 12px | 500 | Label form |

---

## Karakter Visual Per Role

### Pengampu & Orang Tua — Hangat & Friendly
- Sudut komponen: `BorderRadius.circular(16)` (border-radius 16px)
- Card shadow: lembut — `BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))`
- Spacing: longgar, padding lebih besar
- Tombol: rounded penuh — `StadiumBorder()` / `BorderRadius.circular(999)`
- Kesan: ramah, mudah disentuh di layar HP

### Koordinator & Kepala Sekolah — Bersih & Minimal
- Sudut komponen: `BorderRadius.circular(8)` (border-radius 8px)
- Card shadow: tipis — `BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: Offset(0, 1))`
- Spacing: sedang, whitespace banyak
- Tombol: `BorderRadius.circular(8)`
- Kesan: bersih, fokus ke data dan informasi

### Staff TU — Profesional & Structured
- Sudut komponen: `BorderRadius.circular(6)` (border-radius 6px)
- Card shadow: tidak ada shadow, pakai border tegas
- Spacing: rapat, dense untuk tabel dan form
- Tombol: `BorderRadius.circular(6)`
- Kesan: rapi, efisien, seperti panel admin

---

## Komponen UI

### Button

| Tipe | Background | Teks | Border | Pressed |
|------|------------|------|--------|---------|
| **Primary** | `#10B981` | `#FFFFFF` | — | `#059669` |
| **Secondary** | `#FFFFFF` | `#111827` | `#E5E7EB` | `#F9FAFB` |
| **Danger** | `#EF4444` | `#FFFFFF` | — | `#DC2626` |
| **Ghost** | Transparan | `#10B981` | — | `#D1FAE5` |
| **Disabled** | `#F3F4F6` | `#D1D5DB` | — | Tidak berubah |

- Ukuran padding: `12px 20px` untuk default, `8px 14px` untuk small
- Sudut mengikuti karakter role masing-masing
- Feedback tekan menggunakan efek ripple/opacity bawaan Flutter (`InkWell`/`Material`), bukan hover — karena perangkat sentuh tidak punya hover

---

### Input Form

- Background: `#F9FAFB`
- Border: `1px solid #E5E7EB`
- Border saat fokus (input aktif/keyboard muncul): `2px solid #10B981`
- Border saat error: `2px solid #EF4444`
- Sudut: `BorderRadius.circular(8)`
- Padding: `10px 14px`
- Font size: `14px`
- Placeholder warna: `#9CA3AF`

---

### Card

- Background: `#FFFFFF`
- Border: `1px solid #E5E7EB`
- Shadow per role:
  - Pengampu & Ortu: `box-shadow: 0 4px 12px rgba(0,0,0,0.08)`
  - Koordinator & Kepsek: `box-shadow: 0 1px 4px rgba(0,0,0,0.06)`
  - TU: tidak ada shadow, hanya border
- Padding: `16px`

---

### Tabel

- Header background: `#F3F4F6`
- Header teks: `#374151`, weight 600
- Row background: `#FFFFFF`
- Row pressed (efek tap): `#F9FAFB`
- Row garis pemisah: `1px solid #E5E7EB`
- Font size isi: `14px`
- Padding cell: `12px 16px`

---

### Badge & Status

| Status | Background | Teks |
|--------|------------|------|
| Lulus / Selesai | `#D1FAE5` | `#065F46` |
| Pending / Menunggu | `#FEF3C7` | `#92400E` |
| Ditolak / Error | `#FEE2E2` | `#991B1B` |
| Izin | `#DBEAFE` | `#1E40AF` |
| Sakit | `#F3E8FF` | `#6B21A8` |
| Alpha | `#FEE2E2` | `#991B1B` |

---

## State Management Visual

### Empty State
- Ikon ilustrasi ukuran `80px` warna `#D1D5DB`
- Teks utama: `"Belum ada data"` — font size 16px, weight 600, warna `#374151`
- Teks pendukung: penjelasan singkat — font size 14px, warna `#6B7280`
- Tombol aksi (jika relevan): Primary button di bawah teks

### Loading State
- Skeleton loader mengikuti bentuk konten yang sedang dimuat (misal menggunakan package `shimmer`)
- Warna skeleton: animasi `#F3F4F6` → `#E5E7EB` (pulse)
- Tidak menggunakan spinner di tengah halaman kecuali untuk aksi tombol

### Error State
- Background: `#FEF2F2`
- Border: `1px solid #FECACA`
- Ikon: `⚠` warna `#EF4444`
- Teks error: font size 14px, warna `#991B1B`
- Tombol "Coba Lagi" jika error bisa di-retry

### Success Toast
- Menggunakan `SnackBar` bawaan Flutter
- Warna: background `#ECFDF5`, teks `#065F46`, ikon centang `#10B981`
- Durasi: 3 detik lalu hilang otomatis

---