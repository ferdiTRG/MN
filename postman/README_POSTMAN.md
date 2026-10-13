# Menggunakan Postman Collection

## Import
1. Buka Postman → **Import**.
2. Import `Toko-API.postman_collection.json` dan `Toko-API-Local.postman_environment.json`.
3. Pilih environment **Toko API Local** dari dropdown environment.
4. Pastikan server Bun/Express berjalan di `http://localhost:3000`. Ubah `baseUrl` di environment jika port berbeda.

## Akun demo default
- Customer: `g2cxz@email.com` / `su25435123`
- Admin: `busari` / `hash_password_admin`

Akun demo ini sesuai data seed lokal dalam `database/02_seed.sql`. Password hanya untuk pengujian lokal.

## Urutan pengujian yang disarankan
1. `01 - Auth` → `Login customer`, lalu `Login admin`. Login menyimpan `customerToken` dan `adminToken` secara otomatis.
2. `02 - Products` → `Daftar produk` dan `Detail produk`. Untuk menambah/mengubah/menghapus produk, jalankan sebagai admin. `Tambah produk` menyimpan `createdProductId` untuk update/delete.
3. `03 - Orders` → `Buat pesanan (Customer)`, kemudian daftar/detail, lalu bayar. Request create order menyimpan `orderId` otomatis. Jangan jalankan pembayaran customer dan admin untuk order yang sama; satu pembayaran sukses akan membuat order lunas dan pembayaran kedua ditolak.
4. `04 - Reports (Admin)` → jalankan kedua report dengan `adminToken`.

## Catatan register
`Register customer` membuat email unik dengan timestamp. Jika berhasil, collection menyimpan akun baru ke `customerEmail`/`customerPassword`, sehingga request `Login customer` sesudahnya akan menggunakan customer yang baru terdaftar.

## Endpoint dalam collection
- `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `POST /api/v1/auth/admin/login`, `GET /api/v1/auth/profile`
- `GET /api/v1/products`, `GET /api/v1/products/:id`, `POST /api/v1/products`, `PUT /api/v1/products/:id`, `DELETE /api/v1/products/:id`, `PATCH /api/v1/products/:id/stock`
- `POST /api/v1/orders`, `GET /api/v1/orders`, `GET /api/v1/orders/:id`, `POST /api/v1/orders/:id/pay`
- `GET /api/v1/reports/revenue`, `GET /api/v1/reports/top-selling`

Collection ini berisi endpoint fitur, tanpa route root atau health check. Collection ini mengikuti route yang terdefinisi di backend saat dibuat; ini belum berarti endpoint sudah berhasil diuji ke server lokalmu.
