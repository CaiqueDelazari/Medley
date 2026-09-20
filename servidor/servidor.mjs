import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import express from 'express';
import cookieParser from 'cookie-parser';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import multer from 'multer';
import { Pool } from 'pg';

const porta = Number(process.env.PORT || 3000);
const siteDir = process.env.SITE_DIR || '/app/site';
const uploadDir = process.env.UPLOAD_DIR || '/app/uploads';
const segredo = process.env.JWT_SECRET;
const senhaHash = process.env.ADMIN_PASSWORD_HASH;
if (!process.env.DATABASE_URL || !segredo || !senhaHash) throw new Error('DATABASE_URL, JWT_SECRET e ADMIN_PASSWORD_HASH são obrigatórios.');
const db = new Pool({ connectionString: process.env.DATABASE_URL });
const app = express();
app.set('trust proxy', 1);
app.use(express.json({ limit: '2mb' }));
app.use(cookieParser());
app.use('/uploads', express.static(uploadDir, { maxAge: '30d', immutable: true }));

async function iniciarBanco() {
  const sql = await fs.readFile(new URL('./schema.sql', import.meta.url), 'utf8');
  await db.query(sql);
}
function exigirAdmin(req, res, next) {
  try { req.admin = jwt.verify(req.cookies.bolin_admin || '', segredo); next(); }
  catch { res.status(401).json({ error: 'Sessão expirada. Entre novamente.' }); }
}
function temSessao(req) { try { jwt.verify(req.cookies.bolin_admin || '', segredo); return true; } catch { return false; } }
function modeloPublico(m) { return m; }
const campos = new Set(['nome', 'selo', 'pitch', 'foto', 'foto_caminho', 'fotos', 'specs', 'ativo', 'ordem']);
async function atualizarModelo(id, dados) {
  const pares = Object.entries(dados).filter(([k]) => campos.has(k));
  if (!pares.length) return null;
  const valores = [];
  const sets = pares.map(([k, v], i) => {
    valores.push((k === 'fotos' || k === 'specs') ? JSON.stringify(v || []) : v);
    return `${k} = $${i + 1}${k === 'fotos' || k === 'specs' ? '::jsonb' : ''}`;
  });
  valores.push(id);
  const { rows } = await db.query(`update bolin_modelos set ${sets.join(', ')} where id = $${valores.length} returning *`, valores);
  return rows[0] || null;
}

app.get('/api/modelos', async (_req, res, next) => {
  try { const sql = temSessao(_req) ? 'select * from bolin_modelos order by ordem, criado_em' : 'select * from bolin_modelos where ativo = true order by ordem, criado_em'; const { rows } = await db.query(sql); res.json(rows.map(modeloPublico)); } catch (e) { next(e); }
});
app.get('/api/conteudo', async (_req, res, next) => {
  try { const { rows } = await db.query('select chave, valor, atualizado_em from bolin_conteudo'); res.json(rows); } catch (e) { next(e); }
});
app.post('/api/login', async (req, res) => {
  if (!(await bcrypt.compare(String(req.body?.senha || ''), senhaHash))) return res.status(401).json({ error: 'Senha incorreta.' });
  const token = jwt.sign({ papel: 'admin' }, segredo, { expiresIn: '12h' });
  res.cookie('bolin_admin', token, { httpOnly: true, sameSite: 'lax', secure: process.env.NODE_ENV === 'production', maxAge: 43200000 });
  res.json({ ok: true });
});
app.post('/api/logout', (_req, res) => { res.clearCookie('bolin_admin'); res.json({ ok: true }); });
app.get('/api/sessao', (req, res) => { try { jwt.verify(req.cookies.bolin_admin || '', segredo); res.json({ ativa: true }); } catch { res.json({ ativa: false }); } });
app.get('/api/admin/modelos', exigirAdmin, async (_req, res, next) => { try { const { rows } = await db.query('select * from bolin_modelos order by ordem, criado_em'); res.json(rows); } catch (e) { next(e); } });
app.post('/api/admin/modelos', exigirAdmin, async (req, res, next) => {
  try {
    const { rows } = await db.query("insert into bolin_modelos (nome,pitch,specs,ordem) values ($1,$2,$3::jsonb,(select coalesce(max(ordem),0)+1 from bolin_modelos)) returning *", [req.body?.nome || 'Novo modelo', req.body?.pitch || 'Escreva aqui o texto de venda deste modelo.', JSON.stringify(req.body?.specs || [{ r: 'Motor', v: '—' }, { r: 'Bateria', v: '—' }, { r: 'Recarga', v: '—' }])]);
    res.status(201).json(rows[0]);
  } catch (e) { next(e); }
});
app.patch('/api/admin/modelos/:id', exigirAdmin, async (req, res, next) => { try { const m = await atualizarModelo(req.params.id, req.body || {}); if (!m) return res.status(404).json({ error: 'Modelo não encontrado.' }); res.json(m); } catch (e) { next(e); } });
app.delete('/api/admin/modelos', exigirAdmin, async (_req, res, next) => { try { await db.query('delete from bolin_modelos'); res.status(204).end(); } catch (e) { next(e); } });
app.delete('/api/admin/modelos/:id', exigirAdmin, async (req, res, next) => { try { await db.query('delete from bolin_modelos where id = $1', [req.params.id]); res.status(204).end(); } catch (e) { next(e); } });
app.put('/api/admin/conteudo/:chave', exigirAdmin, async (req, res, next) => { try { const { rows } = await db.query('insert into bolin_conteudo (chave,valor,atualizado_em) values ($1,$2,now()) on conflict (chave) do update set valor=excluded.valor, atualizado_em=now() returning *', [req.params.chave, String(req.body?.valor || '')]); res.json(rows[0]); } catch (e) { next(e); } });
app.delete('/api/admin/conteudo', exigirAdmin, async (_req, res, next) => { try { await db.query('delete from bolin_conteudo'); res.status(204).end(); } catch (e) { next(e); } });
app.delete('/api/admin/conteudo/:chave', exigirAdmin, async (req, res, next) => { try { await db.query('delete from bolin_conteudo where chave=$1', [req.params.chave]); res.status(204).end(); } catch (e) { next(e); } });
const storage = multer.diskStorage({ destination: async (_req, _file, cb) => { const dir = path.join(uploadDir, 'bolin'); await fs.mkdir(dir, { recursive: true }); cb(null, dir); }, filename: (_req, file, cb) => cb(null, `${crypto.randomUUID()}${path.extname(file.originalname || '.jpg').toLowerCase() || '.jpg'}`) });
const upload = multer({ storage, limits: { fileSize: 8 * 1024 * 1024, files: 12 }, fileFilter: (_req, file, cb) => cb(null, /^image\//.test(file.mimetype)) });
app.post('/api/admin/upload', exigirAdmin, upload.array('fotos', 12), (req, res) => res.status(201).json((req.files || []).map(f => ({ u: `/uploads/bolin/${f.filename}`, c: `bolin/${f.filename}` }))));
app.delete('/api/admin/upload', exigirAdmin, async (req, res, next) => { try { for (const c of req.body?.caminhos || []) if (/^bolin\/[a-z0-9._-]+$/i.test(c)) await fs.rm(path.join(uploadDir, c), { force: true }); res.status(204).end(); } catch (e) { next(e); } });
app.use(express.static(siteDir));
app.use((err, _req, res, _next) => { console.error(err); res.status(500).json({ error: 'Erro interno.' }); });
await iniciarBanco();
app.listen(porta, () => console.log(`Bolin em http://0.0.0.0:${porta}`));
