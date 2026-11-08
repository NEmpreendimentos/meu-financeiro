-- Contas do tipo investimento são ativos; nenhum movimento ligado a elas deve integrar o caixa disponível.
create or replace function public.get_cash_balance_before(p_as_of_date date)
returns numeric language sql stable security invoker set search_path=public as $$
 select coalesce((select sum(a.opening_balance) from public.accounts a where a.user_id=auth.uid() and a.kind<>'investment'),0)
 +coalesce((select sum(case when t.kind='income' then t.amount else -t.amount end) from public.transactions t where t.user_id=auth.uid() and t.account_id is not null and t.status<>'pending' and t.transaction_date<p_as_of_date and exists(select 1 from public.accounts a where a.id=t.account_id and a.user_id=auth.uid() and a.kind<>'investment')),0)
 -coalesce((select sum(p.amount) from public.invoice_payments p where p.user_id=auth.uid() and p.account_id is not null and p.paid_at<p_as_of_date and exists(select 1 from public.accounts a where a.id=p.account_id and a.user_id=auth.uid() and a.kind<>'investment')),0)
 -coalesce((select sum(p.amount) from public.debt_payments p where p.user_id=auth.uid() and p.account_id is not null and p.paid_at<p_as_of_date and exists(select 1 from public.accounts a where a.id=p.account_id and a.user_id=auth.uid() and a.kind<>'investment')),0)
 +coalesce((select sum(case when m.kind='withdrawal' then m.amount when m.kind='deposit' then -m.amount else 0 end) from public.investment_movements m where m.user_id=auth.uid() and m.account_id is not null and m.movement_date<p_as_of_date and exists(select 1 from public.accounts a where a.id=m.account_id and a.user_id=auth.uid() and a.kind<>'investment')),0)
$$;
revoke all on function public.get_cash_balance_before(date) from public;
grant execute on function public.get_cash_balance_before(date) to authenticated;
