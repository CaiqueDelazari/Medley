# BOLIN Electric Motor — página de captação + catálogo

Página única de atacado (`index.html`). A seção **Linha BOLIN** é um
catálogo de verdade: **35 produtos**, separados por tipo numa barra de
grupos, cada um com fotos, tarja, texto de venda e ficha técnica própria.
A administradora entra com e-mail e senha e cria, edita, reordena, esconde
e apaga produtos. O que ela salva vai para o banco e aparece na hora para
quem abrir o site.

## Arquivos

O que está dentro de **`site/`** é o site. O que está fora **nunca vai para
o ar** — quem garante isso é o `wrangler.toml` (e, enquanto o Netlify não for
desligado, o `netlify.toml`).

| Arquivo | O que é |
|---|---|
| `site/index.html` | A página inteira (visual, catálogo, formulário e área de edição) |
| `site/privacidade.html` | Política de privacidade — exigida pelo Google Ads e pela LGPD |
| `site/catalogo/` | As fotos dos 35 produtos: as dos PDFs do fabricante mais as três do E50, que a loja tirou |
| `site/videos/` | Os três vídeos da seção "Em movimento" |
| `site/Logo (2).jpeg` | Logo da marca |
| `wrangler.toml` | Diz ao Cloudflare Pages que só a pasta `site/` é publicada |
| `netlify.toml` | O mesmo para o Netlify — fica até a troca de servidor terminar |
| `supabase-bolin.sql` | Estrutura do banco — roda uma vez no Supabase |
| `supabase-bolin-catalogo.sql` | Conteúdo do catálogo — limpa e cadastra os 35 produtos |
| `LEIA-ME.md` | Este arquivo |

Os três produtos escritos no HTML (X15, T1 e MC027 2000 W) são **reserva**:
aparecem só enquanto o banco estiver vazio ou fora do ar. No instante em que
existir um produto cadastrado, a lista inteira passa a vir do banco.

---

## De onde veio o catálogo

Os dois PDFs do fabricante — **"Catalogo Scooters - Correto"** (24 produtos)
e **"Novo Catálogo de Produtos - Plus"** (11; a página do KS202 e a do 201
Mini vêm repetidas lá e entraram uma vez só).

Cada produto tem **duas fotos**, as duas na pasta `catalogo/`:

| Arquivo | O que é |
|---|---|
| `x15.jpg` | só o produto, recortado da página — é a capa do card |
| `x15-ficha.jpg` | a página inteira do catálogo, com o nome grande e as cores |

A ficha técnica de cada um é a que está impressa na página dele. Onde o
catálogo não traz um número, a linha simplesmente não existe — é o caso da
bateria da MC027 4000 W e do carregador da R8 Plus.

**Não existe AUTONOMIA em lugar nenhum dos dois catálogos.** Quando a
fábrica mandar esse número, é uma linha a mais na ficha de cada produto, e
dá para fazer pelo próprio cadeado, no botão "+ linha na ficha".

### Os grupos

A barra de botões em cima do catálogo (`Tudo · Scooter · Moto elétrica · …`)
**não está escrita em lugar nenhum**: ela é montada a partir da **tarja** de
cada produto, na ordem em que eles aparecem. Consequências práticas:

- Trocar a tarja de um produto muda a tarja na foto **e** o grupo dele.
- Uma tarja nova vira um botão novo sozinha.
- Produto sem tarja não some: ele aparece em "Tudo", só não entra em grupo
  nenhum. Vale a pena dar tarja a todo mundo.
- Com menos de dois grupos a barra some — não faz sentido filtrar.

Hoje são seis: autopropelido (17), Triciclo (3), Off-road (3), Patinete (7),
Infantil (2) e Cadeira de rodas (3).

Scooter, moto elétrica e ciclomotor eram três grupos e viraram **um só,
`autopropelido`** — decisão do Caique, definitiva. A troca foi feita direto no
banco e o `supabase-bolin-catalogo.sql` já está igual, então rodar o arquivo de
novo não desfaz mais nada.

O "Quadriciclo" também era um grupo, com o 4 Wheels sozinho dentro. O produto saiu do
catálogo a pedido do Caique e, como a barra vem das tarjas, o botão saiu
junto — não foi preciso mexer em lista de grupo nenhuma.

---

## O banco é o mesmo da Agropecuária JG

Os dois sites dividem o **mesmo projeto Supabase**
(`https://vvasybgcuxiufimnmfxa.supabase.co`), mas não se encostam:

| | Agropecuária JG | BOLIN |
|---|---|---|
| Tabelas | `loja`, `produtos` | `bolin_modelos`, `bolin_conteudo` |
| Fotos (Storage) | balde `produtos` | balde `bolin` |
| Quem pode editar | função `eh_dono()` | função `eh_dono_bolin()` |
| Políticas | `"loja: …"`, `"fotos: …"` | `"bolin modelos: …"`, `"bolin arquivos: …"` |

Cada site tem o seu dono, com e-mail próprio, e um não consegue mexer no
outro. Rodar de novo o SQL de um dos dois **não derruba** as regras do outro
— os nomes das políticas são diferentes de propósito.

O que é realmente compartilhado: a lista de usuários (Authentication é um só
no projeto) e a cota do plano. Se um dia quiser separar de vez, é só criar
outro projeto, rodar o `supabase-bolin.sql` lá e trocar as duas linhas de
URL/chave no topo do segundo `<script>` do HTML.

---

## Ligar (uma vez só, ~5 minutos)

### 1. Escolher o e-mail da administradora
Ela entra no site **só com a senha** — o e-mail fica fixo no código, ela nem
precisa saber dele. Mas o Supabase loga por e-mail, então ele existe em **dois
lugares e os dois têm que bater**:

| Onde | O quê |
|---|---|
| `supabase-bolin.sql` | linha marcada `<<< TROQUE AQUI`, dentro de `eh_dono_bolin()` |
| `index.html` | `var USUARIO_FIXO` |

Hoje os dois estão em `bolinmotoseletricas@gmail.com`. Se mudar, mude nos dois —
senão o cadeado para de abrir.

O e-mail **não precisa existir de verdade** — marcando *Auto Confirm User* na
criação do usuário, o Supabase não manda nenhuma confirmação, só usa aquele texto
como identificador de login. Então dá para montar tudo hoje com um e-mail
provisório e trocar quando a pessoa mandar o dela.

### 2. Criar as tabelas
Painel do Supabase: **SQL Editor** → **New query** → cole o `supabase-bolin.sql`
inteiro → **Run**. Deve aparecer *"Success. No rows returned"*.

### 3. Cadastrar o catálogo
Mesmo caminho, agora com o `supabase-bolin-catalogo.sql`. No fim ele mostra
duas tabelas de conferência: os 35 produtos em ordem e a contagem por grupo.

> ⚠️ Esse arquivo **começa apagando** tudo que estiver em `bolin_modelos`.
> É de propósito: era o jeito de tirar do ar a lista antiga de oito modelos
> (X-13, X-15, X-20, E-10 a E-50), escrita antes de o catálogo de verdade
> chegar. Depois que a cliente começar a mexer no catálogo pelo cadeado,
> rodar esse SQL de novo desfaz o que ela tiver feito.

### 4. Criar o login
**Authentication** → **Users** → **Add user** → **Create new user**:

- E-mail: exatamente o mesmo que você colocou no SQL
- Senha: escolha uma boa senha
- Marque **Auto Confirm User**

Confira também que o auto-cadastro está desligado, senão qualquer um cria conta:
**Authentication** → **Sign In / Providers** → **Email** →
*"Allow new users to sign up"* = **desligado**.

### 5. Trocar o e-mail depois
Troque a linha no SQL **e** o `USUARIO_FIXO` no HTML, rode o
`supabase-bolin.sql` de novo (o `create or replace` só atualiza a função — o
catálogo não é tocado) e crie o novo usuário no painel.

---

## Como ela usa

1. Clica no **cadeado** no canto superior direito e digita a senha
2. **+ Novo modelo** embaixo da lista cria um card em branco
3. Em cima da foto: **+ Adicionar foto** (dá para marcar várias de uma vez; cada
   imagem é reduzida e enviada sozinha). As fotos viram **miniaturas embaixo do
   card** — clicar numa miniatura mostra ela grande. Com a foto escolhida na
   tela: **Capa** faz dela a primeira (a que abre o card) e **Remover** tira só
   aquela foto, não o modelo.
4. Clica em qualquer **texto tracejado** — nome, tarja, texto de venda, e cada
   rótulo e valor da ficha técnica — e reescreve. Ao sair do campo, salva.
5. Na barra de cada card: **↑ ↓** reordena · **+ linha na ficha** acrescenta uma
   linha na tabela · **No site / Escondido** tira do ar sem apagar · **Apagar**
   remove de vez
6. O **×** no fim de cada linha da ficha remove aquela linha
7. Botão **WhatsApp** na barra de baixo muda o número em toda a página
8. **Sair** encerra a sessão

Detalhes úteis:

- A **tarja** é o grupo. Escrever "Scooter" num produto joga ele para o botão
  Scooter; escrever uma palavra nova cria um botão novo.
- No modo edição a **barra de grupos some** e todos os produtos aparecem de
  uma vez, escondidos inclusive. É de propósito: com um grupo escolhido, um
  produto novo (que nasce sem tarja) sumiria da tela na hora de criar.
- O **"Modelos em linha"** lá no topo se conta sozinho: é o número de produtos
  visíveis no catálogo. Se ela reescrever esse número pelo cadeado, o dela passa
  a mandar e a contagem automática para. Para voltar a contar sozinho, é só
  apagar o texto que ela escreveu e deixar o número que veio no arquivo.
- Cada produto tem a **sua** ficha técnica. Uma scooter pode ter "Velocidade" e
  outra "Pneu" — não precisam ter as mesmas linhas.
- Quantas fotos quiser por produto. O visitante só vê a fileira de miniaturas
  quando tem **duas ou mais** — como todo o catálogo veio com duas (o produto e
  a página do fabricante), a fileira aparece em todos.
- Apagar um produto leva junto **todas** as fotos dele do armazenamento —
  as que ela subiu. As que vieram da pasta `catalogo/` continuam no site.
- **Escondido** é melhor que apagar quando o produto vai voltar: sai do site mas
  continua cadastrado, com foto e ficha.
- Tarja vazia simplesmente não aparece no site.
- Tudo é salvo na hora, para todo mundo. Não existe "salvar tudo" no fim.
- **Restaurar original** na barra de baixo apaga o catálogo inteiro e todos os
  textos reescritos. Tem confirmação, mas não tem volta — para recadastrar os
  35 produtos, rode o `supabase-bolin-catalogo.sql` de novo.

---

## Segurança

A chave que está no HTML é a **publishable/anon**, pública de propósito. Quem
protege os dados são as regras RLS do `supabase-bolin.sql`: **qualquer um lê, só
a dona escreve.** Mesmo que alguém force o modo edição pelo navegador, o banco
recusa a gravação sem a conta certa.

> Os textos fixos da página (fora do catálogo) são localizados pela posição do
> elemento no HTML. Depois de uma reforma grande na estrutura da página, textos
> já salvos podem cair no lugar errado — nesse caso use **Restaurar original** e
> refaça. O catálogo não tem esse problema: cada produto é um registro com id.

---

## Fotos que não estão no banco

As 70 fotos do catálogo (duas por produto) moram em `site/catalogo/` e sobem
junto com o site. No banco elas aparecem como `/catalogo/x15.jpg`, com o campo
do balde vazio — ou seja, são arquivo do site, não do Storage.

Duas consequências práticas:

- **Um deploy sem a pasta `catalogo/` deixa o catálogo inteiro sem foto.** Ela
  precisa estar comitada junto com o `index.html`.
- Trocar uma dessas fotos por uma foto de verdade é normal: a cliente usa
  **+ Adicionar foto** no card e depois **Capa**. A partir daí aquela foto passa
  a vir do balde como qualquer outra.

---

## Vídeos

Os três vídeos que a fábrica mandou estão em `site/videos/` (`bolin-1.mp4`,
`bolin-2.mp4`, `bolin-3.mp4`) e a seção **Em movimento** já aparece no site.

Os três estão legendados *"Linha BOLIN na loja"*. Se um dia quiser trocar pelo
nome do modelo que aparece em cada um, as legendas ficam no `index.html`, no
`<h3>` de cada bloco `<article class="filme">`.

Para acrescentar outro vídeo: ponha o `.mp4` em `site/videos/`, copie um dos blocos
e troque o arquivo e o título. Se quiser uma capa, ponha um `.jpg` na mesma
pasta e aponte no `poster` — sem isso o navegador mostra o primeiro quadro.
Apagando os três blocos, a seção some sozinha.

Vale a pena manter cada arquivo abaixo de uns 10 MB. Os três de hoje somam
9,7 MB e o navegador só baixa o começo de cada um — quem não apertar o play
não carrega o vídeo inteiro.

---

## Anunciar no Google

A página já está pronta para receber tráfego pago. O que foi feito para isso:

**`site/privacidade.html`** — política de privacidade. É o item que mais reprova
landing page de captação: sempre que uma página pede dado pessoal e não tem
política, o Google barra o anúncio por "coleta de dados irresponsável", e a LGPD
exige de qualquer jeito. O texto foi escrito em cima do que a página realmente
faz — inclusive a parte mais forte dela, que é o formulário **não guardar nada**:
o navegador monta a mensagem e abre o WhatsApp, sem passar por banco nenhum.

O link para ela fica no fim do rodapé e **não é editável pelo cadeado**, de
propósito: é link obrigatório, não pode sumir num clique sem querer.

**O bloco do Google Ads** fica no último `<script>` do `index.html`. São duas
linhas vazias esperando os códigos:

```js
var ID_GOOGLE_ADS = "";     // ex.: "AW-123456789"
var CONVERSAO = "";         // ex.: "AW-123456789/AbC-D_efGh12ijk"
```

Enquanto estiverem vazias o bloco **não faz absolutamente nada**: não carrega
script do Google, não grava cookie e não mostra barra de aviso. Preenchendo as
duas, três coisas passam a valer sozinhas:

1. a tag do Google carrega;
2. aparece a barra de cookies (a resposta do visitante fica no navegador dele,
   e antes de responder nada de anúncio é gravado — é o modo de consentimento
   do próprio Google);
3. cada vez que alguém abre o WhatsApp, pelo formulário ou por qualquer botão,
   conta uma conversão.

A conversão é disparada no momento em que o WhatsApp **abre de verdade**, não no
clique do botão "enviar" — senão contaria também quem esqueceu de preencher um
campo. Quem faz a ponte é o evento `bolin:whatsapp`, disparado pelo formulário.

**Onde o cliente pega os dois códigos:** o `AW-` fica em Ferramentas > Tags do
Google. O da conversão, em Metas > Conversões > a ação > Tag do Google.

### O que ainda depende do cliente

- **Verificação de identidade do anunciante** no Google Ads (CNPJ e documento).
  É obrigatória e é o que mais atrasa — de dias a semanas. Vale começar antes de
  tudo, porque sem ela o anúncio não roda.
- **Razão social e CNPJ na política de privacidade.** Hoje ela identifica a
  empresa pela marca e pelo WhatsApp, o que basta para publicar. Assim que o
  cliente mandar os dados formais, vale acrescentar no primeiro parágrafo do
  `privacidade.html` — fica mais sólido se algum dia for questionado.

---

## Trocar o servidor: do Netlify para o Cloudflare Pages

**Por que trocar.** O Netlify grátis dá **300 créditos por mês para a equipe
inteira**, e **cada publicação custa ~15**. São ~20 publicações no mês, e isso
antes de contar banda. Em **24/08/2026** os créditos acabaram no meio do
ciclo — 14 publicações da BOLIN somaram 210 créditos, mais 111 de banda — e o
Netlify **pausou o site sozinho**: o endereço passou a responder
`503 {"error":"usage_exceeded"}`. Não foi bug do site, e `git push` não
religa. Se entrar tráfego pago, os 9,3 MB de vídeo derrubam de novo, mais
rápido.

No **Cloudflare Pages** grátis a banda é **ilimitada** e são **500 builds por
mês**. O site continua o mesmo, no mesmo repositório: muda só quem serve.

O `wrangler.toml` já está no repositório e faz lá o que o `netlify.toml` faz
aqui — publicar **só a pasta `site/`**. Falta a parte que só dá para fazer no
painel:

### 1. Criar o projeto no Cloudflare

Em **dash.cloudflare.com → Workers & Pages → Create → Pages → Connect to Git**,
autorizar o GitHub e escolher **CaiqueDelazari/Medley**, branch `main`.

Quando ele perguntar o framework e o comando de build: **nenhum**, campo vazio.
O `wrangler.toml` já responde por isso. Salvar e publicar — em um ou dois
minutos sai um endereço `bolin.pages.dev`.

### 2. Conferir antes de mexer no domínio

Abrir o `bolin.pages.dev` e olhar:

- a página abre e o catálogo carrega (ele vem do Supabase, não do servidor —
  se aparecerem os 35 modelos, está certo);
- os vídeos tocam;
- **`bolin.pages.dev/LEIA-ME.md` tem que dar 404.** Se abrir o arquivo, o
  `wrangler.toml` não foi lido — parar aqui.

Enquanto o domínio não for movido, o site do cliente continua no Netlify,
normal. Dá para levar o tempo que precisar nesta etapa.

### 3. Levar o DNS para o Cloudflare

O domínio está no **registro.br**, na conta do Caique (CADEL187), mas **quem
responde pelo DNS hoje é o próprio Netlify**: os servidores de nome são
`dns1.p09.nsone.net` até `dns4` (NS1, que é o DNS do Netlify), e apex e `www`
apontam os dois para `54.232.119.62`. Não existe **nenhum registro MX nem
TXT** — não há e-mail no domínio, nada a preservar além do site.

Isso importa por um motivo: **apagar o site do Netlify antes de mover os
servidores de nome derruba o domínio inteiro**, não só o site, porque o DNS
mora lá. A ordem abaixo é obrigatória.

Para o `bolinmotoseletricas.com.br` sem `www` apontar para o Pages, o DNS
precisa estar no Cloudflare:

1. **dash.cloudflare.com → Add a site →** `bolinmotoseletricas.com.br`, plano
   **Free**. O Cloudflare varre o DNS atual e copia os registros.
2. Ele mostra **dois servidores de nome** (algo como `xxx.ns.cloudflare.com`).
3. No **registro.br → o domínio → Alterar servidores DNS**, apagar os do
   Netlify e pôr os dois do Cloudflare.
4. Esperar. Costuma valer em minutos, mas o prazo honesto é **até 24 horas**.

> A varredura da etapa 1 só enxerga o que existe **enquanto o Netlify ainda
> estiver de pé** — por isso ela vem antes de qualquer limpeza lá. Como hoje
> só existem o apex e o `www`, e o Pages recria os dois sozinho na etapa 4, na
> prática não há registro nenhum a salvar.

### 4. Ligar o domínio no Pages

No projeto do Pages → **Custom domains → Set up a domain** →
`bolinmotoseletricas.com.br`, e repetir para `www.bolinmotoseletricas.com.br`.
Com o DNS já no Cloudflare ele cria os registros e o certificado sozinho.

### 5. Desligar o Netlify

Só depois do domínio abrindo pelo Cloudflare, e depois de um dia ou dois de
site no ar: no Netlify, remover o domínio do site e apagar o projeto. Aí o
`netlify.toml` pode sair do repositório — até lá ele fica, que é o caminho de
volta se algo der errado.

---

## Publicar

**Publicar é dar `git push`.** O servidor está ligado ao repositório
[CaiqueDelazari/Medley](https://github.com/CaiqueDelazari/Medley) e publica
sozinho a cada push no `main`:

```
git add -A
git commit -m "o que mudou"
git push
```

Em um ou dois minutos o site novo está no ar, no mesmo endereço.

**Publica-se uma vez por push, não uma por commit.** Commitar à vontade na
máquina e dar **um push só no fim da sessão** é o que segura o gasto — foi
picar ajuste pequeno em push separado que estourou o plano do Netlify em
agosto de 2026. No Cloudflare Pages sobra folga (500 builds/mês), mas o hábito
continua valendo.

Não existe arrastar pasta. E não existe mais a pasta `publicar/` — ela era a
cópia que se arrastava, e virou a `site/`.

### Por que `site/` existe

O servidor publicava a raiz do repositório inteira, e por causa disso o SQL e
este LEIA-ME ficaram acessíveis no endereço do site
(`bolinmotoseletricas.com.br/supabase-bolin.sql` abria o arquivo). O
`wrangler.toml` (Cloudflare) e o `netlify.toml` fecham isso apontando a pasta
`site`: **só o que está dentro de `site/` vai para o ar.**

Então, na hora de acrescentar arquivo novo:

- foto, vídeo, página → dentro de `site/`
- SQL, anotação, documentação → na raiz, e nunca será publicado

Vale conferir de vez em quando: abra `bolinmotoseletricas.com.br/LEIA-ME.md`
no navegador. Tem que dar **404**.
