
```sql
-- ============================================================
-- SI-TAHFIZ: COMPLETE DATABASE SETUP
-- Schema + RLS Policies + Helper Functions
-- Jalankan seluruhnya sekaligus di Supabase SQL Editor
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM TYPES
-- ============================================================

DO $$ BEGIN
  CREATE TYPE role_enum AS ENUM ('tu', 'koordinator', 'pengampu', 'kepsek');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE grade_enum AS ENUM ('tahsin', 'takmil', 'tahfiz');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tipe_setoran_enum AS ENUM ('sabak', 'sabki', 'manzil');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_setoran_enum AS ENUM ('lulus', 'mengulang');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_tikrar_enum AS ENUM ('wajib_sekolah', 'selesai_sekolah', 'wajib_rumah', 'selesai_rumah');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_absensi_enum AS ENUM ('alpha', 'sakit', 'izin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_approval_enum AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_ukj_santri_enum AS ENUM ('lulus', 'mengulang');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE semester_enum AS ENUM ('ganjil', 'genap');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- AUTH & PENGGUNA
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nama_lengkap TEXT NOT NULL,
  role        role_enum NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orang_tua (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nama_lengkap TEXT NOT NULL,
  nomor_hp    TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DATA MASTER
-- ============================================================

CREATE TABLE IF NOT EXISTS halaqah (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama_halaqah TEXT NOT NULL,
  grade        grade_enum NOT NULL,
  pengampu_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS santri (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama_lengkap TEXT NOT NULL,
  kelas        TEXT NOT NULL,
  grade        grade_enum NOT NULL,
  halaqah_id   UUID NOT NULL REFERENCES halaqah(id) ON DELETE RESTRICT,
  orang_tua_id UUID REFERENCES orang_tua(id) ON DELETE SET NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- KONFIGURASI
-- ============================================================

CREATE TABLE IF NOT EXISTS konfigurasi (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bobot_setoran           INTEGER NOT NULL DEFAULT 40,
  bobot_uas               INTEGER NOT NULL DEFAULT 40,
  bobot_akhlaq            INTEGER NOT NULL DEFAULT 10,
  bobot_kehadiran         INTEGER NOT NULL DEFAULT 10,
  tanggal_mulai_ganjil    DATE,
  tanggal_selesai_ganjil  DATE,
  tanggal_mulai_genap     DATE,
  tanggal_selesai_genap   DATE,
  fitur_akhlaq_aktif      BOOLEAN NOT NULL DEFAULT TRUE,
  maintenance_mode        BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT bobot_total_100 CHECK (
    bobot_setoran + bobot_uas + bobot_akhlaq + bobot_kehadiran = 100
  )
);

INSERT INTO konfigurasi (bobot_setoran, bobot_uas, bobot_akhlaq, bobot_kehadiran, fitur_akhlaq_aktif, maintenance_mode)
SELECT 40, 40, 10, 10, TRUE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM konfigurasi);

CREATE TABLE IF NOT EXISTS hari_libur (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tanggal     DATE NOT NULL UNIQUE,
  keterangan  TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS target_grade (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  grade       grade_enum NOT NULL UNIQUE,
  target_min  INTEGER NOT NULL,
  target_max  INTEGER,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT target_min_positive CHECK (target_min > 0),
  CONSTRAINT target_max_gte_min CHECK (target_max IS NULL OR target_max >= target_min)
);

INSERT INTO target_grade (grade, target_min, target_max)
SELECT * FROM (VALUES
  ('tahsin'::grade_enum, 7, 10),
  ('takmil'::grade_enum, 15, NULL),
  ('tahfiz'::grade_enum, 30, NULL)
) AS v(grade, target_min, target_max)
WHERE NOT EXISTS (SELECT 1 FROM target_grade WHERE target_grade.grade = v.grade);

-- ============================================================
-- SETORAN
-- ============================================================

CREATE TABLE IF NOT EXISTS setoran (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id        UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  tipe             tipe_setoran_enum NOT NULL,
  tanggal          DATE NOT NULL,
  jumlah_baris     INTEGER NOT NULL,
  halaman_awal     INTEGER NOT NULL,
  halaman_akhir    INTEGER NOT NULL,
  jumlah_kesalahan INTEGER,
  status           status_setoran_enum NOT NULL,
  input_oleh       UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_setoran_per_hari UNIQUE (santri_id, tipe, tanggal),
  CONSTRAINT jumlah_baris_positive CHECK (jumlah_baris > 0),
  CONSTRAINT halaman_valid CHECK (halaman_akhir >= halaman_awal)
);

-- ============================================================
-- TIKRAR
-- ============================================================

CREATE TABLE IF NOT EXISTS tikrar (
  id                       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id                UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  tanggal                  DATE NOT NULL,
  surah                    TEXT NOT NULL,
  status                   status_tikrar_enum NOT NULL DEFAULT 'wajib_sekolah',
  diselesaikan_pengampu_at TIMESTAMPTZ,
  dialihkan_rumah_at       TIMESTAMPTZ,
  diselesaikan_ortu_at     TIMESTAMPTZ,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_tikrar UNIQUE (santri_id, tanggal, surah)
);

-- ============================================================
-- ABSENSI
-- ============================================================

CREATE TABLE IF NOT EXISTS absensi (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id   UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  tanggal     DATE NOT NULL,
  status      status_absensi_enum NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_absensi_per_hari UNIQUE (santri_id, tanggal)
);

-- ============================================================
-- UJIAN
-- ============================================================

CREATE TABLE IF NOT EXISTS ukj (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id         UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  pengampu_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  nomor_juz         INTEGER NOT NULL,
  nilai             INTEGER NOT NULL,
  status_santri     status_ukj_santri_enum NOT NULL,
  status_approval   status_approval_enum NOT NULL DEFAULT 'pending',
  alasan_penolakan  TEXT,
  approved_by       UUID REFERENCES profiles(id) ON DELETE RESTRICT,
  approved_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT nilai_ukj_valid CHECK (nilai >= 0 AND nilai <= 100),
  CONSTRAINT nomor_juz_valid CHECK (nomor_juz >= 1 AND nomor_juz <= 30)
);

CREATE TABLE IF NOT EXISTS uas (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id    UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  pengampu_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  semester     semester_enum NOT NULL,
  tahun_ajaran TEXT NOT NULL,
  nilai_akhir  NUMERIC(5,1),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_uas_per_semester UNIQUE (santri_id, semester, tahun_ajaran)
);

CREATE TABLE IF NOT EXISTS uas_detail (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uas_id      UUID NOT NULL REFERENCES uas(id) ON DELETE CASCADE,
  nomor_juz   INTEGER NOT NULL,
  nilai       INTEGER NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_juz_per_uas UNIQUE (uas_id, nomor_juz),
  CONSTRAINT nilai_uas_valid CHECK (nilai >= 0 AND nilai <= 100),
  CONSTRAINT nomor_juz_uas_valid CHECK (nomor_juz >= 1 AND nomor_juz <= 30)
);

-- ============================================================
-- AKHLAQ
-- ============================================================

CREATE TABLE IF NOT EXISTS akhlaq (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id    UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  pengampu_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  semester     semester_enum NOT NULL,
  tahun_ajaran TEXT NOT NULL,
  nilai        INTEGER NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_akhlaq_per_semester UNIQUE (santri_id, semester, tahun_ajaran),
  CONSTRAINT nilai_akhlaq_valid CHECK (nilai >= 0 AND nilai <= 100)
);

-- ============================================================
-- PERIODE KHUSUS
-- ============================================================

CREATE TABLE IF NOT EXISTS syahrul_quran (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tanggal_mulai   DATE NOT NULL,
  tanggal_selesai DATE NOT NULL,
  dibuat_oleh     UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT tanggal_syahrul_valid CHECK (tanggal_selesai >= tanggal_mulai)
);

CREATE TABLE IF NOT EXISTS pekan_murajaah (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tanggal_mulai   DATE NOT NULL,
  tanggal_selesai DATE NOT NULL,
  dibuat_oleh     UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT tanggal_murajaah_valid CHECK (tanggal_selesai >= tanggal_mulai)
);

CREATE TABLE IF NOT EXISTS target_murajaah (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pekan_murajaah_id     UUID NOT NULL REFERENCES pekan_murajaah(id) ON DELETE CASCADE,
  halaqah_id            UUID NOT NULL REFERENCES halaqah(id) ON DELETE CASCADE,
  target_baris_per_hari INTEGER NOT NULL,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_target_per_halaqah UNIQUE (pekan_murajaah_id, halaqah_id),
  CONSTRAINT target_baris_positive CHECK (target_baris_per_hari > 0)
);

-- ============================================================
-- KOMUNIKASI
-- ============================================================

CREATE TABLE IF NOT EXISTS percakapan (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  santri_id    UUID NOT NULL REFERENCES santri(id) ON DELETE CASCADE,
  pengampu_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  ortu_id      UUID NOT NULL REFERENCES orang_tua(id) ON DELETE RESTRICT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_percakapan UNIQUE (santri_id, pengampu_id, ortu_id)
);

CREATE TABLE IF NOT EXISTS pesan (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  percakapan_id   UUID NOT NULL REFERENCES percakapan(id) ON DELETE CASCADE,
  pengirim_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  isi             TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PENGUMUMAN & BERITA
-- ============================================================

CREATE TABLE IF NOT EXISTS pengumuman (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  judul        TEXT NOT NULL,
  isi          TEXT NOT NULL,
  target_role  TEXT[] NOT NULL,
  dibuat_oleh  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pengumuman_read (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pengumuman_id   UUID NOT NULL REFERENCES pengumuman(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_pengumuman_read UNIQUE (pengumuman_id, user_id)
);

CREATE TABLE IF NOT EXISTS berita_login (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  judul        TEXT NOT NULL,
  isi          TEXT NOT NULL,
  dibuat_oleh  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- AUDIT TRAIL
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_trail (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  aktivitas   TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PUSH SUBSCRIPTIONS (PWA)
-- ============================================================

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint    TEXT NOT NULL,
  p256dh      TEXT NOT NULL,
  auth_key    TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_push_subscription UNIQUE (user_id, endpoint)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_setoran_santri_id ON setoran(santri_id);
CREATE INDEX IF NOT EXISTS idx_setoran_tanggal ON setoran(tanggal);
CREATE INDEX IF NOT EXISTS idx_setoran_santri_tipe_tanggal ON setoran(santri_id, tipe, tanggal);
CREATE INDEX IF NOT EXISTS idx_tikrar_santri_id ON tikrar(santri_id);
CREATE INDEX IF NOT EXISTS idx_tikrar_status ON tikrar(status);
CREATE INDEX IF NOT EXISTS idx_absensi_santri_id ON absensi(santri_id);
CREATE INDEX IF NOT EXISTS idx_absensi_tanggal ON absensi(tanggal);
CREATE INDEX IF NOT EXISTS idx_ukj_status_approval ON ukj(status_approval);
CREATE INDEX IF NOT EXISTS idx_ukj_santri_id ON ukj(santri_id);
CREATE INDEX IF NOT EXISTS idx_uas_detail_uas_id ON uas_detail(uas_id);
CREATE INDEX IF NOT EXISTS idx_santri_halaqah_id ON santri(halaqah_id);
CREATE INDEX IF NOT EXISTS idx_santri_orang_tua_id ON santri(orang_tua_id);
CREATE INDEX IF NOT EXISTS idx_pesan_percakapan_id ON pesan(percakapan_id);
CREATE INDEX IF NOT EXISTS idx_pengumuman_read_user_id ON pengumuman_read(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_trail_created_at ON audit_trail(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_trail_user_id ON audit_trail(user_id);
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_user_id ON push_subscriptions(user_id);

-- ============================================================
-- ENABLE RLS
-- ============================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE orang_tua ENABLE ROW LEVEL SECURITY;
ALTER TABLE santri ENABLE ROW LEVEL SECURITY;
ALTER TABLE halaqah ENABLE ROW LEVEL SECURITY;
ALTER TABLE konfigurasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE hari_libur ENABLE ROW LEVEL SECURITY;
ALTER TABLE target_grade ENABLE ROW LEVEL SECURITY;
ALTER TABLE setoran ENABLE ROW LEVEL SECURITY;
ALTER TABLE tikrar ENABLE ROW LEVEL SECURITY;
ALTER TABLE absensi ENABLE ROW LEVEL SECURITY;
ALTER TABLE ukj ENABLE ROW LEVEL SECURITY;
ALTER TABLE uas ENABLE ROW LEVEL SECURITY;
ALTER TABLE uas_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE akhlaq ENABLE ROW LEVEL SECURITY;
ALTER TABLE syahrul_quran ENABLE ROW LEVEL SECURITY;
ALTER TABLE pekan_murajaah ENABLE ROW LEVEL SECURITY;
ALTER TABLE target_murajaah ENABLE ROW LEVEL SECURITY;
ALTER TABLE percakapan ENABLE ROW LEVEL SECURITY;
ALTER TABLE pesan ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengumuman ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengumuman_read ENABLE ROW LEVEL SECURITY;
ALTER TABLE berita_login ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION auth_user_role()
RETURNS text AS $$
DECLARE v_role text;
BEGIN
  SELECT role::text INTO v_role FROM profiles WHERE id = auth.uid();
  IF v_role IS NULL THEN
    IF EXISTS (SELECT 1 FROM orang_tua WHERE id = auth.uid()) THEN
      v_role := 'orang_tua';
    END IF;
  END IF;
  RETURN v_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_my_santri_ids()
RETURNS uuid[] AS $$
  SELECT ARRAY(
    SELECT s.id FROM santri s
    INNER JOIN halaqah h ON s.halaqah_id = h.id
    WHERE h.pengampu_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_my_anak_ids()
RETURNS uuid[] AS $$
  SELECT ARRAY(
    SELECT id FROM santri WHERE orang_tua_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION delete_old_audit_trail()
RETURNS void AS $$
BEGIN
  DELETE FROM audit_trail WHERE created_at < NOW() - INTERVAL '3 months';
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- DROP EXISTING POLICIES (avoid conflicts on re-run)
-- ============================================================

DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- ============================================================
-- RLS POLICIES: PROFILES
-- ============================================================

CREATE POLICY "profiles_select_authenticated" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update_own_or_tu" ON profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id OR auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: ORANG TUA
-- ============================================================

CREATE POLICY "orang_tua_select_own" ON orang_tua FOR SELECT TO authenticated
  USING (auth.uid() = id);
CREATE POLICY "orang_tua_select_internal" ON orang_tua FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'pengampu', 'kepsek'));
CREATE POLICY "orang_tua_update_own_or_tu" ON orang_tua FOR UPDATE TO authenticated
  USING (auth.uid() = id OR auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: HALAQAH
-- ============================================================

CREATE POLICY "halaqah_select_authenticated" ON halaqah FOR SELECT TO authenticated USING (true);
CREATE POLICY "halaqah_insert_tu" ON halaqah FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'tu');
CREATE POLICY "halaqah_update_tu" ON halaqah FOR UPDATE TO authenticated
  USING (auth_user_role() = 'tu');
CREATE POLICY "halaqah_delete_tu" ON halaqah FOR DELETE TO authenticated
  USING (auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: SANTRI
-- ============================================================

CREATE POLICY "santri_select_tu_koordinator_kepsek" ON santri FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "santri_select_pengampu" ON santri FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND id = ANY(get_my_santri_ids()));
CREATE POLICY "santri_select_ortu" ON santri FOR SELECT TO authenticated
  USING (orang_tua_id = auth.uid());
CREATE POLICY "santri_insert_tu" ON santri FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'tu');
CREATE POLICY "santri_update_tu_koordinator" ON santri FOR UPDATE TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator'));
CREATE POLICY "santri_delete_tu" ON santri FOR DELETE TO authenticated
  USING (auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: KONFIGURASI
-- ============================================================

CREATE POLICY "konfigurasi_select_all" ON konfigurasi FOR SELECT USING (true);
CREATE POLICY "konfigurasi_update_tu_koordinator" ON konfigurasi FOR UPDATE TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator'));

-- ============================================================
-- RLS POLICIES: HARI LIBUR
-- ============================================================

CREATE POLICY "hari_libur_select_authenticated" ON hari_libur FOR SELECT TO authenticated USING (true);
CREATE POLICY "hari_libur_insert_tu" ON hari_libur FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'tu');
CREATE POLICY "hari_libur_delete_tu" ON hari_libur FOR DELETE TO authenticated
  USING (auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: TARGET GRADE
-- ============================================================

CREATE POLICY "target_grade_select_authenticated" ON target_grade FOR SELECT TO authenticated USING (true);
CREATE POLICY "target_grade_update_koordinator" ON target_grade FOR UPDATE TO authenticated
  USING (auth_user_role() = 'koordinator');

-- ============================================================
-- RLS POLICIES: SETORAN
-- ============================================================

CREATE POLICY "setoran_select_tu_koordinator_kepsek" ON setoran FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "setoran_select_pengampu" ON setoran FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "setoran_select_ortu" ON setoran FOR SELECT TO authenticated
  USING (santri_id = ANY(get_my_anak_ids()));
CREATE POLICY "setoran_insert_pengampu_sabak_sabki" ON setoran FOR INSERT TO authenticated
  WITH CHECK (
    auth_user_role() = 'pengampu' AND tipe IN ('sabak', 'sabki')
    AND santri_id = ANY(get_my_santri_ids()) AND input_oleh = auth.uid()
  );
CREATE POLICY "setoran_insert_ortu_manzil" ON setoran FOR INSERT TO authenticated
  WITH CHECK (
    auth_user_role() = 'orang_tua' AND tipe = 'manzil'
    AND santri_id = ANY(get_my_anak_ids()) AND input_oleh = auth.uid()
  );
CREATE POLICY "setoran_update_pengampu" ON setoran FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND tipe IN ('sabak', 'sabki') AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "setoran_update_ortu_manzil" ON setoran FOR UPDATE TO authenticated
  USING (
    auth_user_role() = 'orang_tua' AND tipe = 'manzil'
    AND santri_id = ANY(get_my_anak_ids()) AND input_oleh = auth.uid()
  );

-- ============================================================
-- RLS POLICIES: TIKRAR
-- ============================================================

CREATE POLICY "tikrar_select_tu_koordinator_kepsek" ON tikrar FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "tikrar_select_pengampu" ON tikrar FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "tikrar_select_ortu" ON tikrar FOR SELECT TO authenticated
  USING (santri_id = ANY(get_my_anak_ids()));
CREATE POLICY "tikrar_insert_pengampu" ON tikrar FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "tikrar_update_pengampu" ON tikrar FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "tikrar_update_ortu" ON tikrar FOR UPDATE TO authenticated
  USING (auth_user_role() = 'orang_tua' AND santri_id = ANY(get_my_anak_ids()) AND status = 'wajib_rumah');

-- ============================================================
-- RLS POLICIES: ABSENSI
-- ============================================================

CREATE POLICY "absensi_select_tu_koordinator_kepsek" ON absensi FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "absensi_select_pengampu" ON absensi FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "absensi_select_ortu" ON absensi FOR SELECT TO authenticated
  USING (santri_id = ANY(get_my_anak_ids()));
CREATE POLICY "absensi_insert_pengampu" ON absensi FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "absensi_update_pengampu" ON absensi FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "absensi_delete_pengampu" ON absensi FOR DELETE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));

-- ============================================================
-- RLS POLICIES: UKJ
-- ============================================================

CREATE POLICY "ukj_select_tu_koordinator_kepsek" ON ukj FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "ukj_select_pengampu" ON ukj FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "ukj_select_ortu" ON ukj FOR SELECT TO authenticated
  USING (santri_id = ANY(get_my_anak_ids()));
CREATE POLICY "ukj_insert_pengampu" ON ukj FOR INSERT TO authenticated
  WITH CHECK (
    auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids())
    AND pengampu_id = auth.uid() AND status_approval = 'pending'
  );
CREATE POLICY "ukj_update_pengampu_pending" ON ukj FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()) AND status_approval = 'pending');
CREATE POLICY "ukj_update_koordinator" ON ukj FOR UPDATE TO authenticated
  USING (auth_user_role() = 'koordinator');

-- ============================================================
-- RLS POLICIES: UAS
-- ============================================================

CREATE POLICY "uas_select_tu_koordinator_kepsek" ON uas FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "uas_select_pengampu" ON uas FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "uas_select_ortu" ON uas FOR SELECT TO authenticated
  USING (santri_id = ANY(get_my_anak_ids()));
CREATE POLICY "uas_insert_pengampu" ON uas FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()) AND pengampu_id = auth.uid());
CREATE POLICY "uas_update_pengampu" ON uas FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));

-- ============================================================
-- RLS POLICIES: UAS DETAIL
-- ============================================================

CREATE POLICY "uas_detail_select_tu_koordinator_kepsek" ON uas_detail FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "uas_detail_select_pengampu" ON uas_detail FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND EXISTS (
    SELECT 1 FROM uas u WHERE u.id = uas_detail.uas_id AND u.santri_id = ANY(get_my_santri_ids())
  ));
CREATE POLICY "uas_detail_select_ortu" ON uas_detail FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM uas u WHERE u.id = uas_detail.uas_id AND u.santri_id = ANY(get_my_anak_ids())
  ));
CREATE POLICY "uas_detail_insert_pengampu" ON uas_detail FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND EXISTS (
    SELECT 1 FROM uas u WHERE u.id = uas_detail.uas_id AND u.santri_id = ANY(get_my_santri_ids())
  ));
CREATE POLICY "uas_detail_update_pengampu" ON uas_detail FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND EXISTS (
    SELECT 1 FROM uas u WHERE u.id = uas_detail.uas_id AND u.santri_id = ANY(get_my_santri_ids())
  ));

-- ============================================================
-- RLS POLICIES: AKHLAQ
-- ============================================================

CREATE POLICY "akhlaq_select_tu_koordinator_kepsek" ON akhlaq FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator', 'kepsek'));
CREATE POLICY "akhlaq_select_pengampu" ON akhlaq FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "akhlaq_insert_pengampu" ON akhlaq FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()) AND pengampu_id = auth.uid());
CREATE POLICY "akhlaq_update_pengampu" ON akhlaq FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND santri_id = ANY(get_my_santri_ids()));

-- ============================================================
-- RLS POLICIES: SYAHRUL QURAN
-- ============================================================

CREATE POLICY "syahrul_quran_select_authenticated" ON syahrul_quran FOR SELECT TO authenticated USING (true);
CREATE POLICY "syahrul_quran_insert_koordinator" ON syahrul_quran FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'koordinator');
CREATE POLICY "syahrul_quran_update_koordinator" ON syahrul_quran FOR UPDATE TO authenticated
  USING (auth_user_role() = 'koordinator');

-- ============================================================
-- RLS POLICIES: PEKAN MURAJAAH
-- ============================================================

CREATE POLICY "pekan_murajaah_select_authenticated" ON pekan_murajaah FOR SELECT TO authenticated USING (true);
CREATE POLICY "pekan_murajaah_insert_koordinator" ON pekan_murajaah FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'koordinator');
CREATE POLICY "pekan_murajaah_update_koordinator" ON pekan_murajaah FOR UPDATE TO authenticated
  USING (auth_user_role() = 'koordinator');

-- ============================================================
-- RLS POLICIES: TARGET MURAJAAH
-- ============================================================

CREATE POLICY "target_murajaah_select_authenticated" ON target_murajaah FOR SELECT TO authenticated USING (true);
CREATE POLICY "target_murajaah_insert_pengampu" ON target_murajaah FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND EXISTS (
    SELECT 1 FROM halaqah h WHERE h.id = target_murajaah.halaqah_id AND h.pengampu_id = auth.uid()
  ));
CREATE POLICY "target_murajaah_update_pengampu" ON target_murajaah FOR UPDATE TO authenticated
  USING (auth_user_role() = 'pengampu' AND EXISTS (
    SELECT 1 FROM halaqah h WHERE h.id = target_murajaah.halaqah_id AND h.pengampu_id = auth.uid()
  ));

-- ============================================================
-- RLS POLICIES: PERCAKAPAN
-- ============================================================

CREATE POLICY "percakapan_select_pengampu" ON percakapan FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND pengampu_id = auth.uid());
CREATE POLICY "percakapan_select_ortu" ON percakapan FOR SELECT TO authenticated
  USING (auth_user_role() = 'orang_tua' AND ortu_id = auth.uid());
CREATE POLICY "percakapan_insert_pengampu" ON percakapan FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'pengampu' AND pengampu_id = auth.uid() AND santri_id = ANY(get_my_santri_ids()));
CREATE POLICY "percakapan_insert_ortu" ON percakapan FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'orang_tua' AND ortu_id = auth.uid() AND santri_id = ANY(get_my_anak_ids()));

-- ============================================================
-- RLS POLICIES: PESAN
-- ============================================================

CREATE POLICY "pesan_select_pengampu" ON pesan FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM percakapan p WHERE p.id = pesan.percakapan_id AND p.pengampu_id = auth.uid()));
CREATE POLICY "pesan_select_ortu" ON pesan FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM percakapan p WHERE p.id = pesan.percakapan_id AND p.ortu_id = auth.uid()));
CREATE POLICY "pesan_insert_pengampu" ON pesan FOR INSERT TO authenticated
  WITH CHECK (pengirim_id = auth.uid() AND EXISTS (
    SELECT 1 FROM percakapan p WHERE p.id = pesan.percakapan_id AND p.pengampu_id = auth.uid()
  ));
CREATE POLICY "pesan_insert_ortu" ON pesan FOR INSERT TO authenticated
  WITH CHECK (pengirim_id = auth.uid() AND EXISTS (
    SELECT 1 FROM percakapan p WHERE p.id = pesan.percakapan_id AND p.ortu_id = auth.uid()
  ));

-- ============================================================
-- RLS POLICIES: PENGUMUMAN
-- ============================================================

CREATE POLICY "pengumuman_select_tu_koordinator" ON pengumuman FOR SELECT TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator'));
CREATE POLICY "pengumuman_select_pengampu" ON pengumuman FOR SELECT TO authenticated
  USING (auth_user_role() = 'pengampu' AND 'pengampu' = ANY(target_role));
CREATE POLICY "pengumuman_select_kepsek" ON pengumuman FOR SELECT TO authenticated
  USING (auth_user_role() = 'kepsek' AND 'kepsek' = ANY(target_role));
CREATE POLICY "pengumuman_select_ortu" ON pengumuman FOR SELECT TO authenticated
  USING (auth_user_role() = 'orang_tua' AND 'orang_tua' = ANY(target_role));
CREATE POLICY "pengumuman_insert_tu_koordinator" ON pengumuman FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() IN ('tu', 'koordinator'));
CREATE POLICY "pengumuman_delete_tu_koordinator" ON pengumuman FOR DELETE TO authenticated
  USING (auth_user_role() IN ('tu', 'koordinator'));

-- ============================================================
-- RLS POLICIES: PENGUMUMAN READ
-- ============================================================

CREATE POLICY "pengumuman_read_select_own" ON pengumuman_read FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY "pengumuman_read_insert_own" ON pengumuman_read FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- ============================================================
-- RLS POLICIES: BERITA LOGIN
-- ============================================================

CREATE POLICY "berita_login_select_all" ON berita_login FOR SELECT USING (true);
CREATE POLICY "berita_login_insert_tu" ON berita_login FOR INSERT TO authenticated
  WITH CHECK (auth_user_role() = 'tu');
CREATE POLICY "berita_login_update_tu" ON berita_login FOR UPDATE TO authenticated
  USING (auth_user_role() = 'tu');
CREATE POLICY "berita_login_delete_tu" ON berita_login FOR DELETE TO authenticated
  USING (auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: AUDIT TRAIL
-- ============================================================

CREATE POLICY "audit_trail_select_tu" ON audit_trail FOR SELECT TO authenticated
  USING (auth_user_role() = 'tu');
CREATE POLICY "audit_trail_insert_authenticated" ON audit_trail FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "audit_trail_delete_tu" ON audit_trail FOR DELETE TO authenticated
  USING (auth_user_role() = 'tu');

-- ============================================================
-- RLS POLICIES: PUSH SUBSCRIPTIONS
-- ============================================================

CREATE POLICY "push_subscriptions_own" ON push_subscriptions FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- VERIFIKASI
-- ============================================================

SELECT tablename, COUNT(*) as jumlah_policy
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;
```

