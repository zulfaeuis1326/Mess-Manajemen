-- ============================================================
-- Mess Ku — Skema Database Supabase
-- Jalankan file ini di Supabase SQL Editor (satu kali, urut dari atas)
-- ============================================================

-- ---------- ENUM ----------
create type user_role as enum ('super_admin', 'admin_mess', 'karyawan');
create type kamar_status as enum ('tersedia', 'terisi', 'perbaikan');
create type jadwal_jenis as enum ('housekeeping', 'laundry', 'fogging', 'lainnya');
create type laporan_status as enum ('baru', 'diproses', 'selesai');
create type pengumuman_level as enum ('global', 'mess');

-- ---------- MESS (gedung) ----------
create table mess (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  alamat text,
  pic_nama text,
  pic_telepon text,
  created_at timestamptz not null default now()
);

-- ---------- PROFIL USER (extends auth.users) ----------
create table profil (
  id uuid primary key references auth.users(id) on delete cascade,
  nama text not null,
  telepon text,
  role user_role not null default 'karyawan',
  mess_id uuid references mess(id),          -- mess yang jadi tanggung jawab admin_mess / tempat karyawan tinggal
  kamar_id uuid,                              -- diisi belakangan, referensi ke kamar (karyawan)
  created_at timestamptz not null default now()
);

-- ---------- KAMAR ----------
create table kamar (
  id uuid primary key default gen_random_uuid(),
  mess_id uuid not null references mess(id) on delete cascade,
  lantai int not null,
  nomor text not null,
  kapasitas int not null default 4,
  status kamar_status not null default 'tersedia',
  fasilitas text,
  created_at timestamptz not null default now(),
  unique (mess_id, nomor)
);

alter table profil
  add constraint profil_kamar_fk foreign key (kamar_id) references kamar(id);

-- ---------- CUTI / ABSEN MAKAN (My Kilo) ----------
create table cuti (
  id uuid primary key default gen_random_uuid(),
  karyawan_id uuid not null references profil(id) on delete cascade,
  tanggal_mulai date not null,
  tanggal_selesai date not null,
  keterangan text,
  created_at timestamptz not null default now()
);

-- ---------- JADWAL (housekeeping / laundry) ----------
create table jadwal (
  id uuid primary key default gen_random_uuid(),
  mess_id uuid not null references mess(id) on delete cascade,
  kamar_id uuid references kamar(id),
  jenis jadwal_jenis not null,
  tanggal date not null,
  jam time,
  catatan text,
  created_at timestamptz not null default now()
);

-- ---------- LAPORAN / KOMPLAIN ----------
create table laporan (
  id uuid primary key default gen_random_uuid(),
  karyawan_id uuid not null references profil(id) on delete cascade,
  mess_id uuid not null references mess(id) on delete cascade,
  judul text not null,
  deskripsi text,
  status laporan_status not null default 'baru',
  created_at timestamptz not null default now()
);

-- ---------- PENGUMUMAN ----------
create table pengumuman (
  id uuid primary key default gen_random_uuid(),
  judul text not null,
  isi text not null,
  level pengumuman_level not null default 'global',
  mess_id uuid references mess(id),   -- diisi kalau level = 'mess'
  dibuat_oleh uuid references profil(id),
  darurat boolean not null default false,
  created_at timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY (dasar — akan ditajamkan per fitur nanti)
-- ============================================================
alter table mess enable row level security;
alter table profil enable row level security;
alter table kamar enable row level security;
alter table cuti enable row level security;
alter table jadwal enable row level security;
alter table laporan enable row level security;
alter table pengumuman enable row level security;

-- Helper: ambil role & mess_id user yang sedang login
create or replace function auth_role() returns user_role as $$
  select role from profil where id = auth.uid();
$$ language sql stable;

create or replace function auth_mess_id() returns uuid as $$
  select mess_id from profil where id = auth.uid();
$$ language sql stable;

-- Semua user login boleh baca daftar mess (buat landing page publik & dropdown)
create policy "mess: publik boleh baca" on mess for select using (true);

-- Profil: user boleh baca profil sendiri; admin_mess boleh baca profil di mess-nya; super_admin baca semua
create policy "profil: baca sendiri" on profil for select using (
  id = auth.uid()
  or auth_role() = 'super_admin'
  or (auth_role() = 'admin_mess' and mess_id = auth_mess_id())
);

-- Kamar: siapa saja yang login boleh lihat (dipakai buat denah); admin_mess/super_admin boleh ubah
create policy "kamar: baca semua login" on kamar for select using (auth.uid() is not null);
create policy "kamar: admin ubah" on kamar for all using (
  auth_role() = 'super_admin' or (auth_role() = 'admin_mess' and mess_id = auth_mess_id())
);

-- Cuti: karyawan CRUD data sendiri; admin_mess baca cuti di mess-nya
create policy "cuti: milik sendiri" on cuti for all using (karyawan_id = auth.uid());
create policy "cuti: admin baca mess-nya" on cuti for select using (
  auth_role() = 'super_admin'
  or exists (
    select 1 from profil p where p.id = cuti.karyawan_id and p.mess_id = auth_mess_id()
  )
);

-- Jadwal: baca oleh semua yang login di mess terkait; ubah oleh admin_mess/super_admin
create policy "jadwal: baca login" on jadwal for select using (auth.uid() is not null);
create policy "jadwal: admin ubah" on jadwal for all using (
  auth_role() = 'super_admin' or (auth_role() = 'admin_mess' and mess_id = auth_mess_id())
);

-- Laporan: karyawan buat & baca laporan sendiri; admin_mess baca semua laporan mess-nya
create policy "laporan: milik sendiri" on laporan for all using (karyawan_id = auth.uid());
create policy "laporan: admin baca & ubah mess-nya" on laporan for select using (
  auth_role() = 'super_admin' or (auth_role() = 'admin_mess' and mess_id = auth_mess_id())
);
create policy "laporan: admin update status" on laporan for update using (
  auth_role() = 'super_admin' or (auth_role() = 'admin_mess' and mess_id = auth_mess_id())
);

-- Pengumuman: publik/semua login boleh baca; hanya admin yang boleh buat
create policy "pengumuman: baca semua" on pengumuman for select using (true);
create policy "pengumuman: admin buat" on pengumuman for insert with check (
  auth_role() in ('super_admin', 'admin_mess')
);
