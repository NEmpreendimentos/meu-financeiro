# Meu Financeiro

Aplicativo de controle financeiro pessoal em Next.js, TypeScript e Tailwind CSS, com Supabase PostgreSQL/Auth e gráficos interativos. Os registros pertencem ao usuário autenticado e são protegidos por Row Level Security (RLS). Compras no cartão são despesas na data da compra; pagar a fatura liquida a obrigação sem adicionar outra despesa. Pagamentos de faturas e dívidas, aportes e resgates podem indicar a conta usada e movimentar o caixa sem duplicação. Rentabilidade e saldo de investimentos são informados manualmente.

## Infraestrutura

- Repositório: [NEmpreendimentos/meu-financeiro](https://github.com/NEmpreendimentos/meu-financeiro)
- Supabase provisionado: projeto `meu-financeiro` em São Paulo; as migrations e RLS foram aplicadas.
- Vercel: deploy do repositório está pendente da autorização do escopo da equipe `nakamura7` nesta conexão.

## Configuração local

1. Instale Node.js e execute `npm install`.
2. Copie `.env.example` para `.env.local`.
3. Preencha `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY` com a URL e a chave **publicável** do projeto Supabase. Não use `service_role` no navegador e não faça commit de `.env.local`.
4. Execute `npm run dev` e abra `http://localhost:3000`.

O arquivo `.env.local` está no `.gitignore`. A chave publicável identifica o projeto, mas as políticas RLS continuam sendo a barreira de acesso dos dados.

## Banco de dados

As migrations estão em `supabase/migrations/` e devem ser aplicadas em ordem cronológica:

1. `20261108000000_finance_core.sql` — tabelas, funções de domínio, RLS, Auth, snapshots e recorrências.
2. `20261108000100_security_performance.sql` — índices, políticas RLS otimizadas e restrição da função interna de Auth.
3. `20261108000200_exclude_investment_accounts_from_cash.sql` — exclui contas de investimento do caixa disponível.
4. `20261108000300_investment_account_cash_activity.sql` — também exclui movimentações ligadas a essas contas para evitar dupla contagem patrimonial.

Todas já foram aplicadas ao projeto Supabase associado. Ao criar outro projeto, aplique-as em ordem e confira os advisors de segurança antes de usar.

## Autenticação em produção

Após o deploy, configure no painel Supabase Auth a URL pública de produção como **Site URL** e adicione às Redirect URLs `http://localhost:3000/**` e `https://<domínio-vercel>/**`. A rota de callback do app é `/auth/callback`. A confirmação por e-mail pode ser habilitada no provedor de e-mail Supabase.

## Validação

- `npm run typecheck`
- `npm run lint`
- `npm run build`

A integração de login/persistência ainda precisa de teste ponta a ponta com uma conta real; não há dados financeiros de demonstração nem saldos fictícios.
