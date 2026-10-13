USE task1;

-- Jalankan tiap CALL sebagai satu statement. Procedure mengembalikan result set sendiri.
CALL sp_get_products();
CALL sp_get_product_by_id(2);
CALL sp_get_customer_profile(1);
CALL sp_get_admin_profile(1);
CALL sp_get_revenue_report();
CALL sp_get_top_selling_report();
CALL sp_login_customer('g2cxz@email.com', 'su25435123');
CALL sp_login_admin('busari', 'hash_password_admin');
