USE task1;

CREATE TRIGGER trg_potong_stok_log
AFTER UPDATE ON PESANAN
FOR EACH ROW
BEGIN
    IF NEW.status = 'lunas' AND OLD.status <> 'lunas' THEN
        IF EXISTS (
            SELECT 1
              FROM DETAIL_PESANAN dp
              JOIN PRODUK p ON p.id = dp.produk_id
             WHERE dp.pesanan_id = NEW.id
               AND p.stok < dp.jumlah
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Stok tidak mencukupi untuk menyelesaikan pembayaran.';
        END IF;

        UPDATE PRODUK p
        JOIN DETAIL_PESANAN dp ON dp.produk_id = p.id
           SET p.stok = p.stok - dp.jumlah
         WHERE dp.pesanan_id = NEW.id;

        INSERT INTO STOK_LOG (produk_id, admin_id, perubahan, alasan, waktu)
        SELECT dp.produk_id, NULL, -dp.jumlah, CONCAT('Penjualan #', NEW.id), NOW()
          FROM DETAIL_PESANAN dp
         WHERE dp.pesanan_id = NEW.id;
    END IF;
END;
