# Task1 Toko API — MySQL/MariaDB XAMPP + DBeaver + Node.js/Express (JavaScript)

## Target perubahan sesuai ketentuan

1. **Backend tidak berisi query SELECT/INSERT/UPDATE/DELETE langsung.** Semua akses database di folder `src/` menggunakan `CALL nama_procedure(...)`.
2. **Semua stored procedure memakai transaksi.** Saat berhasil: `COMMIT`; saat validasi bisnis gagal: `ROLLBACK`; saat SQL exception: `EXIT HANDLER` menjalankan `ROLLBACK` lalu `RESIGNAL`.
3. **Procedure untuk membaca data mengambilnya dari VIEW.** Contoh: `sp_get_products` membaca `v_stok_produk`, procedure pesanan membaca `v_detail_pesanan`, dan report membaca view laporan.
4. **Backend tidak menggunakan user root.** Buat user `Admin_op` lewat `database/10_create_api_user.sql`, lalu gunakan akun ini di `.env`. Kode backend juga menolak konfigurasi `DB_USER=root`.

> Catatan transaksi: `ROLLBACK` dan `COMMIT` bukan rangkaian yang dijalankan berurutan pada jalur yang sama. `COMMIT` dipakai untuk transaksi berhasil; `ROLLBACK` dipakai untuk membatalkan transaksi gagal.

## Instalasi

Yang diperlukan: XAMPP dengan MySQL/MariaDB aktif, DBeaver, Node.js (v18+), VS Code, dan Postman atau Thunder Client untuk pengujian API.

## Urutan SQL awal

Jalankan di DBeaver menggunakan koneksi administrator database:

1. `database/00_fresh_start.sql` **hanya untuk database baru**; file ini menghapus database `task1` lama.
2. `database/01_schema.sql`
3. `database/02_seed.sql`
4. `database/03_drop_routines.sql`
5. `database/04_function_cek_stok.sql`
6. `database/05_views.sql`
7. `database/06_stored_procedures.sql` — berisi seluruh 19 stored procedure dalam satu file.
8. `database/07_trigger_potong_stok_log.sql`
9. `database/08_indexes.sql`
10. `database/09_roles_grant_revoke.sql`
11. `database/10_create_api_user.sql`
12. `database/11_json_examples.sql`

File pengujian: `database/40_smoke_tests.sql`, `database/41_order_flow_test.sql`, `database/42_failure_recovery_test.sql`, `database/43_check_indexes.sql`, `database/44_check_roles_user.sql`, dan `database/45_concurrency_test.md`.

### Menjalankan stored procedure di DBeaver

Semua stored procedure ada di `06_stored_procedures.sql`, tetapi karena file SQL tidak menggunakan pemisah statement client khusus, **jangan langsung menjalankan seluruh file sebagai satu script** jika DBeaver memecahnya pada setiap titik koma. Pastikan koneksi aktif memakai schema `task1`, lalu pilih satu blok lengkap dari komentar `PROCEDURE: ...` sampai `END;` terkait dan tekan **Ctrl+Enter (Execute SQL Statement)**. Ulangi untuk setiap procedure. Jangan jalankan statement di dalam `BEGIN ... END` satu per satu.

### Jika database sudah ada dan datanya ingin dipertahankan

Jangan jalankan `00_fresh_start.sql`, `01_schema.sql`, atau `02_seed.sql` ulang. Buat backup terlebih dahulu, lalu jalankan `03_drop_routines.sql`, `04_function_cek_stok.sql`, `05_views.sql`, `06_stored_procedures.sql` (setiap procedure satu blok), dan `07_trigger_potong_stok_log.sql`. File `03_drop_routines.sql` menghapus routines, trigger, dan views; tidak menghapus tabel atau data. Setelah itu jalankan `43_check_indexes.sql`: jika index bernama `idx_pesanan_customer_created`, `idx_pesanan_status_created`, `idx_produk_kategori`, `idx_stok_log_waktu`, dan `idx_stok_log_admin_waktu` sudah ada, **jangan jalankan `08_indexes.sql` lagi** agar tidak error karena nama index duplikat. Terakhir jalankan `09_roles_grant_revoke.sql` dan `10_create_api_user.sql`.

## User database aplikasi

Jalankan `10_create_api_user.sql` menggunakan koneksi administrator DBeaver. User `Admin_op` hanya diberi privilege `EXECUTE` ke stored procedure, bukan akses langsung ke tabel.

Salin `.env.example` menjadi `.env`. Nilai `DB_PASSWORD` harus sama dengan password pada file SQL. Untuk lokal, ganti password contoh pada kedua tempat dengan password milikmu.

## Menjalankan backend

Dari folder root project di terminal VS Code:

```powershell
npm install
npm run check
npm run dev
```

- API: `http://localhost:3000`
Server hanya menampilkan alamat saat mulai berjalan. Tidak ada endpoint health check atau pemeriksaan koneksi database saat startup; koneksi database digunakan ketika endpoint fitur dipanggil.

## Endpoint API

### Auth
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/admin/login`
- `GET /api/v1/auth/profile` (Bearer token)

### Products
- `GET /api/v1/products`
- `GET /api/v1/products/:id`
- `POST /api/v1/products` (admin)
- `PUT /api/v1/products/:id` (admin)
- `DELETE /api/v1/products/:id` (admin)
- `PATCH /api/v1/products/:id/stock` (admin)

### Orders
- `POST /api/v1/orders` (customer)
- `GET /api/v1/orders` (customer/admin)
- `GET /api/v1/orders/:id` (customer/admin)
- `POST /api/v1/orders/:id/pay` (customer pemilik pesanan atau admin)

### Reports (admin)
- `GET /api/v1/reports/revenue`
- `GET /api/v1/reports/top-selling`

Semua endpoint mengembalikan JSON. `database/11_json_examples.sql` mencontohkan JSON per baris yang dibangun dari view agar kompatibel dengan MariaDB yang belum mendukung `JSON_ARRAYAGG`. API membungkus rowset hasil procedure menjadi response JSON dengan properti `success` dan `data`.

## Catatan penting

- Password pada tabel demo masih plaintext mengikuti skema awal yang kamu kirim. Ini hanya untuk tugas/lokal; aplikasi sungguhan harus memakai password hashing.
- Pembuatan pesanan saat ini mendukung satu produk per pesanan, selaras dengan procedure awal. Pembayaran menolak pesanan dengan lebih dari satu baris detail.
- Untuk uji transaksi, lihat `database/41_order_flow_test.sql` dan `database/42_failure_recovery_test.sql`.
- Untuk uji concurrency dua sesi, lihat `database/45_concurrency_test.md`.
