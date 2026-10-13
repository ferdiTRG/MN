USE task1;

CREATE TABLE ADMIN (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE CUSTOMER (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    no_hp VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE PRODUK (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(50),
    harga DECIMAL(10,2) NOT NULL DEFAULT 0,
    stok INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_produk_harga CHECK (harga >= 0),
    CONSTRAINT chk_produk_stok CHECK (stok >= 0)
) ENGINE=InnoDB;

CREATE TABLE PESANAN (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_bayar DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pesanan_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id),
    CONSTRAINT chk_pesanan_status CHECK (status IN ('pending', 'lunas', 'dibatalkan')),
    CONSTRAINT chk_pesanan_total CHECK (total_bayar >= 0)
) ENGINE=InnoDB;

CREATE TABLE DETAIL_PESANAN (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pesanan_id INT NOT NULL,
    produk_id INT NOT NULL,
    jumlah INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT uq_detail_pesanan_produk UNIQUE (pesanan_id, produk_id),
    CONSTRAINT fk_detail_pesanan FOREIGN KEY (pesanan_id) REFERENCES PESANAN(id),
    CONSTRAINT fk_detail_produk FOREIGN KEY (produk_id) REFERENCES PRODUK(id),
    CONSTRAINT chk_detail_jumlah CHECK (jumlah > 0),
    CONSTRAINT chk_detail_subtotal CHECK (subtotal >= 0)
) ENGINE=InnoDB;

CREATE TABLE STOK_LOG (
    id INT PRIMARY KEY AUTO_INCREMENT,
    produk_id INT NOT NULL,
    admin_id INT NULL,
    perubahan INT NOT NULL,
    alasan VARCHAR(100),
    waktu DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stok_log_produk FOREIGN KEY (produk_id) REFERENCES PRODUK(id),
    CONSTRAINT fk_stok_log_admin FOREIGN KEY (admin_id) REFERENCES ADMIN(id)
) ENGINE=InnoDB;
