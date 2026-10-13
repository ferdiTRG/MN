USE task1;

CREATE VIEW v_stok_produk AS
SELECT id, nama, kategori, harga, stok, created_at
FROM PRODUK;

CREATE VIEW v_customer_public AS
SELECT id, nama, email, no_hp, created_at
FROM CUSTOMER;

CREATE VIEW v_customer_auth AS
SELECT id, email, password
FROM CUSTOMER;

CREATE VIEW v_admin_public AS
SELECT id, username, created_at
FROM ADMIN;

CREATE VIEW v_admin_auth AS
SELECT id, username, password
FROM ADMIN;

CREATE VIEW v_detail_pesanan AS
SELECT
    p.id AS pesanan_id,
    p.customer_id,
    p.status,
    p.total_bayar,
    p.created_at,
    dp.produk_id,
    pr.nama AS produk_nama,
    dp.jumlah,
    dp.subtotal
FROM PESANAN p
JOIN DETAIL_PESANAN dp ON dp.pesanan_id = p.id
JOIN PRODUK pr ON pr.id = dp.produk_id;

CREATE VIEW v_laporan_revenue AS
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS bulan,
    COUNT(*) AS total_pesanan,
    COALESCE(SUM(total_bayar), 0) AS total_pendapatan
FROM PESANAN
WHERE status = 'lunas'
GROUP BY DATE_FORMAT(created_at, '%Y-%m');

CREATE VIEW v_produk_terlaris AS
SELECT
    pr.id AS produk_id,
    pr.nama,
    SUM(dp.jumlah) AS total_terjual,
    SUM(dp.subtotal) AS total_nilai
FROM DETAIL_PESANAN dp
JOIN PRODUK pr ON pr.id = dp.produk_id
JOIN PESANAN p ON p.id = dp.pesanan_id
WHERE p.status = 'lunas'
GROUP BY pr.id, pr.nama;
