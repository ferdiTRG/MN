USE task1;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_registrasi_customer
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_registrasi_customer(
    IN p_nama VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_no_hp VARCHAR(20),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_email_ada INT DEFAULT 0;
    DECLARE v_customer_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_nama IS NULL OR TRIM(p_nama) = '' THEN
        ROLLBACK;
        SELECT 0 AS success, NULL AS customer_id, 'Nama wajib diisi.' AS message;
    ELSEIF p_email IS NULL OR TRIM(p_email) = '' THEN
        ROLLBACK;
        SELECT 0 AS success, NULL AS customer_id, 'Email wajib diisi.' AS message;
    ELSEIF p_password IS NULL OR p_password = '' THEN
        ROLLBACK;
        SELECT 0 AS success, NULL AS customer_id, 'Password wajib diisi.' AS message;
    ELSE
        SELECT COUNT(*) INTO v_email_ada FROM CUSTOMER WHERE email = p_email;

        IF v_email_ada > 0 THEN
            ROLLBACK;
            SELECT 0 AS success, NULL AS customer_id, 'Email sudah terdaftar, gunakan email lain.' AS message;
        ELSE
            INSERT INTO CUSTOMER (nama, email, no_hp, password)
            VALUES (TRIM(p_nama), TRIM(p_email), p_no_hp, p_password);
            SET v_customer_id = LAST_INSERT_ID();
            COMMIT;
            SELECT 1 AS success, v_customer_id AS customer_id,
                   CONCAT('Registrasi berhasil, id customer: ', v_customer_id) AS message;
        END IF;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_login_customer
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_login_customer(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_customer_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT MAX(id) INTO v_customer_id
      FROM v_customer_auth
     WHERE email = p_email AND password = p_password;
    COMMIT;

    SELECT IF(v_customer_id IS NULL, 0, 1) AS success,
           v_customer_id AS customer_id,
           IF(v_customer_id IS NULL, 'Email atau password salah.',
              CONCAT('Login berhasil, selamat datang customer id ', v_customer_id)) AS message;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_login_admin
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_login_admin(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_admin_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT MAX(id) INTO v_admin_id
      FROM v_admin_auth
     WHERE username = p_username AND password = p_password;
    COMMIT;

    SELECT IF(v_admin_id IS NULL, 0, 1) AS success,
           v_admin_id AS admin_id,
           IF(v_admin_id IS NULL, 'Username atau password salah.',
              CONCAT('Login berhasil, selamat datang admin id ', v_admin_id)) AS message;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_customer_profile
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_customer_profile(IN p_customer_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT id, nama, email, no_hp, created_at
      FROM v_customer_public
     WHERE id = p_customer_id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_admin_profile
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_admin_profile(IN p_admin_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT id, username, created_at
      FROM v_admin_public
     WHERE id = p_admin_id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_products
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_products()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT id, nama, kategori, harga, stok, created_at
      FROM v_stok_produk
     ORDER BY id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_product_by_id
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_product_by_id(IN p_produk_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT id, nama, kategori, harga, stok, created_at
      FROM v_stok_produk
     WHERE id = p_produk_id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_create_product
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_create_product(
    IN p_nama VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(10,2),
    IN p_stok INT
)
BEGIN
    DECLARE v_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    IF p_nama IS NULL OR TRIM(p_nama) = '' OR p_harga IS NULL OR p_harga < 0 OR p_stok IS NULL OR p_stok < 0 THEN
        ROLLBACK;
        SELECT 0 AS success, NULL AS id, 'Nama wajib diisi, harga dan stok tidak boleh negatif.' AS message;
    ELSE
        INSERT INTO PRODUK (nama, kategori, harga, stok)
        VALUES (TRIM(p_nama), p_kategori, p_harga, p_stok);
        SET v_id = LAST_INSERT_ID();
        COMMIT;
        SELECT 1 AS success, v_id AS id, 'Produk berhasil dibuat.' AS message;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_update_product
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_update_product(
    IN p_produk_id INT,
    IN p_nama VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(10,2)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT COUNT(*) INTO v_exists FROM PRODUK WHERE id = p_produk_id;

    IF v_exists = 0 THEN
        ROLLBACK;
        SELECT 0 AS success, 'Produk tidak ditemukan.' AS message;
    ELSEIF p_nama IS NULL OR TRIM(p_nama) = '' OR p_harga IS NULL OR p_harga < 0 THEN
        ROLLBACK;
        SELECT 0 AS success, 'Nama wajib diisi dan harga tidak boleh negatif.' AS message;
    ELSE
        UPDATE PRODUK
           SET nama = TRIM(p_nama), kategori = p_kategori, harga = p_harga
         WHERE id = p_produk_id;
        COMMIT;
        SELECT 1 AS success, 'Produk berhasil diperbarui.' AS message;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_delete_product
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_delete_product(IN p_produk_id INT)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT COUNT(*) INTO v_exists FROM PRODUK WHERE id = p_produk_id;
    IF v_exists = 0 THEN
        ROLLBACK;
        SELECT 0 AS success, 'Produk tidak ditemukan.' AS message;
    ELSE
        DELETE FROM PRODUK WHERE id = p_produk_id;
        COMMIT;
        SELECT 1 AS success, 'Produk berhasil dihapus.' AS message;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_buat_pesanan
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_buat_pesanan(
    IN p_customer_id INT,
    IN p_produk_id INT,
    IN p_jumlah INT
)
BEGIN
    DECLARE v_customer_ada INT DEFAULT 0;
    DECLARE v_produk_ada INT DEFAULT 0;
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_harga DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_pesanan_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_jumlah IS NULL OR p_jumlah <= 0 THEN
        ROLLBACK;
        SELECT 0 AS success, NULL AS pesanan_id, NULL AS total_bayar, 'Jumlah produk harus lebih dari 0.' AS message;
    ELSE
        SELECT COUNT(*) INTO v_customer_ada FROM CUSTOMER WHERE id = p_customer_id;
        SELECT COUNT(*) INTO v_produk_ada FROM PRODUK WHERE id = p_produk_id;

        IF v_customer_ada = 0 THEN
            ROLLBACK;
            SELECT 0 AS success, NULL AS pesanan_id, NULL AS total_bayar, 'Customer tidak ditemukan.' AS message;
        ELSEIF v_produk_ada = 0 THEN
            ROLLBACK;
            SELECT 0 AS success, NULL AS pesanan_id, NULL AS total_bayar, 'Produk tidak ditemukan.' AS message;
        ELSE
            SELECT harga, stok INTO v_harga, v_stok
              FROM PRODUK
             WHERE id = p_produk_id
             FOR UPDATE;

            IF v_stok < p_jumlah OR NOT fn_cek_stok_cukup(p_produk_id, p_jumlah) THEN
                ROLLBACK;
                SELECT 0 AS success, NULL AS pesanan_id, NULL AS total_bayar, 'Stok tidak cukup untuk produk ini.' AS message;
            ELSE
                SET v_total = v_harga * p_jumlah;
                INSERT INTO PESANAN (customer_id, status, total_bayar, created_at)
                VALUES (p_customer_id, 'pending', v_total, NOW());
                SET v_pesanan_id = LAST_INSERT_ID();

                INSERT INTO DETAIL_PESANAN (pesanan_id, produk_id, jumlah, subtotal)
                VALUES (v_pesanan_id, p_produk_id, p_jumlah, v_total);

                COMMIT;
                SELECT 1 AS success, v_pesanan_id AS pesanan_id, v_total AS total_bayar,
                       CONCAT('Pesanan berhasil dibuat dengan id ', v_pesanan_id, ', total Rp ', v_total) AS message;
            END IF;
        END IF;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_orders_customer
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_orders_customer(IN p_customer_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT pesanan_id, customer_id, status, total_bayar, created_at,
           produk_id, produk_nama, jumlah, subtotal
      FROM v_detail_pesanan
     WHERE customer_id = p_customer_id
     ORDER BY pesanan_id DESC;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_orders_admin
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_orders_admin()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT pesanan_id, customer_id, status, total_bayar, created_at,
           produk_id, produk_nama, jumlah, subtotal
      FROM v_detail_pesanan
     ORDER BY pesanan_id DESC;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_order_detail_customer
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_order_detail_customer(
    IN p_pesanan_id INT,
    IN p_customer_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT pesanan_id, customer_id, status, total_bayar, created_at,
           produk_id, produk_nama, jumlah, subtotal
      FROM v_detail_pesanan
     WHERE pesanan_id = p_pesanan_id AND customer_id = p_customer_id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_order_detail_admin
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_order_detail_admin(IN p_pesanan_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT pesanan_id, customer_id, status, total_bayar, created_at,
           produk_id, produk_nama, jumlah, subtotal
      FROM v_detail_pesanan
     WHERE pesanan_id = p_pesanan_id;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_bayar_pesanan
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_bayar_pesanan(
    IN p_pesanan_id INT,
    IN p_customer_id INT
)
BEGIN
    DECLARE v_order_count INT DEFAULT 0;
    DECLARE v_customer_id INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_detail_count INT DEFAULT 0;
    DECLARE v_jumlah INT DEFAULT 0;
    DECLARE v_stok INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT COUNT(*) INTO v_order_count FROM PESANAN WHERE id = p_pesanan_id;

    IF v_order_count = 0 THEN
        ROLLBACK;
        SELECT 0 AS success, 'Pesanan tidak ditemukan.' AS message;
    ELSE
        SELECT customer_id, status INTO v_customer_id, v_status
          FROM PESANAN
         WHERE id = p_pesanan_id
         FOR UPDATE;

        IF p_customer_id IS NOT NULL AND v_customer_id <> p_customer_id THEN
            ROLLBACK;
            SELECT 0 AS success, 'Pesanan bukan milik customer ini.' AS message;
        ELSEIF v_status = 'lunas' THEN
            ROLLBACK;
            SELECT 0 AS success, 'Pesanan ini sudah lunas sebelumnya.' AS message;
        ELSEIF v_status = 'dibatalkan' THEN
            ROLLBACK;
            SELECT 0 AS success, 'Pesanan sudah dibatalkan.' AS message;
        ELSE
            SELECT COUNT(*) INTO v_detail_count FROM DETAIL_PESANAN WHERE pesanan_id = p_pesanan_id;
            IF v_detail_count = 0 THEN
                ROLLBACK;
                SELECT 0 AS success, 'Detail pesanan tidak ditemukan.' AS message;
            ELSEIF v_detail_count > 1 THEN
                ROLLBACK;
                SELECT 0 AS success, 'Pesanan memiliki beberapa detail; checkout multi-produk belum didukung.' AS message;
            ELSE
                SELECT dp.jumlah, p.stok INTO v_jumlah, v_stok
                  FROM DETAIL_PESANAN dp
                  JOIN PRODUK p ON p.id = dp.produk_id
                 WHERE dp.pesanan_id = p_pesanan_id
                 FOR UPDATE;

                IF v_stok < v_jumlah THEN
                    ROLLBACK;
                    SELECT 0 AS success,
                           CONCAT('Pembayaran gagal: stok tersisa ', v_stok,
                                  ', sedangkan pesanan membutuhkan ', v_jumlah, '.') AS message;
                ELSE
                    UPDATE PESANAN SET status = 'lunas' WHERE id = p_pesanan_id;
                    -- Trigger akan mengurangi stok dan mencatat STOK_LOG di transaksi yang sama.
                    COMMIT;
                    SELECT 1 AS success,
                           CONCAT('Pembayaran pesanan #', p_pesanan_id,
                                  ' berhasil, stok otomatis diperbarui.') AS message;
                END IF;
            END IF;
        END IF;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_update_stok
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_update_stok(
    IN p_admin_id INT,
    IN p_produk_id INT,
    IN p_perubahan INT,
    IN p_alasan VARCHAR(100)
)
BEGIN
    DECLARE v_admin_ada INT DEFAULT 0;
    DECLARE v_produk_ada INT DEFAULT 0;
    DECLARE v_stok_sekarang INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_admin_id IS NULL OR p_perubahan IS NULL OR p_perubahan = 0 THEN
        ROLLBACK;
        SELECT 0 AS success, 'Admin wajib diisi dan perubahan stok tidak boleh 0.' AS message;
    ELSE
        SELECT COUNT(*) INTO v_admin_ada FROM ADMIN WHERE id = p_admin_id;
        SELECT COUNT(*) INTO v_produk_ada FROM PRODUK WHERE id = p_produk_id;

        IF v_admin_ada = 0 THEN
            ROLLBACK;
            SELECT 0 AS success, 'Admin tidak ditemukan.' AS message;
        ELSEIF v_produk_ada = 0 THEN
            ROLLBACK;
            SELECT 0 AS success, 'Produk tidak ditemukan.' AS message;
        ELSE
            SELECT stok INTO v_stok_sekarang
              FROM PRODUK
             WHERE id = p_produk_id
             FOR UPDATE;

            IF (v_stok_sekarang + p_perubahan) < 0 THEN
                ROLLBACK;
                SELECT 0 AS success, 'Stok tidak boleh menjadi negatif.' AS message;
            ELSE
                UPDATE PRODUK SET stok = stok + p_perubahan WHERE id = p_produk_id;
                INSERT INTO STOK_LOG (produk_id, admin_id, perubahan, alasan, waktu)
                VALUES (p_produk_id, p_admin_id, p_perubahan, p_alasan, NOW());
                COMMIT;
                SELECT 1 AS success, CONCAT('Stok berhasil diperbarui, perubahan: ', p_perubahan) AS message;
            END IF;
        END IF;
    END IF;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_revenue_report
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_revenue_report()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT bulan, total_pesanan, total_pendapatan
      FROM v_laporan_revenue
     ORDER BY bulan DESC;
    COMMIT;
END;

-- ------------------------------------------------------------------
-- PROCEDURE: sp_get_top_selling_report
-- ------------------------------------------------------------------
CREATE PROCEDURE sp_get_top_selling_report()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT produk_id, nama, total_terjual, total_nilai
      FROM v_produk_terlaris
     ORDER BY total_terjual DESC;
    COMMIT;
END;
