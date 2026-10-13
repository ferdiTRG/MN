-- Jalankan menggunakan koneksi administrator DBeaver, bukan koneksi API.
-- User aplikasi ini bukan root dan hanya diberi EXECUTE untuk stored procedure.
CREATE USER 'Admin_op'@'127.0.0.1' IDENTIFIED BY 'nagabonar';
ALTER USER 'Admin_op'@'127.0.0.1' IDENTIFIED BY 'nagabonar';

GRANT EXECUTE ON PROCEDURE task1.sp_registrasi_customer TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_login_customer TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_login_admin TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_customer_profile TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_admin_profile TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_products TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_product_by_id TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_create_product TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_update_product TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_delete_product TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_buat_pesanan TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_orders_customer TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_orders_admin TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_order_detail_customer TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_order_detail_admin TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_bayar_pesanan TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_update_stok TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_revenue_report TO 'Admin_op'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE task1.sp_get_top_selling_report TO 'Admin_op'@'127.0.0.1';

-- Periksa hak akses: hasil tidak boleh menunjukkan ALL PRIVILEGES atau akses langsung ke tabel.
SHOW GRANTS FOR 'Admin_op'@'127.0.0.1';
