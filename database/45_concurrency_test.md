# Pengujian concurrency di DBeaver (dua sesi)

1. Login ke DBeaver dengan akun administrator dan buka dua SQL Editor yang memakai dua koneksi/sesi berbeda ke database `task1`.
2. Buat satu pesanan yang valid memakai `CALL sp_buat_pesanan(1, 2, 1);` lalu catat `pesanan_id` dari hasil procedure.
3. Pada sesi A dan sesi B, siapkan `CALL sp_bayar_pesanan(ID_PESANAN, 1);` dengan ID yang sama.
4. Eksekusi keduanya hampir bersamaan.
5. Hasil yang diharapkan: satu pembayaran sukses; pembayaran lainnya memberi pesan sudah lunas. `STOK_LOG` hanya memiliki satu catatan penjualan untuk pesanan itu dan stok hanya berkurang sekali.

`FOR UPDATE` pada procedure pembayaran mengunci pesanan dan produk. Uji ini memerlukan dua koneksi database independen, bukan dua tab yang berbagi satu koneksi.
