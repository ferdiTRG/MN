USE task1;

CREATE FUNCTION fn_cek_stok_cukup(
    p_produk_id INT,
    p_jumlah_diminta INT
)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stok_tersedia INT DEFAULT NULL;

    IF p_jumlah_diminta IS NULL OR p_jumlah_diminta <= 0 THEN
        RETURN FALSE;
    END IF;

    SELECT MAX(stok)
      INTO v_stok_tersedia
      FROM PRODUK
     WHERE id = p_produk_id;

    IF v_stok_tersedia IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN v_stok_tersedia >= p_jumlah_diminta;
END;
