USE task1;

-- 1. Buat pesanan demo. Catat pesanan_id pada hasil procedure.
CALL sp_buat_pesanan(1, 2, 2);

-- 2. Sebelum dibayar, stok produk 2 tidak berubah akibat pembuatan pesanan.
SELECT * FROM v_stok_produk WHERE id = 2;

-- 3. Ganti angka 123 dengan pesanan_id hasil langkah 1.
-- Customer ID 1 hanya boleh membayar pesanan miliknya.
CALL sp_bayar_pesanan(123, 1);

-- 4. Periksa stok dan log setelah pembayaran.
SELECT * FROM v_stok_produk WHERE id = 2;
SELECT * FROM STOK_LOG ORDER BY id DESC;

-- 5. Pembayaran kedua kali harus ditolak, tanpa pemotongan stok tambahan.
CALL sp_bayar_pesanan(123, 1);
