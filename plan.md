# Plano — Meu Financeiro

## Escopo e arquitetura

Construir um aplicativo web responsivo em Next.js App Router com TypeScript e Tailwind CSS, usando Supabase PostgreSQL para persistência e Supabase Auth para cadastro, login, recuperação de senha e sessão. O Vercel será o alvo de publicação, condicionado à conexão autorizada da conta e configuração dos segredos. Nenhuma chave será commitada. O banco terá migrations SQL versionadas, ownership por `user_id`, RLS habilitada em todas as tabelas privadas e políticas que limitam operações ao usuário autenticado.

A interface será em português brasileiro, com moeda em BRL e datas DD/MM/AAAA. O dashboard terá filtros por intervalo e agregações feitas a partir dos dados persistidos; usuários sem dados verão estados vazios honestos, nunca saldos ou cotações fictícias. Componentes de domínio serão separados para lançamentos, contas, cartões/faturas/parcelas, dívidas, investimentos e relatórios. Os gráficos serão alimentados por consultas/transformações reais. Exportações usarão CSV gerado no cliente e PDF via impressão/exportação do relatório, sem envio dos dados financeiros a terceiros.

### Regras contábeis e de domínio

- Compra no cartão é despesa na data da compra e impacta a fatura/limite; pagar a fatura liquida uma obrigação e não cria uma segunda despesa.
- Compra parcelada gera ocorrências mensais para as faturas respectivas e agenda de compromissos futuros. Total das parcelas deve fechar com o total da compra, com ajuste determinístico de centavos na última parcela.
- Investimentos não recebem cotações/rentabilidades inventadas; valor atual e rendimentos podem ser atualizados manualmente.
- Cada registro financeiro tem `user_id`; consultas UI são complementares às políticas RLS no banco.

## Estrutura principal

- `src/app/`: rotas App Router para autenticação e páginas privadas (dashboard, lançamentos, cartões, dívidas, investimentos e relatórios).
- `src/components/`: shell responsivo, navegação, cards, formulários, tabelas e gráficos.
- `src/lib/supabase/`: clientes server/browser, middleware de sessão e helpers de autorização.
- `src/lib/finance/`: cálculos BRL, intervalos, parcelas, agregações e exportação.
- `src/lib/validations/`: esquemas tipados para entrada e validação.
- `supabase/migrations/`: esquema PostgreSQL, triggers e políticas RLS.
- `public/manus-routes.json`: manifesto de rotas do site.
- `.env.example`: nomes/URLs esperados, sem valores secretos.

## Design

Três estilos considerados: (1) Fintech editorial, com cartões de saldo em alto contraste e hierarquia tipográfica de revista financeira. Probabilidade: 0,04. (2) Neo-banco pastel, com superfícies claras e gradientes suaves. Probabilidade: 0,07. (3) Terminal de mercado escuro, com painéis densos e cores de cotação. Probabilidade: 0,09.

### Estilo escolhido — Fintech editorial

- **Movimento de design:** Swiss/International Typographic Style reinterpretado para um painel financeiro pessoal contemporâneo.
- **Princípios centrais:** clareza antes de decoração; hierarquia editorial para valores; densidade equilibrada; acessibilidade em todos os estados.
- **Filosofia de cor:** marfim e cinza-grafite formam uma base calma e confiável; verde-esmeralda marca saúde financeira/ações positivas, âmbar sinaliza atenção e vermelho fica reservado a saídas e alertas.
- **Paradigma de layout:** navegação lateral persistente no desktop e barra inferior adaptada a celular; área de conteúdo assimétrica, com saldo e fluxo em destaque e trilhas de compromissos ao lado.
- **Elementos de assinatura:** faixa esmeralda fina para o saldo principal; etiquetas de categoria com tons discretos; divisórias finas e numerais tabulares.
- **Interação:** filtros e ações mantêm contexto; formulários validam junto ao campo; ações destrutivas pedem confirmação e oferecem feedback claro.
- **Animação:** transições curtas de 140–220 ms em hover/foco e abertura de menus; contagem de valores é opcional e respeita `prefers-reduced-motion`; sem animação que atrase leitura.
- **Tipografia:** Manrope para interface/títulos e Geist Mono para valores tabulares; títulos 28–36 px, métricas principais 32–40 px, corpo 14–16 px, rótulos 11–12 px.
- **Essência da marca:** controle financeiro diário que transforma dados pessoais em decisões claras; personalidade: lúcida, discreta, confiável.
- **Voz:** direta e acolhedora, sem alarmismo. Exemplos: “Seu mês, em perspectiva.” e “Tudo que entra e sai, no lugar certo.”
- **Wordmark/logo:** monograma geométrico “MF” formado por duas colunas ascendentes e uma linha de saldo, acompanhado do nome em caixa baixa.
- **Cor de assinatura:** esmeralda profundo `#087F5B`.

## Dependências e limites operacionais

O clone inicial confirmou que o repositório GitHub especificado existe, está acessível e continha apenas `README.md`. Os arquivos do app já estão no clone; o commit/push ainda está pendente. O projeto Supabase `meu-financeiro` foi criado na região de São Paulo, as duas migrations estão aplicadas e as tabelas privadas estão com RLS; os advisors de segurança não retornam alertas. A URL e a chave publicável estão apenas em `.env.local`, que o Git ignora. A conexão Vercel está autenticada, mas não lista equipes e ainda não consegue acessar a equipe autorizada; será necessário concluir o consentimento do escopo antes do deploy. O teste ponta a ponta de cadastro, login e persistência exige usuário real e será feito depois da publicação, sem inventar dados financeiros.
