import { Router } from 'express';
import { callProcedure } from '../db.js';
import { requireAuth, requireRole } from '../auth.js';

const router = Router();
const ok = (value) => value === 1 || value === true;

router.get('/', async (_req, res) => {
  try {
    const rows = await callProcedure('CALL sp_get_products()');
    return res.json({ success: true, data: rows });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil produk.' });
  }
});

router.get('/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return res.status(400).json({ success: false, message: 'ID produk tidak valid.' });
  try {
    const rows = await callProcedure('CALL sp_get_product_by_id(?)', [id]);
    if (!rows[0]) return res.status(404).json({ success: false, message: 'Produk tidak ditemukan.' });
    return res.json({ success: true, data: rows[0] });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil produk.' });
  }
});

router.post('/', requireAuth, requireRole('admin'), async (req, res) => {
  const { nama, kategori, harga, stok = 0 } = req.body ?? {};
  if (typeof nama !== 'string' || !nama.trim() || !Number.isFinite(Number(harga)) || Number(harga) < 0 || !Number.isInteger(Number(stok)) || Number(stok) < 0) {
    return res.status(400).json({ success: false, message: 'nama wajib diisi, harga harus >= 0, dan stok harus bilangan bulat >= 0.' });
  }
  try {
    const rows = await callProcedure('CALL sp_create_product(?, ?, ?, ?)', [nama.trim(), kategori ?? null, Number(harga), Number(stok)]);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 201 : 400).json({ success: ok(result.success), message: result.message, data: ok(result.success) ? { id: result.id } : null });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal membuat produk.' });
  }
});

router.put('/:id', requireAuth, requireRole('admin'), async (req, res) => {
  const id = Number(req.params.id);
  const { nama, kategori, harga } = req.body ?? {};
  if (!Number.isInteger(id) || id <= 0 || typeof nama !== 'string' || !nama.trim() || !Number.isFinite(Number(harga)) || Number(harga) < 0) {
    return res.status(400).json({ success: false, message: 'ID, nama, atau harga tidak valid.' });
  }
  try {
    const rows = await callProcedure('CALL sp_update_product(?, ?, ?, ?)', [id, nama.trim(), kategori ?? null, Number(harga)]);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 200 : 404).json({ success: ok(result.success), message: result.message });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal memperbarui produk.' });
  }
});

router.delete('/:id', requireAuth, requireRole('admin'), async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return res.status(400).json({ success: false, message: 'ID produk tidak valid.' });
  try {
    const rows = await callProcedure('CALL sp_delete_product(?)', [id]);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 200 : 404).json({ success: ok(result.success), message: result.message });
  } catch (error) {
    const code = error?.code;
    const status = code === 'ER_ROW_IS_REFERENCED_2' || code === 'ER_ROW_IS_REFERENCED' ? 409 : 500;
    return res.status(status).json({ success: false, message: status === 409 ? 'Produk tidak dapat dihapus karena sudah digunakan dalam pesanan.' : 'Gagal menghapus produk.' });
  }
});

router.patch('/:id/stock', requireAuth, requireRole('admin'), async (req, res) => {
  const id = Number(req.params.id);
  const { perubahan, alasan } = req.body ?? {};
  if (!Number.isInteger(id) || id <= 0 || !Number.isInteger(Number(perubahan)) || Number(perubahan) === 0) {
    return res.status(400).json({ success: false, message: 'ID produk valid dan perubahan stok berupa bilangan bulat bukan nol wajib diisi.' });
  }
  try {
    const rows = await callProcedure('CALL sp_update_stok(?, ?, ?, ?)', [req.user.id, id, Number(perubahan), typeof alasan === 'string' ? alasan : 'Perubahan via API']);
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 200 : 400).json({ success: ok(result.success), message: result.message });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengubah stok.' });
  }
});

export default router;
