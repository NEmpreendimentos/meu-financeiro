-- Contas do tipo investimento são ativos, não caixa disponível; a posição correspondente é registrada em investments.
create or replace function public.get_cash_balance_before(p_as_of_date date)
returns numeric language sql stable security invoker set search_path=public as $$
 select coalesce((select sum(opening_balance) from public.accounts where user_id=auth.uid() and kind<>'investment'),0)
 +coalesce((select sum(case when kind='income' then amount else -amount end) from public.transactions where user_id=auth.uid() and account_id is not null and status<>'pending' and transaction_date<p_as_of_date),0)
 -coalesce((select sum(amount) from public.invoice_payments where user_id=auth.uid() and account_id is not null and paid_at<p_as_of_date),0)
 -coalesce((select sum(amount) from public.debt_payments where user_id=auth.uid() and account_id is not null and paid_at<p_as_of_date),0)
 +coalesce((select sum(case when kind='withdrawal' then amount when kind='deposit' then -amount else 0 end) from public.investment_movements where user_id=auth.uid() and account_id is not null and movement_date<p_as_of_date),0)
$$;
revoke all on function public.get_cash_balance_before(date) from public;
grant execute on function public.get_cash_balance_before(date) to authenticated;
