# Entregas e critérios

Status: `[ ]` pendente · `[x]` implementado/configurado; validação real descrita quando ainda necessária.

## 1. Repositório GitHub e entrega
- [x] Desenvolver o projeto no repositório `https://github.com/NEmpreendimentos/meu-financeiro`.
- [x] Verificar conteúdo atual antes das alterações; preservar arquivos importantes; não alterar nenhum outro repositório. Evidência: clone limpo, só continha `README.md`.
- [ ] Criar commit descritivo e enviar o código ao repositório informado.
- [ ] Ao concluir, entregar link do GitHub, tecnologias utilizadas, funcionalidades concluídas, instruções de acesso/configuração e pendências que dependam de ação do usuário.

## 2. Arquitetura, segurança e publicação
- [x] Usar Next.js com TypeScript, Tailwind CSS, Supabase PostgreSQL, Supabase Auth, Vercel e gráficos interativos.
- [x] Persistir dados financeiros no Supabase; o app não depende de armazenamento somente no navegador. O schema, as quatro migrations e RLS estão aplicados; a validação com uma conta real ainda depende de cadastro/teste E2E.
- [x] Implementar RLS por `user_id` para que cada usuário só consiga acessar os próprios dados; não expor dados financeiros publicamente. Os advisors de segurança retornaram sem alertas após os ajustes.
- [ ] Publicar um sistema funcionando, não só protótipo/layout; variáveis locais estão seguras, mas deploy e variáveis de ambiente Vercel ainda dependem do acesso à equipe autorizada.
- [x] Configurar banco Supabase, aplicar migrations e políticas de segurança. [ ] Fazer deploy na Vercel, testar o site publicado e corrigir erros observados.
- [x] Implementar cadastro, login, recuperação de senha, sessão persistente e proteção das páginas privadas. [ ] Testar o fluxo ponta a ponta com um usuário real.
- [ ] Entregar link público do site somente quando a publicação tiver sido confirmada.

## 3. Dashboard e visualizações
- [x] Apresentar saldo total disponível; dinheiro em contas e carteiras; total de receitas e despesas do período; total investido; valor das dívidas; patrimônio líquido; despesas futuras; faturas pendentes; próximos vencimentos.
- [x] Exibir gráficos interativos de receitas versus despesas; evolução do patrimônio (snapshots manuais); gastos por categoria; evolução mensal do saldo; distribuição dos investimentos.
- [x] Incluir filtros por mês, ano e período personalizado.

## 4. Receitas, despesas e categorias
- [x] Permitir cadastrar, editar, excluir e consultar lançamentos.
- [x] Cada lançamento inclui descrição, valor, categoria, data, tipo, conta utilizada, observações e status de pagamento quando aplicável.
- [x] Permitir categorias personalizáveis, incluindo Alimentação, Transporte, Moradia, Lazer, Saúde, Educação, Compras, Salário, Vendas, Investimentos e Outros.
- [x] Permitir receitas e despesas recorrentes; regras são salvas e podem ser ativadas/pausadas, e o app materializa lançamentos pendentes vencidos ao abrir o dashboard.

## 5. Cartões de crédito e faturas
- [x] Permitir cadastrar vários cartões; cada cartão possui nome, banco/instituição, limite total, utilizado/disponível, fechamento, vencimento e identificação visual.
- [x] Cada cartão possui controle de faturas próprio, com status aberta, fechada ou paga.
- [x] Permitir registrar compras/parceladas, fechar e pagar faturas, acompanhar limite, consultar compras e parcelas futuras.
- [x] Contabilizar uma compra como despesa na data da compra, e não novamente quando a fatura for paga.
- [x] Registrar o pagamento como liquidação da obrigação, sem duplicar despesas nos relatórios.

## 6. Compras parceladas
- [x] Selecionar cartão, valor total, quantidade de parcelas, data de compra e primeiro vencimento.
- [x] Distribuir automaticamente as parcelas nas faturas correspondentes e ajustar os centavos na última parcela.
- [x] Criar agenda de compromissos futuros mostrando o total comprometido.
- [x] Consultar parcelas restantes, total restante e compras parceladas por cartão.

## 7. Dívidas e empréstimos
- [x] Criar área específica para dívidas e empréstimos.
- [x] Registrar nome, valor inicial, valor pago/restante, parcelas, vencimentos, juros, credor e observações.
- [x] Apresentar histórico de pagamentos e saldo atualizado; vincular opcionalmente a conta para refletir saída de caixa sem despesa duplicada.

## 8. Investimentos
- [x] Registrar nome, instituição, valor investido, data, rentabilidade, valor atual, rendimentos e resgates.
- [x] Apresentar capital investido, rendimentos e evolução do patrimônio em snapshots manuais.
- [x] Não inventar cotações/rentabilidades; valores são informados pelo usuário e movimentos podem apontar a conta usada.

## 9. Relatórios mensais
- [x] Criar relatórios com seleção de mês e ano.
- [x] Apresentar saldo inicial de caixa real, receitas, despesas, resultado, aportes, resgates, dívidas pagas, compras no cartão, parcelas futuras, despesas por categoria, comparação e evolução patrimonial.
- [x] Exportar em CSV e PDF via impressão do navegador.
- [x] Resumo visual com indicadores e gráficos.

## 10. Design e experiência
- [x] Visual fintech premium, moderno, minimalista e profissional.
- [x] Menu lateral no computador, navegação adaptada a celular, tema claro/escuro.
- [x] Gráficos interativos, cards, ícones consistentes e animações discretas.
- [x] Valores em real (R$) e datas brasileiras.
- [x] Interface em português brasileiro, responsiva para celular e desktop.

## 11. Autenticação, persistência e proteção
- [x] Implementar cadastro, login, logout, recuperação de senha e sessão persistente.
- [x] Usar banco de dados em nuvem, proteger páginas privadas e assegurar que dados financeiros não sejam expostos publicamente.

## 12. Critérios finais
- [ ] Código enviado ao GitHub; banco configurado; login e persistência validados com usuário real; lançamentos, cartões, parcelamentos e relatórios testados; pagamento de fatura sem duplicação; site publicado e acessível por link público.
- [x] Não inventar credenciais; usar apenas a chave publicável do Supabase e nunca enviar `service_role` ao cliente ou ao Git.
