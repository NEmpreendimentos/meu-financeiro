-- Revisão pós-migration: índices em FKs, políticas com initplan e função interna do trigger de Auth.
create index if not exists accounts_user_id_idx on public.accounts(user_id);
create index if not exists transactions_account_id_idx on public.transactions(account_id);
create index if not exists transactions_card_purchase_id_idx on public.transactions(card_purchase_id);
create index if not exists transactions_category_id_idx on public.transactions(category_id);
create index if not exists recurring_rules_user_id_idx on public.recurring_rules(user_id);
create index if not exists recurring_rules_account_id_idx on public.recurring_rules(account_id);
create index if not exists recurring_rules_category_id_idx on public.recurring_rules(category_id);
create index if not exists credit_cards_user_id_idx on public.credit_cards(user_id);
create index if not exists card_purchases_user_id_idx on public.card_purchases(user_id);
create index if not exists card_purchases_card_id_idx on public.card_purchases(card_id);
create index if not exists card_purchases_category_id_idx on public.card_purchases(category_id);
create index if not exists card_installments_invoice_id_idx on public.card_installments(invoice_id);
create index if not exists invoice_payments_user_paid_idx on public.invoice_payments(user_id,paid_at);
create index if not exists invoice_payments_account_id_idx on public.invoice_payments(account_id);
create index if not exists debt_payments_user_paid_idx on public.debt_payments(user_id,paid_at);
create index if not exists debt_payments_debt_id_idx on public.debt_payments(debt_id);
create index if not exists debt_payments_account_id_idx on public.debt_payments(account_id);
create index if not exists debts_user_id_idx on public.debts(user_id);
create index if not exists investment_movements_user_date_idx on public.investment_movements(user_id,movement_date);
create index if not exists investment_movements_investment_id_idx on public.investment_movements(investment_id);
create index if not exists investment_movements_account_id_idx on public.investment_movements(account_id);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path=public as $$
begin new.updated_at=now(); return new; end; $$;
revoke all on function public.handle_new_user() from public,anon,authenticated;

do $$ declare t text;begin
 foreach t in array array['profiles','categories','accounts','transactions','recurring_rules','credit_cards','credit_card_invoices','card_purchases','card_installments','invoice_payments','debts','debt_payments','investments','investment_movements','net_worth_snapshots'] loop
  execute format('drop policy if exists owner_all on public.%I',t);
  if t='profiles' then
   execute 'create policy owner_all on public.profiles for all using (id=(select auth.uid())) with check (id=(select auth.uid()))';
  else
   execute format('create policy owner_all on public.%I for all using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()))',t);
  end if;
 end loop;
end $$;
