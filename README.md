# Mess Ku

Platform manajemen mess karyawan — Next.js + Supabase.

## Cara mulai

1. Buat project baru di https://supabase.com
2. Buka **SQL Editor** di dashboard Supabase, tempel isi `supabase/schema.sql`, jalankan
3. Salin `.env.local.example` jadi `.env.local`, isi dengan URL & anon key project Supabase kamu
4. Install dependency dan jalankan:

```bash
npm install
npm run dev
```

5. Buka `http://localhost:3000`

## Struktur folder

```
app/
  page.js              -> landing page publik
  login/page.js         -> halaman login (routing otomatis per role)
  dashboard/            -> nanti diisi 3 dashboard: super-admin, admin-mess, karyawan
lib/supabase/
  client.js              -> Supabase client untuk Client Component
  server.js               -> Supabase client untuk Server Component
supabase/
  schema.sql             -> semua tabel + Row Level Security
```

## Status tahapan

- [x] Skema database (`supabase/schema.sql`)
- [x] Setup project + koneksi Supabase
- [x] Halaman login dengan routing per role
- [ ] Landing page (banner, live statistic, info per mess)
- [ ] Dashboard Karyawan (profil kamar, jadwal, form cuti, form laporan)
- [ ] Dashboard Admin Mess (denah kamar, penghuni, jadwal, rekap katering)
- [ ] Dashboard Super Admin (role & akses, infrastruktur, overview global, broadcast)
- [ ] Notifikasi (toast, pop-up banner darurat)

Bahasa visual dashboard (gaya "denah blueprint": navy, sage, slate, amber, serif Fraunces + mono JetBrains) mengikuti prototipe yang sudah disetujui — dipakai konsisten di semua halaman berikutnya.
