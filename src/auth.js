import jwt from 'jsonwebtoken';

/**
 * Payload token: { id: number, role: 'customer' | 'admin' }
 */

function getSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 24) {
    throw new Error('JWT_SECRET harus diisi dengan secret acak minimal 24 karakter pada file .env.');
  }
  return secret;
}

export function createToken(payload) {
  return jwt.sign(payload, getSecret(), { expiresIn: '2h' });
}

export function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Token Bearer diperlukan.' });
  }

  try {
    req.user = jwt.verify(header.slice(7), getSecret());
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Token tidak valid atau sudah kedaluwarsa.' });
  }
}

export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ success: false, message: 'Akses ditolak.' });
    }
    next();
  };
}
