import { Router } from 'express';
import type { RowDataPacket } from 'mysql2';
import { callProcedure } from '../db.js';
import { requireAuth, requireRole } from '../auth.js';

const router = Router();
router.use(requireAuth, requireRole('admin'));

router.get('/revenue', async (_req, res) => {
  try {
    const rows = await callProcedure<RowDataPacket>('CALL sp_get_revenue_report()');
    return res.json({ success: true, data: rows });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil laporan revenue.' });
  }
});

router.get('/top-selling', async (_req, res) => {
  try {
    const rows = await callProcedure<RowDataPacket>('CALL sp_get_top_selling_report()');
    return res.json({ success: true, data: rows });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil laporan produk terlaris.' });
  }
});

export default router;
