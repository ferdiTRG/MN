import mysql from 'mysql2/promise';
import 'dotenv/config';

const dbUser = process.env.DB_USER ?? 'Admin_op';
if (dbUser.toLowerCase() === 'root') {
  throw new Error('DB_USER tidak boleh root. Gunakan user database khusus Admin_op.');
}

export const pool = mysql.createPool({
  host: process.env.DB_HOST ?? '127.0.0.1',
  port: Number(process.env.DB_PORT ?? 3306),
  user: dbUser,
  password: process.env.DB_PASSWORD ?? '',
  database: process.env.DB_NAME ?? 'task1',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  multipleStatements: false
});

/**
 * Semua akses database aplikasi dilakukan lewat CALL stored procedure.
 * Fungsi ini mengambil result set pertama yang dikembalikan procedure.
 */
export async function callProcedure(statement, params = []) {
  if (!/^\s*CALL\s/i.test(statement)) {
    throw new Error('Akses database aplikasi hanya boleh menggunakan CALL stored procedure.');
  }

  const [rawResult] = await pool.query(statement, params);
  const firstResultSet = rawResult.find((part) => Array.isArray(part));
  return firstResultSet ?? [];
}
