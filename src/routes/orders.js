import { Router } from 'express';
import { callProcedure } from '../db.js';
import { requireAuth } from '../auth.js';

const router = Router();
const ok = (value) => value === 1 || value === true;

router.post('/', requireAuth, async (req, res) => {
  const { produk_id, jumlah } = req.body ?? {};
  if (req.user.role !== 'customer') return res.status(403).json({ success: false, message: 'Hanya customer yang dapat membuat pesanan.' });
  if (!Number.isInteger(Number(produk_id)) || Number(produk_id) <= 0 || !Number.isInteger(Number(jumlah)) || Number(jumlah) <= 0) {
    return res.status(400).json({ success: false, message: 'produk_id dan jumlah harus berupa bilangan bulat positif.' });
  }
  try {
    const rows = await callProcedure('CALL sp_buat_pesanan(?, ?, ?)', [req.user.id, Number(produk_id), Number(jumlah)]);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 201 : 400).json({
      success: ok(result.success), message: result.message,
      data: ok(result.success) ? { pesanan_id: result.pesanan_id, total_bayar: result.total_bayar } : null
    });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal membuat pesanan.' });
  }
});

router.get('/', requireAuth, async (req, res) => {
  try {
    const rows = req.user.role === 'customer'
      ? await callProcedure('CALL sp_get_orders_customer(?)', [req.user.id])
      : await callProcedure('CALL sp_get_orders_admin()');
    return res.json({ success: true, data: rows });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil daftar pesanan.' });
  }
});

router.get('/:id', requireAuth, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return res.status(400).json({ success: false, message: 'ID pesanan tidak valid.' });
  try {
    const rows = req.user.role === 'customer'
      ? await callProcedure('CALL sp_get_order_detail_customer(?, ?)', [id, req.user.id])
      : await callProcedure('CALL sp_get_order_detail_admin(?)', [id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan.' });
    return res.json({ success: true, data: rows });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil detail pesanan.' });
  }
});

router.post('/:id/pay', requireAuth, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return res.status(400).json({ success: false, message: 'ID pesanan tidak valid.' });
  const customerId = req.user.role === 'customer' ? req.user.id : null;
  try {
    const rows = await callProcedure('CALL sp_bayar_pesanan(?, ?)', [id, customerId]);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 200 : 409).json({ success: ok(result.success), message: result.message });
  } catch (error) {
    const code = error?.code;
    const status = code === 'ER_SIGNAL_EXCEPTION' || code === 'ER_SIGNAL_NOT_FOUND' ? 409 : 500;
    return res.status(status).json({ success: false, message: status === 409 ? 'Pembayaran gagal karena kondisi pesanan atau stok tidak valid.' : 'Gagal memproses pembayaran.' });
  }
});

export default router;
