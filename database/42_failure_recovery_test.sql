USE task1;

-- Uji validasi jumlah: pesanan dengan jumlah negatif ditolak tanpa menyimpan order.
CALL sp_buat_pesanan(1, 2, -10);

-- Uji stok negatif: perubahan yang membuat stok di bawah nol harus ditolak dan di-rollback.
CALL sp_update_stok(1, 2, -99999, 'Uji rollback stok');

-- Verifikasi stok dan log tidak berubah karena percobaan gagal.
SELECT * FROM v_stok_produk WHERE id = 2;
SELECT * FROM STOK_LOG ORDER BY id DESC;
