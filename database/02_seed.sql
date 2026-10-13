USE task1;

-- Data demo lokal. Password masih plaintext mengikuti skema awal proyek.
-- Jangan gunakan model penyimpanan password seperti ini untuk aplikasi sungguhan.
INSERT INTO ADMIN (id, username, password) VALUES
(1, 'busari', 'hash_password_admin');

INSERT INTO CUSTOMER (id, nama, email, no_hp, password) VALUES
(1, 's32suk', 'g2cxz@email.com', '0856463213', 'su25435123'),
(2, 'Customer Dua', 'customer2@email.com', '081200000002', 'password2'),
(3, 'Customer Tiga', 'customer3@email.com', '081200000003', 'password3');

INSERT INTO PRODUK (id, nama, kategori, harga, stok) VALUES
(1, 'Indomie Goreng', 'Makanan Instan', 3000, 50),
(2, 'Aqua Botol 600ml', 'Minuman', 5000, 30),
(3, 'Kecap ABC 220ml', 'Bumbu Dapur', 9000, 44);
