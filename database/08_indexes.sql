USE task1;

CREATE INDEX idx_pesanan_customer_created ON PESANAN(customer_id, created_at);
CREATE INDEX idx_pesanan_status_created ON PESANAN(status, created_at);
CREATE INDEX idx_produk_kategori ON PRODUK(kategori);
CREATE INDEX idx_stok_log_waktu ON STOK_LOG(waktu);
CREATE INDEX idx_stok_log_admin_waktu ON STOK_LOG(admin_id, waktu);
