import jwt from 'jsonwebtoken';
import type { Request, Response, NextFunction } from 'express';

export type AuthPayload = {
  id: number;
  role: 'customer' | 'admin';
};

function getSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 24) {
    throw new Error('JWT_SECRET harus diisi dengan secret acak minimal 24 karakter pada file .env.');
  }
  return secret;
}

export function createToken(payload: AuthPayload) {
  return jwt.sign(payload, getSecret(), { expiresIn: '2h' });
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Token Bearer diperlukan.' });
  }

  try {
    req.user = jwt.verify(header.slice(7), getSecret()) as AuthPayload;
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Token tidak valid atau sudah kedaluwarsa.' });
  }
}

export function requireRole(role: AuthPayload['role']) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ success: false, message: 'Akses ditolak.' });
    }
    next();
  };
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthPayload;
    }
  }
}
