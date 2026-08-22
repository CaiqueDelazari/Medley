-- =====================================================================
-- BOLIN Electric Motor — o catálogo inteiro
--
-- Este arquivo NÃO cria tabela nenhuma: ele só troca o conteúdo. A
-- estrutura continua sendo a do supabase-bolin.sql — rode aquele antes,
-- se ainda não rodou.
--
-- O que ele faz:
--   1) apaga o catálogo que estiver no banco
--   2) cadastra os 34 produtos dos dois catálogos do fabricante:
--      "Catalogo Scooters - Correto" (23) e "Novo Catálogo de Produtos -
--      Plus" (11 — a página do KS202 e a do 201 Mini vêm repetidas lá e
--      entram uma vez só)
--   3) cadastra o E50, que não está em catálogo nenhum — são 35 no fim
--
--   O quadriciclo "4 Wheels" saía nos dois catálogos do fabricante, mas
--   a loja não trabalha com ele: foi tirado a pedido do Caique. Era o
--   único do grupo "Quadriciclo", então esse botão sumiu da barra de
--   filtros junto — a barra é montada a partir das tarjas dos produtos.
--   As fotos dele também saíram de site/catalogo.
--
-- Cada produto entra com DUAS fotos: o produto recortado, que é a capa
-- do card, e a página inteira do catálogo, que fica na fileira de
-- miniaturas. As duas são arquivo do site (pasta "site/catalogo" no
-- repositório, endereço /catalogo/... no navegador), não estão no
-- Storage. Deploy sem essa pasta deixa o catálogo sem foto.
--
-- Como rodar: painel do Supabase > SQL Editor > New query > cole tudo > Run.
-- Pode rodar de novo quantas vezes quiser: ele começa limpando.
--
-- ATENÇÃO: o passo 1 apaga TUDO que estiver cadastrado, inclusive modelo
-- que a administradora tenha criado pelo cadeado. Se ela já tiver subido
-- foto própria de algum produto, a foto continua no balde "bolin" mas
-- solta, sem modelo apontando para ela.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) Limpa o catálogo
--
--    Estava no ar uma lista antiga de oito modelos (X-13, X-15, X-20,
--    E-10 a E-50) escrita antes de o catálogo de verdade chegar: nomes
--    com traço que a fábrica não usa, ficha técnica pela metade e nenhuma
--    foto. Sai tudo.
-- ---------------------------------------------------------------------
delete from public.bolin_modelos;


-- ---------------------------------------------------------------------
-- 2) O catálogo
--
--    A ficha de cada um é a que está impressa na página dele. Onde o
--    catálogo não traz um número, a linha simplesmente não existe — é o
--    caso da bateria da MC027 4000 W e do carregador da R8 Plus.
--
--    Não entra AUTONOMIA: nenhum dos dois catálogos traz esse número.
--    Quando a fábrica mandar, é uma linha a mais na ficha de cada
--    modelo, e dá para fazer pelo próprio cadeado, no botão
--    "+ linha na ficha".
--
--    O "selo" é a tarja que aparece em cima da foto E o nome do grupo na
--    barra de filtros do site. Mexer no selo de um produto muda os dois
--    ao mesmo tempo; um selo novo vira um botão novo na barra sozinho.
-- ---------------------------------------------------------------------
with catalogo(ordem, nome, selo, arquivo, pitch, specs) as (values

  -- ---------- Scooters de perna larga ----------
  (1, 'X15', 'Scooter', 'x15',
   'Banco corrido com encosto, pneu largo e roda de raios. Ré e bluetooth de série.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Ré + bluetooth"},{"r":"Cores","v":"Verde · Preto · Vermelho · Cinza"}]'::jsonb),

  (2, 'X13', 'Scooter', 'x13',
   'A mesma mecânica da X15 com entrada para duas baterias — o dobro de rua sem trocar de modelo.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Ré + bluetooth · entrada para 2 baterias"},{"r":"Cores","v":"Vermelho · Preto · Cinza · Union Jack"}]'::jsonb),

  (3, 'X11', 'Scooter', 'x11',
   'A X de todo dia: acabamento preto fosco, encosto e bagageiro atrás do banco.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Ré + bluetooth"},{"r":"Cores","v":"Vermelho · Preto · Cinza · Union Jack"}]'::jsonb),

  (4, 'X20', 'Scooter', 'x20',
   'A mais equipada da linha X: farol duplo, espelhos e banco estofado com encosto.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Ré + bluetooth"},{"r":"Cores","v":"Preto · Vermelho · Branco · Verde · Union Jack"}]'::jsonb),

  (5, '701', 'Scooter', '701',
   'Desenho de chopper, farol redondo e para-lama largo. Carregador de 3 A, o mais rápido da linha.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"3 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Azul · Laranja"}]'::jsonb),

  (6, '701 Mini', 'Scooter', '701-mini',
   'A 701 num corpo menor, para quem quer o mesmo visual em rua apertada.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Azul · Laranja"}]'::jsonb),

  -- ---------- Motos elétricas ----------
  (7, 'E10', 'Moto elétrica', 'e10',
   'Carenagem fechada, baú traseiro e farol de LED. A cara de moto, com 1.000 W embaixo.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Branco · Verde · Cinza"}]'::jsonb),

  (8, 'E20', 'Moto elétrica', 'e20',
   'Linhas retas, farol quadrado e detalhes em verde-limão. A esportiva da linha E.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Branco · Cinza"}]'::jsonb),

  (9, 'E30', 'Moto elétrica', 'e30',
   'Acabamento liso, espelhos e farol integrado à carenagem. A mais sóbria das E.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Azul · Marrom · Branco"}]'::jsonb),

  (10, 'E40', 'Moto elétrica', 'e40',
   'A maior da linha E: para-brisa, farol duplo e banco alongado para dois.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Branco · Verde · Marrom"}]'::jsonb),

  -- ---------- Ciclomotores ----------
  (12, '1822', 'Ciclomotor', '1822',
   'Banco duplo, cesto na frente e bagageiro atrás. Bateria de 60 V no corpo mais leve da linha.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"60 V · 20 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Verde · Branco"}]'::jsonb),

  (13, '1958', 'Ciclomotor', '1958',
   'Painel redondo, cesto de vime e barra lateral laranja. O de visual mais retrô.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza"}]'::jsonb),

  (14, '1962', 'Ciclomotor', '1962',
   'Farol duplo redondo, estribo largo e garupa com encosto.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza"}]'::jsonb),

  (15, '1970', 'Ciclomotor', '1970',
   'Espelhos, cesto na frente e baú lateral. O mais completo dos ciclomotores.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza"}]'::jsonb),

  (16, '1994', 'Ciclomotor', '1994',
   'O mais simples da linha: leve, com cesto, dois bancos e nada sobrando.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 20 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Branco"}]'::jsonb),

  (17, '2002', 'Ciclomotor', '2002',
   'Rodas maiores, quadro reforçado e garupa larga. O de carga entre os ciclomotores.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 20 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza"}]'::jsonb),

  -- ---------- Triciclos ----------
  (18, 'T1', 'Triciclo', 't1',
   'Três rodas, baú traseiro e banco estofado. Estabilidade para quem não anda de duas.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 18 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"3 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza · Branco"}]'::jsonb),

  (19, 'T2', 'Triciclo', 't2',
   'Cesto na frente, estribo largo e banco duplo com encosto e apoio de braço.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 18 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"3 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza · Branco"}]'::jsonb),

  (20, 'T3', 'Triciclo', 't3',
   'O mais comprido dos três: estribo de carga entre as rodas, cesto e dois bancos.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 18 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"3 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho · Cinza · Branco"}]'::jsonb),

  -- ---------- Off-road ----------
  (21, 'W1 Plus', 'Off-road', 'w1-plus',
   'Moto de trilha elétrica, suspensão longa e pneu cravado. Velocidade ajustável no painel.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"48 V · 20 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Velocidade ajustável"},{"r":"Cores","v":"Preto"}]'::jsonb),

  (22, 'M3', 'Off-road', 'm3',
   'Motocross elétrica menor, para piloto em formação. Velocidade ajustável pelo responsável.',
   '[{"r":"Motor","v":"500 W"},{"r":"Bateria","v":"48 V · 12 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Diferenciais","v":"Velocidade ajustável"},{"r":"Cores","v":"Vermelho · Branco"}]'::jsonb),

  (23, 'R8 Plus', 'Off-road', 'r8-plus',
   'Bicicleta elétrica de pneu gordo, com pedal, marchas e freio a disco nas duas rodas.',
   '[{"r":"Motor","v":"750 W"},{"r":"Bateria","v":"48 V · 15 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto"}]'::jsonb),

  -- ---------- Patinetes ----------
  (24, 'MC027 2000 W', 'Patinete', 'mc027-2000w',
   'Pneu off-road, farol duplo e suspensão dianteira. O patinete de entrada da linha grande.',
   '[{"r":"Motor","v":"2.000 W"},{"r":"Bateria","v":"48 V · 15,6 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Laranja · Preto"}]'::jsonb),

  (25, 'MC027 4000 W', 'Patinete', 'mc027-4000w',
   'O mesmo chassi off-road do 2000 W com o dobro de motor. O topo de linha dos patinetes.',
   '[{"r":"Motor","v":"4.000 W"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Laranja · Preto"}]'::jsonb),

  (26, 'M4', 'Patinete', 'm4',
   'Com banco, suspensão e pneu largo. O de giro mais rápido: fecha venda no primeiro contato.',
   '[{"r":"Motor","v":"500 W"},{"r":"Bateria","v":"48 V · 10 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto · Vermelho"}]'::jsonb),

  (27, 'M6', 'Patinete', 'm6',
   'Banco e bagageiro traseiro, com 1.000 W. Para quem carrega peso no dia a dia.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"48 V · 15 A"},{"r":"Velocidade","v":"25 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Vermelho · Branco"}]'::jsonb),

  (28, 'M7', 'Patinete', 'm7',
   'Banco, baú traseiro e faixa de LED no estribo. O mais chamativo dos patinetes.',
   '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"48 V · 15 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto"}]'::jsonb),

  (29, 'XMAX', 'Patinete', 'xmax',
   'Dobrável, sem banco, para cidade. Entra no porta-malas e no elevador.',
   '[{"r":"Motor","v":"500 W"},{"r":"Bateria","v":"48 V · 8,8 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Preto"}]'::jsonb),

  (30, 'XXH', 'Patinete', 'xxh',
   'Banco com encosto e cesto na frente, a 18 km/h. O mais tranquilo da linha.',
   '[{"r":"Motor","v":"250 W"},{"r":"Bateria","v":"48 V · 3,6 A"},{"r":"Velocidade","v":"18 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Rosa · Azul · Preto"}]'::jsonb),

  -- ---------- Infantil ----------
  (31, 'KS202', 'Infantil', 'ks202',
   'Patinete infantil de 130 W, com guidão regulável e pé de apoio. Sai em quatro cores.',
   '[{"r":"Motor","v":"130 W"},{"r":"Bateria","v":"24 V · 2,5 A"},{"r":"Velocidade","v":"15 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"3 horas"},{"r":"Cores","v":"Rosa · Azul · Amarelo · Preto"}]'::jsonb),

  (32, '201 Mini', 'Infantil', '201-mini',
   'Triciclo de drift, com rodinhas giratórias atrás e desenho de fogo. Recarrega em 3 horas.',
   '[{"r":"Motor","v":"180 W"},{"r":"Bateria","v":"36 V · 2,5 A"},{"r":"Velocidade","v":"15 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"3 horas"},{"r":"Cores","v":"Rosa · Azul · Amarelo · Preto"}]'::jsonb),

  -- ---------- Cadeiras de rodas ----------
  (33, 'E100', 'Cadeira de rodas', 'e100',
   'Motorizada e dobrável, com comando no apoio de braço. Comporta duas baterias.',
   '[{"r":"Motor","v":"250 W"},{"r":"Bateria","v":"24 V · 12 A"},{"r":"Velocidade","v":"6 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"3 horas"},{"r":"Diferenciais","v":"Comporta 2 baterias"}]'::jsonb),

  (34, 'E200', 'Cadeira de rodas', 'e200',
   'Rodas grandes atrás e 800 W: encara calçada ruim e subida sem perder tração.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 20 A"},{"r":"Velocidade","v":"7 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"3 horas"},{"r":"Cores","v":"Preto"}]'::jsonb),

  (35, 'E300', 'Cadeira de rodas', 'e300',
   'Reclinável, com encosto de cabeça e apoio de pernas. Para quem passa o dia sentado.',
   '[{"r":"Motor","v":"800 W"},{"r":"Bateria","v":"48 V · 20 A"},{"r":"Velocidade","v":"7 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"3 horas"},{"r":"Cores","v":"Preto"}]'::jsonb)
)
insert into public.bolin_modelos
       (nome, selo, pitch, foto, foto_caminho, fotos, specs, ativo, ordem)
select c.nome,
       c.selo,
       c.pitch,
       '/catalogo/' || c.arquivo || '.jpg',
       '',                                   -- não está no balde: é arquivo do site
       jsonb_build_array(
         jsonb_build_object('u', '/catalogo/' || c.arquivo || '.jpg', 'c', ''),
         jsonb_build_object('u', '/catalogo/' || c.arquivo || '-ficha.jpg', 'c', '')
       ),
       c.specs,
       true,
       c.ordem
  from catalogo c;


-- ---------------------------------------------------------------------
-- 3) O E50
--
--    Ele não veio de nenhum dos dois PDFs do fabricante: chegou depois,
--    e as fotos são as três que a loja tirou — preta, verde e cinza, do
--    mesmo ângulo. Por isso ele entra num insert só dele: todo o resto
--    do catálogo tem sempre duas fotos (o produto recortado e a página
--    do catálogo), e o E50 tem três e nenhuma página.
--
--    A ficha é a que o Caique mandou. As cores também são as dele:
--    branco, cinza, verde e preto.
--
--    Ordem 11 põe o E50 logo depois do E40, fechando a linha E — por
--    isso os produtos daí para baixo estão numerados a partir de 12.
-- ---------------------------------------------------------------------
insert into public.bolin_modelos
       (nome, selo, pitch, foto, foto_caminho, fotos, specs, ativo, ordem)
values ('E50',
        'Moto elétrica',
        'Baú de série, espelhos e faixa de LED acesa na frente. A mais equipada da linha E.',
        '/catalogo/e50.jpg',
        '',                                  -- não está no balde: é arquivo do site
        jsonb_build_array(
          jsonb_build_object('u', '/catalogo/e50.jpg',       'c', ''),
          jsonb_build_object('u', '/catalogo/e50-verde.jpg', 'c', ''),
          jsonb_build_object('u', '/catalogo/e50-cinza.jpg', 'c', '')
        ),
        '[{"r":"Motor","v":"1.000 W"},{"r":"Bateria","v":"60 V · 21 A"},{"r":"Velocidade","v":"32 km/h"},{"r":"Carregador","v":"2 A"},{"r":"Recarga","v":"5 horas"},{"r":"Cores","v":"Branco · Cinza · Verde · Preto"}]'::jsonb,
        true,
        11);


-- ---------------------------------------------------------------------
-- Conferência: como ficou o catálogo
-- ---------------------------------------------------------------------
select ordem, nome, selo, jsonb_array_length(fotos) as fotos, foto
  from public.bolin_modelos
 order by ordem;

select selo, count(*) as produtos
  from public.bolin_modelos
 group by selo
 order by min(ordem);
