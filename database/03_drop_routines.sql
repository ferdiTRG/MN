USE task1;

-- Jalankan sebelum membuat ulang routine. Tidak menghapus tabel atau data.
DROP TRIGGER IF EXISTS trg_potong_stok_log;

DROP PROCEDURE IF EXISTS sp_registrasi_customer;
DROP PROCEDURE IF EXISTS sp_login_customer;
DROP PROCEDURE IF EXISTS sp_login_admin;
DROP PROCEDURE IF EXISTS sp_get_customer_profile;
DROP PROCEDURE IF EXISTS sp_get_admin_profile;
DROP PROCEDURE IF EXISTS sp_get_products;
DROP PROCEDURE IF EXISTS sp_get_product_by_id;
DROP PROCEDURE IF EXISTS sp_create_product;
DROP PROCEDURE IF EXISTS sp_update_product;
DROP PROCEDURE IF EXISTS sp_delete_product;
DROP PROCEDURE IF EXISTS sp_buat_pesanan;
DROP PROCEDURE IF EXISTS sp_get_orders_customer;
DROP PROCEDURE IF EXISTS sp_get_orders_admin;
DROP PROCEDURE IF EXISTS sp_get_order_detail_customer;
DROP PROCEDURE IF EXISTS sp_get_order_detail_admin;
DROP PROCEDURE IF EXISTS sp_bayar_pesanan;
DROP PROCEDURE IF EXISTS sp_update_stok;
DROP PROCEDURE IF EXISTS sp_get_revenue_report;
DROP PROCEDURE IF EXISTS sp_get_top_selling_report;

DROP FUNCTION IF EXISTS fn_cek_stok_cukup;

DROP VIEW IF EXISTS v_detail_pesanan;
DROP VIEW IF EXISTS v_customer_public;
DROP VIEW IF EXISTS v_customer_auth;
DROP VIEW IF EXISTS v_admin_public;
DROP VIEW IF EXISTS v_admin_auth;
DROP VIEW IF EXISTS v_stok_produk;
DROP VIEW IF EXISTS v_laporan_revenue;
DROP VIEW IF EXISTS v_produk_terlaris;
