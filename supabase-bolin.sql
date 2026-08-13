-- =====================================================================
-- BOLIN Electric Motor — estrutura do banco
--
-- Roda no MESMO projeto Supabase da Agropecuária JG.
-- Tudo aqui começa com "bolin_" para não encostar em nada da outra loja:
-- tabelas, função de permissão, balde de fotos e nomes de política.
--
-- Como rodar: painel do Supabase > SQL Editor > New query > cole tudo > Run.
-- Pode rodar de novo quantas vezes quiser, não quebra nada.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0) QUEM É O DONO DA PÁGINA BOLIN
--    Troque o e-mail abaixo pelo e-mail que você vai cadastrar em
--    Authentication > Users. É esse e-mail (e só ele) que consegue
--    mexer no catálogo.
--
--    O e-mail NÃO precisa existir de verdade: marcando "Auto Confirm
--    User" na criação, o Supabase não manda nenhuma confirmação — ele
--    só usa esse texto como identificador de login.
--
--    ATENÇÃO: desligue o auto-cadastro em
--      Authentication > Sign In / Providers > Email
--      > "Allow new users to sign up" = desligado
--    senão qualquer um cria uma conta sozinho.
-- ---------------------------------------------------------------------
create or replace function public.eh_dono_bolin()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from auth.users
    where id = auth.uid()
      and lower(email) = lower('bolinmotoseletricas@gmail.com')   -- <<< TROQUE AQUI
  );
$$;

revoke all on function public.eh_dono_bolin() from public;
grant execute on function public.eh_dono_bolin() to anon, authenticated;


-- ---------------------------------------------------------------------
-- 1) Catálogo de modelos
--
--    Uma linha por scooter. É isto que monta a seção "Linha BOLIN" da
--    página: a administradora cria, edita, reordena e apaga modelos
--    direto no site, sem ninguém mexer no HTML.
--
--    specs = ficha técnica, uma lista de pares rótulo/valor. Cada modelo
--    tem a sua, com quantas linhas quiser:
--      [{"r": "Motor", "v": "2.000 W"}, {"r": "Bateria", "v": "48 V"}]
--    Assim uma scooter pode ter "Velocidade" e outra "Pneu", sem obrigar
--    todas a terem as mesmas linhas.
-- ---------------------------------------------------------------------
create table if not exists public.bolin_modelos (
  id           uuid primary key default gen_random_uuid(),
  nome         text not null default 'Novo modelo',
  selo         text default '',          -- tarja da foto: "Mais vendida", "Topo de linha"…
  pitch        text default '',          -- o texto de venda embaixo do nome
  foto         text default '',          -- endereço público da imagem
  foto_caminho text default '',          -- arquivo dentro do balde, para apagar na troca
  specs        jsonb not null default '[]'::jsonb,
  ativo        boolean not null default true,   -- false = some do site sem ser apagado
  ordem        int not null default 0,          -- menor aparece primeiro
  criado_em    timestamptz default now()
);

create index if not exists bolin_modelos_ordem_idx
  on public.bolin_modelos (ativo, ordem);


-- ---------------------------------------------------------------------
-- 2) Textos e telefone da página
--    Guarda só o que foi reescrito. O que não estiver aqui continua
--    vindo do próprio HTML. A chave 'whatsapp' guarda o número do
--    atendimento.
-- ---------------------------------------------------------------------
create table if not exists public.bolin_conteudo (
  chave         text primary key,
  valor         text not null default '',
  atualizado_em timestamptz default now()
);


-- ---------------------------------------------------------------------
-- 3) Segurança (RLS)
--    Visitante LÊ (é assim que a página monta o catálogo).
--    Só a dona ESCREVE.
-- ---------------------------------------------------------------------
alter table public.bolin_modelos  enable row level security;
alter table public.bolin_conteudo enable row level security;

drop policy if exists "bolin modelos: todos leem"      on public.bolin_modelos;
drop policy if exists "bolin modelos: dono escreve"    on public.bolin_modelos;
drop policy if exists "bolin conteudo: todos leem"     on public.bolin_conteudo;
drop policy if exists "bolin conteudo: dono escreve"   on public.bolin_conteudo;

-- visitante enxerga só modelo ativo; a dona enxerga tudo
create policy "bolin modelos: todos leem"
  on public.bolin_modelos for select
  to anon, authenticated
  using (ativo or public.eh_dono_bolin());

create policy "bolin modelos: dono escreve"
  on public.bolin_modelos for all
  to authenticated
  using (public.eh_dono_bolin()) with check (public.eh_dono_bolin());

create policy "bolin conteudo: todos leem"
  on public.bolin_conteudo for select
  to anon, authenticated
  using (true);

create policy "bolin conteudo: dono escreve"
  on public.bolin_conteudo for all
  to authenticated
  using (public.eh_dono_bolin()) with check (public.eh_dono_bolin());


-- ---------------------------------------------------------------------
-- 4) Balde das fotos (Storage)
--    Separado do balde 'produtos' da Agropecuária. Os nomes das políticas
--    também são diferentes, então rodar o SQL de uma loja nunca derruba
--    as regras da outra.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('bolin', 'bolin', true)
on conflict (id) do nothing;

drop policy if exists "bolin arquivos: todos veem"  on storage.objects;
drop policy if exists "bolin arquivos: dono envia"  on storage.objects;
drop policy if exists "bolin arquivos: dono troca"  on storage.objects;
drop policy if exists "bolin arquivos: dono apaga"  on storage.objects;

create policy "bolin arquivos: todos veem"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'bolin');

create policy "bolin arquivos: dono envia"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'bolin' and public.eh_dono_bolin());

create policy "bolin arquivos: dono troca"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'bolin' and public.eh_dono_bolin())
  with check (bucket_id = 'bolin' and public.eh_dono_bolin());

create policy "bolin arquivos: dono apaga"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'bolin' and public.eh_dono_bolin());
