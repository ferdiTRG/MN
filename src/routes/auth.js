import { Router } from 'express';
import { callProcedure } from '../db.js';
import { createToken, requireAuth } from '../auth.js';

const router = Router();

const ok = (value) => value === 1 || value === true;

router.post('/register', async (req, res) => {
  const { nama, email, no_hp, password } = req.body ?? {};
  if (typeof nama !== 'string' || !nama.trim() || typeof email !== 'string' || !email.trim() || typeof password !== 'string' || !password) {
    return res.status(400).json({ success: false, message: 'nama, email, dan password wajib diisi.' });
  }

  try {
    const rows = await callProcedure(
      'CALL sp_registrasi_customer(?, ?, ?, ?)',
      [nama.trim(), email.trim(), typeof no_hp === 'string' && no_hp ? no_hp : null, password]
    );
    const result = rows[0];
    if (!result) return res.status(500).json({ success: false, message: 'Procedure registrasi tidak mengembalikan hasil.' });
    return res.status(ok(result.success) ? 201 : 409).json({
      success: ok(result.success), message: result.message,
      data: ok(result.success) ? { customer_id: result.customer_id } : null
    });
  } catch (error) {
    const status = error?.code === 'ER_DUP_ENTRY' ? 409 : 500;
    return res.status(status).json({ success: false, message: status === 409 ? 'Email sudah terdaftar.' : 'Registrasi gagal.' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body ?? {};
  if (typeof email !== 'string' || !email || typeof password !== 'string' || !password) {
    return res.status(400).json({ success: false, message: 'email dan password wajib diisi.' });
  }

  try {
    const rows = await callProcedure('CALL sp_login_customer(?, ?)', [email, password]);
    const result = rows[0];
    if (!result || !ok(result.success) || !result.customer_id) {
      return res.status(401).json({ success: false, message: result?.message ?? 'Email atau password salah.' });
    }
    const token = createToken({ id: Number(result.customer_id), role: 'customer' });
    return res.json({ success: true, message: result.message, data: { customer_id: result.customer_id, token } });
  } catch {
    return res.status(500).json({ success: false, message: 'Login customer gagal.' });
  }
});

router.post('/admin/login', async (req, res) => {
  const { username, password } = req.body ?? {};
  if (typeof username !== 'string' || !username || typeof password !== 'string' || !password) {
    return res.status(400).json({ success: false, message: 'username dan password wajib diisi.' });
  }

  try {
    const rows = await callProcedure('CALL sp_login_admin(?, ?)', [username, password]);
    const result = rows[0];
    if (!result || !ok(result.success) || !result.admin_id) {
      return res.status(401).json({ success: false, message: result?.message ?? 'Username atau password salah.' });
    }
    const token = createToken({ id: Number(result.admin_id), role: 'admin' });
    return res.json({ success: true, message: result.message, data: { admin_id: result.admin_id, token } });
  } catch {
    return res.status(500).json({ success: false, message: 'Login admin gagal.' });
  }
});

router.get('/profile', requireAuth, async (req, res) => {
  try {
    const rows = req.user.role === 'customer'
      ? await callProcedure('CALL sp_get_customer_profile(?)', [req.user.id])
      : await callProcedure('CALL sp_get_admin_profile(?)', [req.user.id]);
    if (!rows[0]) return res.status(404).json({ success: false, message: 'Profil tidak ditemukan.' });
    return res.json({ success: true, data: rows[0] });
  } catch {
    return res.status(500).json({ success: false, message: 'Gagal mengambil profil.' });
  }
});

export default router;
