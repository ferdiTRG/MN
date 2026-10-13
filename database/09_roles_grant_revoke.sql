USE task1;

CREATE ROLE 'role_customer';
CREATE ROLE 'role_admin';

-- Customer membaca produk melalui procedure/view dan membuat/membayar pesanan melalui procedure.
GRANT SELECT ON task1.v_stok_produk TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_get_products TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_get_product_by_id TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_get_customer_profile TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_registrasi_customer TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_login_customer TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_buat_pesanan TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_get_orders_customer TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_get_order_detail_customer TO 'role_customer';
GRANT EXECUTE ON PROCEDURE task1.sp_bayar_pesanan TO 'role_customer';

-- Contoh REVOKE: beri hak tulis sementara, lalu cabut lagi.
GRANT INSERT, UPDATE, DELETE ON task1.PRODUK TO 'role_customer';
REVOKE INSERT, UPDATE, DELETE ON task1.PRODUK FROM 'role_customer';

-- Role admin.
GRANT SELECT ON task1.v_stok_produk TO 'role_admin';
GRANT SELECT ON task1.v_laporan_revenue TO 'role_admin';
GRANT SELECT ON task1.v_produk_terlaris TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_products TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_product_by_id TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_admin_profile TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_login_admin TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_create_product TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_update_product TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_delete_product TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_update_stok TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_orders_admin TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_order_detail_admin TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_revenue_report TO 'role_admin';
GRANT EXECUTE ON PROCEDURE task1.sp_get_top_selling_report TO 'role_admin';
