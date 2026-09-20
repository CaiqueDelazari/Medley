create extension if not exists pgcrypto;

create table if not exists bolin_modelos (
  id uuid primary key default gen_random_uuid(),
  nome text not null default 'Novo modelo',
  selo text not null default '',
  pitch text not null default '',
  foto text not null default '',
  foto_caminho text not null default '',
  fotos jsonb not null default '[]'::jsonb,
  specs jsonb not null default '[]'::jsonb,
  ativo boolean not null default true,
  ordem integer not null default 0,
  criado_em timestamptz not null default now()
);
create index if not exists bolin_modelos_ordem_idx on bolin_modelos (ativo, ordem);

create table if not exists bolin_conteudo (
  chave text primary key,
  valor text not null default '',
  atualizado_em timestamptz not null default now()
);
