# BOLIN Electric Motor — página de captação + catálogo

Página única de atacado (`bolin-lead-page.html`). A seção **Linha BOLIN** é um
catálogo de verdade: a administradora entra com e-mail e senha e cria, edita,
reordena, esconde e apaga modelos — cada um com **várias fotos**, tarja, texto
de venda e ficha técnica própria. O que ela salva vai para o banco e aparece na
hora para quem abrir o site.

## Arquivos

| Arquivo | O que é |
|---|---|
| `bolin-lead-page.html` | A página inteira (visual, catálogo, formulário e área de edição) |
| `supabase-bolin.sql` | Estrutura do banco — roda uma vez no Supabase |
| `Logo (2).jpeg` | Logo da marca |

Os três modelos escritos no HTML são **reserva**: aparecem só enquanto o banco
estiver vazio ou fora do ar. No instante em que existir um modelo cadastrado, a
lista inteira passa a vir do banco.

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

Cada site tem o seu dono, com e-mail próprio, e um não consegue mexer no outro.
Rodar de novo o SQL de um dos dois **não derruba** as regras do outro — os nomes
das políticas são diferentes de propósito.

O que é realmente compartilhado: a lista de usuários (Authentication é um só no
projeto) e a cota do plano. Se um dia quiser separar de vez, é só criar outro
projeto, rodar o `supabase-bolin.sql` lá e trocar as duas linhas de URL/chave no
topo do segundo `<script>` do HTML.

---

## Ligar (uma vez só, ~5 minutos)

### 1. Escolher o e-mail da administradora
Ela entra no site **só com a senha** — o e-mail fica fixo no código, ela nem
precisa saber dele. Mas o Supabase loga por e-mail, então ele existe em **dois
lugares e os dois têm que bater**:

| Onde | O quê |
|---|---|
| `supabase-bolin.sql` | linha marcada `<<< TROQUE AQUI`, dentro de `eh_dono_bolin()` |
| `bolin-lead-page.html` | `var USUARIO_FIXO` |

Hoje os dois estão em `bolinmotoseletricas@gmail.com`. Se mudar, mude nos dois —
senão o cadeado para de abrir.

O e-mail **não precisa existir de verdade** — marcando *Auto Confirm User* na
criação do usuário, o Supabase não manda nenhuma confirmação, só usa aquele texto
como identificador de login. Então dá para montar tudo hoje com um e-mail
provisório e trocar quando a pessoa mandar o dela.

### 2. Criar as tabelas
Painel do Supabase: **SQL Editor** → **New query** → cole o `supabase-bolin.sql`
inteiro → **Run**. Deve aparecer *"Success. No rows returned"*.

### 3. Criar o login
**Authentication** → **Users** → **Add user** → **Create new user**:

- E-mail: exatamente o mesmo que você colocou no SQL
- Senha: escolha uma boa senha
- Marque **Auto Confirm User**

Confira também que o auto-cadastro está desligado, senão qualquer um cria conta:
**Authentication** → **Sign In / Providers** → **Email** →
*"Allow new users to sign up"* = **desligado**.

### 4. Trocar o e-mail depois
Troque a linha no SQL **e** o `USUARIO_FIXO` no HTML, rode o arquivo de novo (o
`create or replace` só atualiza a função — o catálogo já cadastrado não é tocado)
e crie o novo usuário no painel.

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

- Cada modelo tem a **sua** ficha técnica. Uma scooter pode ter "Velocidade" e
  outra "Pneu" — não precisam ter as mesmas linhas.
- Quantas fotos quiser por modelo. O visitante só vê a fileira de miniaturas
  quando tem **duas ou mais**; com uma foto só, o card fica igual a antes. No
  modo edição as miniaturas aparecem sempre, para dar onde clicar.
- Apagar um modelo leva junto **todas** as fotos dele do armazenamento.
- **Escondido** é melhor que apagar quando o modelo vai voltar: sai do site mas
  continua cadastrado, com foto e ficha.
- Tarja vazia simplesmente não aparece no site.
- Tudo é salvo na hora, para todo mundo. Não existe "salvar tudo" no fim.
- **Restaurar original** na barra de baixo apaga o catálogo inteiro e todos os
  textos reescritos. Tem confirmação, mas não tem volta.

---

## Segurança

A chave que está no HTML é a **publishable/anon**, pública de propósito. Quem
protege os dados são as regras RLS do `supabase-bolin.sql`: **qualquer um lê, só
a dona escreve.** Mesmo que alguém force o modo edição pelo navegador, o banco
recusa a gravação sem a conta certa.

> Os textos fixos da página (fora do catálogo) são localizados pela posição do
> elemento no HTML. Depois de uma reforma grande na estrutura da página, textos
> já salvos podem cair no lugar errado — nesse caso use **Restaurar original** e
> refaça. O catálogo não tem esse problema: cada modelo é um registro com id.

---

## Publicar

Arraste a pasta para [Netlify Drop](https://app.netlify.com/drop) — ou Vercel,
Cloudflare Pages, GitHub Pages. A página é um arquivo só; o banco continua o
mesmo de qualquer lugar que ela seja aberta.
