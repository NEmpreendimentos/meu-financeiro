-- Meu Financeiro: schema inicial. Todos os valores monetários usam NUMERIC(14,2).
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  kind text not null default 'both' check (kind in ('income','expense','both')),
  color text,
  created_at timestamptz not null default now(),
  unique(user_id, name)
);
create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  kind text not null default 'checking' check (kind in ('checking','savings','cash','wallet','investment','other')),
  institution text,
  opening_balance numeric(14,2) not null default 0,
  color text default '#087F5B',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  amount numeric(14,2) not null check (amount > 0),
  kind text not null check (kind in ('income','expense')),
  category_id uuid references public.categories(id) on delete set null,
  account_id uuid references public.accounts(id) on delete set null,
  transaction_date date not null default current_date,
  status text not null default 'paid' check (status in ('pending','paid','received')),
  notes text,
  card_purchase_id uuid,
  recurring_rule_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists transactions_user_date_idx on public.transactions(user_id, transaction_date desc);
create index if not exists transactions_user_kind_idx on public.transactions(user_id, kind, status);
create table if not exists public.recurring_rules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  amount numeric(14,2) not null check (amount > 0),
  kind text not null check (kind in ('income','expense')),
  category_id uuid references public.categories(id) on delete set null,
  account_id uuid references public.accounts(id) on delete set null,
  frequency text not null check (frequency in ('weekly','monthly','yearly')),
  next_date date not null,
  active boolean not null default true,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.credit_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  institution text,
  credit_limit numeric(14,2) not null check (credit_limit >= 0),
  closing_day int not null check (closing_day between 1 and 31),
  due_day int not null check (due_day between 1 and 31),
  color text not null default '#087F5B',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.credit_card_invoices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  card_id uuid not null references public.credit_cards(id) on delete cascade,
  due_date date not null,
  status text not null default 'open' check (status in ('open','closed','paid')),
  created_at timestamptz not null default now(),
  unique(card_id, due_date)
);
create index if not exists invoices_user_due_idx on public.credit_card_invoices(user_id, due_date);
create table if not exists public.card_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  card_id uuid not null references public.credit_cards(id) on delete restrict,
  category_id uuid references public.categories(id) on delete set null,
  description text not null,
  total_amount numeric(14,2) not null check (total_amount > 0),
  installment_count int not null check (installment_count between 1 and 120),
  purchase_date date not null,
  first_due_date date not null,
  notes text,
  created_at timestamptz not null default now()
);
create table if not exists public.card_installments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  purchase_id uuid not null references public.card_purchases(id) on delete cascade,
  invoice_id uuid not null references public.credit_card_invoices(id) on delete cascade,
  installment_number int not null,
  amount numeric(14,2) not null check (amount > 0),
  due_date date not null,
  status text not null default 'pending' check (status in ('pending','paid')),
  created_at timestamptz not null default now(),
  unique(purchase_id, installment_number)
);
create index if not exists installments_user_due_idx on public.card_installments(user_id, due_date, status);
create table if not exists public.invoice_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  invoice_id uuid not null references public.credit_card_invoices(id) on delete restrict,
  amount numeric(14,2) not null check (amount > 0),
  paid_at date not null default current_date,
  account_id uuid references public.accounts(id) on delete set null,
  notes text,
  created_at timestamptz not null default now()
);
create unique index if not exists invoice_single_full_payment_idx on public.invoice_payments(invoice_id);

create table if not exists public.debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  creditor text,
  initial_amount numeric(14,2) not null check (initial_amount > 0),
  paid_amount numeric(14,2) not null default 0 check (paid_amount >= 0),
  installment_count int check (installment_count is null or installment_count > 0),
  installment_amount numeric(14,2) check (installment_amount is null or installment_amount > 0),
  next_due_date date,
  interest_rate numeric(7,4),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.debt_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  debt_id uuid not null references public.debts(id) on delete cascade,
  account_id uuid references public.accounts(id) on delete set null,
  amount numeric(14,2) not null check (amount > 0),
  paid_at date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);
create table if not exists public.investments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  institution text,
  invested_amount numeric(14,2) not null default 0 check (invested_amount >= 0),
  invested_at date not null default current_date,
  manual_return_rate numeric(8,4),
  current_value numeric(14,2) not null default 0 check (current_value >= 0),
  accumulated_earnings numeric(14,2) not null default 0,
  notes text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create table if not exists public.investment_movements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  investment_id uuid not null references public.investments(id) on delete cascade,
  account_id uuid references public.accounts(id) on delete set null,
  kind text not null check (kind in ('deposit','withdrawal','valuation')),
  amount numeric(14,2) not null check (amount > 0),
  movement_date date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);
create index if not exists investments_user_idx on public.investments(user_id);

alter table public.transactions add constraint transactions_card_purchase_fk foreign key (card_purchase_id) references public.card_purchases(id) on delete set null;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, full_name) values (new.id, coalesce(new.raw_user_meta_data->>'full_name','')) on conflict (id) do nothing;
  insert into public.categories(user_id,name,kind,color) values
    (new.id,'Alimentação','expense','#D48A37'),(new.id,'Transporte','expense','#5B73C5'),(new.id,'Moradia','expense','#7A5E9B'),
    (new.id,'Lazer','expense','#56959A'),(new.id,'Saúde','expense','#D86C63'),(new.id,'Educação','expense','#A3A33D'),
    (new.id,'Compras','expense','#C26C94'),(new.id,'Salário','income','#087F5B'),(new.id,'Vendas','income','#3B9C78'),
    (new.id,'Investimentos','both','#557DAA'),(new.id,'Outros','both','#7C8794') on conflict (user_id,name) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.register_card_purchase(
  p_card_id uuid, p_description text, p_total numeric, p_installments integer,
  p_purchase_date date, p_first_due_date date, p_category_id uuid default null, p_notes text default null
) returns uuid language plpgsql security invoker set search_path = public as $$
declare
  v_user uuid := auth.uid(); v_purchase uuid := gen_random_uuid(); v_tx uuid; v_invoice uuid;
  v_due date; v_piece numeric(14,2); v_i int; v_due_day int;
begin
  if v_user is null then raise exception 'Autenticação necessária'; end if;
  if p_total <= 0 or p_installments < 1 or p_installments > 120 then raise exception 'Compra ou parcelas inválidas'; end if;
  select due_day into v_due_day from public.credit_cards where id=p_card_id and user_id=v_user for update;
  if not found then raise exception 'Cartão não encontrado'; end if;
  if p_category_id is not null and not exists(select 1 from public.categories where id=p_category_id and user_id=v_user) then raise exception 'Categoria inválida'; end if;
  insert into public.card_purchases(id,user_id,card_id,category_id,description,total_amount,installment_count,purchase_date,first_due_date,notes)
  values(v_purchase,v_user,p_card_id,p_category_id,p_description,p_total,p_installments,p_purchase_date,p_first_due_date,p_notes);
  -- A compra é uma despesa na data da compra; pagar faturas nunca gera outra transação.
  insert into public.transactions(user_id,description,amount,kind,category_id,transaction_date,status,notes,card_purchase_id)
  values(v_user,p_description,p_total,'expense',p_category_id,p_purchase_date,'paid',p_notes,v_purchase) returning id into v_tx;
  v_piece := trunc((p_total / p_installments),2);
  for v_i in 1..p_installments loop
    v_due := (p_first_due_date + ((v_i-1) * interval '1 month'))::date;
    -- Mantém o dia contratado do primeiro vencimento nos meses seguintes.
    v_due := make_date(extract(year from v_due)::int,extract(month from v_due)::int,least(v_due_day,extract(day from (date_trunc('month',v_due) + interval '1 month - 1 day'))::int));
    insert into public.credit_card_invoices(user_id,card_id,due_date,status)
    values(v_user,p_card_id,v_due,'open') on conflict(card_id,due_date) do update set status=public.credit_card_invoices.status returning id into v_invoice;
    insert into public.card_installments(user_id,purchase_id,invoice_id,installment_number,amount,due_date)
    values(v_user,v_purchase,v_invoice,v_i,case when v_i=p_installments then p_total-v_piece*(p_installments-1) else v_piece end,v_due);
  end loop;
  return v_purchase;
end; $$;

create or replace function public.pay_card_invoice(p_invoice_id uuid,p_account_id uuid default null,p_paid_at date default current_date,p_notes text default null)
returns void language plpgsql security invoker set search_path = public as $$
declare v_user uuid := auth.uid(); v_invoice public.credit_card_invoices%rowtype; v_total numeric(14,2); v_paid numeric(14,2);
begin
  if v_user is null then raise exception 'Autenticação necessária'; end if;
  select * into v_invoice from public.credit_card_invoices where id=p_invoice_id and user_id=v_user for update;
  if not found then raise exception 'Fatura não encontrada'; end if;
  if v_invoice.status='paid' then raise exception 'Fatura já está paga'; end if;
  if p_account_id is not null and not exists(select 1 from public.accounts where id=p_account_id and user_id=v_user) then raise exception 'Conta inválida'; end if;
  select coalesce(sum(amount),0) into v_total from public.card_installments where invoice_id=p_invoice_id and user_id=v_user;
  select coalesce(sum(amount),0) into v_paid from public.invoice_payments where invoice_id=p_invoice_id and user_id=v_user;
  if v_total-v_paid <= 0 then raise exception 'Fatura sem saldo pendente'; end if;
  -- Liquidação de passivo, sem criar transaction (despesa duplicada).
  insert into public.invoice_payments(user_id,invoice_id,amount,paid_at,account_id,notes) values(v_user,p_invoice_id,v_total-v_paid,p_paid_at,p_account_id,p_notes);
  update public.credit_card_invoices set status='paid' where id=p_invoice_id;
  update public.card_installments set status='paid' where invoice_id=p_invoice_id and user_id=v_user;
end; $$;

create or replace function public.register_debt_payment(p_debt_id uuid,p_amount numeric,p_account_id uuid default null,p_paid_at date default current_date,p_notes text default null)
returns uuid language plpgsql security invoker set search_path = public as $$
declare v_user uuid := auth.uid(); v_id uuid := gen_random_uuid(); v_initial numeric; v_paid numeric;
begin
  select initial_amount,paid_amount into v_initial,v_paid from public.debts where id=p_debt_id and user_id=v_user for update;
  if not found then raise exception 'Dívida não encontrada'; end if;
  if p_amount<=0 or p_amount>v_initial-v_paid then raise exception 'Valor de pagamento excede o saldo'; end if;
  if p_account_id is not null and not exists(select 1 from public.accounts where id=p_account_id and user_id=v_user) then raise exception 'Conta inválida'; end if;
  insert into public.debt_payments(id,user_id,debt_id,account_id,amount,paid_at,notes) values(v_id,v_user,p_debt_id,p_account_id,p_amount,p_paid_at,p_notes);
  update public.debts set paid_amount=paid_amount+p_amount, updated_at=now() where id=p_debt_id;
  return v_id;
end; $$;

create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
create trigger profiles_updated before update on public.profiles for each row execute procedure public.set_updated_at();
create trigger accounts_updated before update on public.accounts for each row execute procedure public.set_updated_at();
create trigger cards_updated before update on public.credit_cards for each row execute procedure public.set_updated_at();
create trigger debts_updated before update on public.debts for each row execute procedure public.set_updated_at();
create trigger investments_updated before update on public.investments for each row execute procedure public.set_updated_at();

-- Isolamento por usuário em todas as entidades financeiras. Views/functions não substituem RLS.
do $$ declare t text; begin
  foreach t in array array['profiles','categories','accounts','transactions','recurring_rules','credit_cards','credit_card_invoices','card_purchases','card_installments','invoice_payments','debts','debt_payments','investments','investment_movements'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists owner_all on public.%I', t);
    if t='profiles' then
      execute 'create policy owner_all on public.profiles for all using (id=auth.uid()) with check (id=auth.uid())';
    else
      execute format('create policy owner_all on public.%I for all using (user_id=auth.uid()) with check (user_id=auth.uid())', t);
    end if;
  end loop;
end $$;

grant usage on schema public to authenticated;
grant select,insert,update,delete on all tables in schema public to authenticated;
grant execute on function public.register_card_purchase(uuid,text,numeric,integer,date,date,uuid,text) to authenticated;
grant execute on function public.pay_card_invoice(uuid,uuid,date,text) to authenticated;
grant execute on function public.register_debt_payment(uuid,numeric,uuid,date,text) to authenticated;


-- Registros de patrimônio são snapshots explícitos; não inventamos histórico/cotações.
create table if not exists public.net_worth_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  as_of_date date not null,
  cash_balance numeric(14,2) not null,
  investments_value numeric(14,2) not null,
  debt_value numeric(14,2) not null,
  card_due numeric(14,2) not null,
  net_worth numeric(14,2) not null,
  created_at timestamptz not null default now(),
  unique(user_id, as_of_date)
);
create index if not exists snapshots_user_date_idx on public.net_worth_snapshots(user_id,as_of_date desc);
alter table public.net_worth_snapshots enable row level security;
drop policy if exists owner_all on public.net_worth_snapshots;
create policy owner_all on public.net_worth_snapshots for all using (user_id=auth.uid()) with check (user_id=auth.uid());
grant select,insert,update,delete on public.net_worth_snapshots to authenticated;


-- Ao inserir pela sessão autenticada, o banco define o proprietário; RLS continua validando auth.uid().
do $$ declare t text; begin
  foreach t in array array['categories','accounts','transactions','recurring_rules','credit_cards','credit_card_invoices','card_purchases','card_installments','invoice_payments','debts','debt_payments','investments','investment_movements','net_worth_snapshots'] loop
    execute format('alter table public.%I alter column user_id set default auth.uid()',t);
  end loop;
end $$;

-- Saldo de caixa é afetado por transações e liquidações/transferências vinculadas a uma conta,
-- mas pagamentos de fatura, pagamento de dívida e aportes não viram despesa duplicada.
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

-- Materialização idempotente no primeiro carregamento autenticado, sem precisar de job externo.
alter table public.transactions add column recurring_occurrence_date date;
create unique index recurring_occurrence_unique on public.transactions(recurring_rule_id,recurring_occurrence_date) where recurring_rule_id is not null and recurring_occurrence_date is not null;
create or replace function public.process_recurring_rules()
returns integer language plpgsql security invoker set search_path=public as $$
declare r public.recurring_rules%rowtype; v_date date; v_count integer:=0; v_steps integer;
begin
 if auth.uid() is null then raise exception 'Autenticação necessária'; end if;
 for r in select * from public.recurring_rules where user_id=auth.uid() and active and next_date<=current_date for update loop
   v_date:=r.next_date; v_steps:=0;
   while v_date<=current_date and v_steps<120 loop
     insert into public.transactions(user_id,description,amount,kind,category_id,account_id,transaction_date,status,notes,recurring_rule_id,recurring_occurrence_date)
     values(r.user_id,r.description,r.amount,r.kind,r.category_id,r.account_id,v_date,'pending',r.notes,r.id,v_date)
     on conflict(recurring_rule_id,recurring_occurrence_date) where recurring_rule_id is not null and recurring_occurrence_date is not null do nothing;
     if found then v_count:=v_count+1; end if;
     v_date:=case r.frequency when 'weekly' then v_date+7 when 'monthly' then (v_date+interval '1 month')::date else (v_date+interval '1 year')::date end;
     v_steps:=v_steps+1;
   end loop;
   update public.recurring_rules set next_date=v_date where id=r.id;
 end loop;
 return v_count;
end; $$;
revoke all on function public.process_recurring_rules() from public;
grant execute on function public.process_recurring_rules() to authenticated;

-- Impede referências a contas/categorias de outro usuário mesmo se um UUID externo for conhecido.
create or replace function public.enforce_user_owned_references() returns trigger language plpgsql security invoker set search_path=public as $$
begin
 if tg_table_name='transactions' then
   if new.account_id is not null and not exists(select 1 from public.accounts where id=new.account_id and user_id=new.user_id) then raise exception 'Conta não pertence a este usuário'; end if;
   if new.category_id is not null and not exists(select 1 from public.categories where id=new.category_id and user_id=new.user_id) then raise exception 'Categoria não pertence a este usuário'; end if;
   if new.card_purchase_id is not null and not exists(select 1 from public.card_purchases where id=new.card_purchase_id and user_id=new.user_id) then raise exception 'Compra não pertence a este usuário'; end if;
   if new.recurring_rule_id is not null and not exists(select 1 from public.recurring_rules where id=new.recurring_rule_id and user_id=new.user_id) then raise exception 'Regra não pertence a este usuário'; end if;
 elsif tg_table_name='recurring_rules' then
   if new.account_id is not null and not exists(select 1 from public.accounts where id=new.account_id and user_id=new.user_id) then raise exception 'Conta não pertence a este usuário'; end if;
   if new.category_id is not null and not exists(select 1 from public.categories where id=new.category_id and user_id=new.user_id) then raise exception 'Categoria não pertence a este usuário'; end if;
 elsif tg_table_name='investment_movements' then
   if not exists(select 1 from public.investments where id=new.investment_id and user_id=new.user_id) then raise exception 'Investimento não pertence a este usuário'; end if;
   if new.account_id is not null and not exists(select 1 from public.accounts where id=new.account_id and user_id=new.user_id) then raise exception 'Conta não pertence a este usuário'; end if;
 end if;
 return new;
end; $$;
drop trigger if exists transactions_owner_refs on public.transactions;
create trigger transactions_owner_refs before insert or update on public.transactions for each row execute procedure public.enforce_user_owned_references();
drop trigger if exists recurring_owner_refs on public.recurring_rules;
create trigger recurring_owner_refs before insert or update on public.recurring_rules for each row execute procedure public.enforce_user_owned_references();
drop trigger if exists investment_movement_owner_refs on public.investment_movements;
create trigger investment_movement_owner_refs before insert or update on public.investment_movements for each row execute procedure public.enforce_user_owned_references();
