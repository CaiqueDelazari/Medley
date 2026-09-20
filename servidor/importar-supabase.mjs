import { Pool } from 'pg';
import fs from 'node:fs/promises';
import path from 'node:path';

const origem = 'https://vvasybgcuxiufimnmfxa.supabase.co';
const chave = 'sb_publishable_uvmoyalfvsMxd03EAgnRLw_2BLgNvPy';
const db = new Pool({ connectionString: process.env.DATABASE_URL });
const h = { apikey: chave, Authorization: `Bearer ${chave}` };
const uploadDir = process.env.UPLOAD_DIR || '/app/uploads';
const obter = async rota => { const r = await fetch(origem + rota, { headers: h }); if (!r.ok) throw new Error(`Supabase respondeu ${r.status}`); return r.json(); };
const schema = await fs.readFile(new URL('./schema.sql', import.meta.url), 'utf8');
await db.query(schema);
const [modelos, conteudo] = await Promise.all([obter('/rest/v1/bolin_modelos?select=*&order=ordem.asc,criado_em.asc'), obter('/rest/v1/bolin_conteudo?select=*')]);
for (const modelo of modelos) {
  const fotos = Array.isArray(modelo.fotos) ? modelo.fotos : [];
  for (const foto of fotos) {
    if (!foto?.u || !/supabase\.co\/storage\/v1\/object\/public\/bolin\//.test(foto.u)) continue;
    const nome = String(foto.c || new URL(foto.u).pathname.split('/').pop()).replace(/^bolin\//, '');
    if (!/^[a-z0-9._-]+$/i.test(nome)) throw new Error(`Nome de foto inválido: ${nome}`);
    const destino = path.join(uploadDir, 'bolin', nome);
    await fs.mkdir(path.dirname(destino), { recursive: true });
    const resposta = await fetch(foto.u);
    if (!resposta.ok) throw new Error(`Não consegui copiar a foto ${nome}: ${resposta.status}`);
    await fs.writeFile(destino, Buffer.from(await resposta.arrayBuffer()));
    foto.u = `/uploads/bolin/${nome}`;
    foto.c = `bolin/${nome}`;
  }
  modelo.fotos = fotos;
  if (fotos.length) { modelo.foto = fotos[0].u; modelo.foto_caminho = fotos[0].c || ''; }
}
await db.query('begin');
try {
  for (const m of modelos) await db.query(`insert into bolin_modelos (id,nome,selo,pitch,foto,foto_caminho,fotos,specs,ativo,ordem,criado_em) values ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9,$10,$11) on conflict (id) do update set nome=excluded.nome,selo=excluded.selo,pitch=excluded.pitch,foto=excluded.foto,foto_caminho=excluded.foto_caminho,fotos=excluded.fotos,specs=excluded.specs,ativo=excluded.ativo,ordem=excluded.ordem`, [m.id,m.nome,m.selo,m.pitch,m.foto,m.foto_caminho,JSON.stringify(m.fotos || []),JSON.stringify(m.specs || []),m.ativo,m.ordem,m.criado_em]);
  for (const c of conteudo) await db.query('insert into bolin_conteudo (chave,valor,atualizado_em) values ($1,$2,$3) on conflict (chave) do update set valor=excluded.valor, atualizado_em=excluded.atualizado_em', [c.chave,c.valor,c.atualizado_em]);
  await db.query('commit'); console.log(`Importados ${modelos.length} modelos e ${conteudo.length} textos.`);
} catch (e) { await db.query('rollback'); throw e; } finally { await db.end(); }
