USE task1;

-- Kompatibel dengan MariaDB/MySQL yang belum mendukung JSON_ARRAYAGG.
-- Query ini hanya membaca VIEW. Setiap baris hasil adalah satu JSON object.
-- API Express membungkus kumpulan baris menjadi properti data berbentuk array JSON.
SELECT JSON_OBJECT(
    'success', TRUE,
    'data', JSON_OBJECT(
        'id', id,
        'nama', nama,
        'kategori', kategori,
        'harga', harga,
        'stok', stok
    )
) AS response_json
FROM v_stok_produk
ORDER BY id;

-- Contoh JSON untuk setiap item detail dari sebuah pesanan.
SELECT JSON_OBJECT(
    'success', TRUE,
    'data', JSON_OBJECT(
        'pesanan_id', pesanan_id,
        'customer_id', customer_id,
        'status', status,
        'total_bayar', total_bayar,
        'produk_id', produk_id,
        'produk_nama', produk_nama,
        'jumlah', jumlah,
        'subtotal', subtotal
    )
) AS response_json
FROM v_detail_pesanan
WHERE pesanan_id = 1;
