-- =====================================================================
-- UPI Guardian - Transaction History
-- Run this whole file once in your Supabase project's SQL Editor
-- (Project -> SQL Editor -> New query -> paste -> Run)
-- =====================================================================

-- 1. Table -------------------------------------------------------------
create table if not exists public.transactions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references auth.users (id) on delete cascade,
  payee_name      text not null,
  upi_id          text not null,
  amount          numeric(12, 2) not null,
  direction       text not null default 'sent' check (direction in ('sent', 'received')),
  category        text not null default 'other',       -- shopping, person, bill, food, transfer, other...
  risk_level      text not null default 'low' check (risk_level in ('low', 'medium', 'high')),
  status          text not null default 'success' check (status in ('success', 'pending', 'failed')),
  note            text,
  created_at      timestamptz not null default now()
);

-- Keep the newest transactions fast to query
create index if not exists transactions_created_at_idx
  on public.transactions (created_at desc);

create index if not exists transactions_user_id_idx
  on public.transactions (user_id);

-- 2. Row Level Security --------------------------------------------------
alter table public.transactions enable row level security;

-- Option A (recommended once login is wired up with Supabase Auth):
-- each signed-in user can only see / add / remove their own transactions.
drop policy if exists "Users can view own transactions" on public.transactions;
create policy "Users can view own transactions"
  on public.transactions for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own transactions" on public.transactions;
create policy "Users can insert own transactions"
  on public.transactions for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own transactions" on public.transactions;
create policy "Users can update own transactions"
  on public.transactions for update
  using (auth.uid() = user_id);

drop policy if exists "Users can delete own transactions" on public.transactions;
create policy "Users can delete own transactions"
  on public.transactions for delete
  using (auth.uid() = user_id);

-- Option B (demo / no-auth mode):
-- UPI Guardian's login page isn't wired to Supabase Auth yet, so by
-- default nobody would be able to read/write anything (policies above
-- all require auth.uid()). Uncomment the block below ONLY while you're
-- prototyping without real logins, then delete it once auth is in place
-- -- it makes every row public to anyone with your anon key.
--
-- drop policy if exists "Public demo access" on public.transactions;
-- create policy "Public demo access"
--   on public.transactions for all
--   using (true)
--   with check (true);

-- 3. Sample data (optional) ---------------------------------------------
-- Only useful while Option B is active, or after you've signed in and
-- swapped in your own user_id. Safe to delete this whole block.
--
-- insert into public.transactions (payee_name, upi_id, amount, direction, category, risk_level, note)
-- values
--   ('Amazon India', 'amazon@apl', 950,   'sent', 'shopping', 'low',  'Order #12345'),
--   ('Rahul Kumar',  'rahul123@upi', 500, 'sent', 'person',   'low',  null),
--   ('Unknown Receiver', 'xyz123@upi', 50000, 'sent', 'other', 'high', 'First-time receiver, unusually large amount'),
--   ('Flipkart', 'flipkart@apl', 1299, 'sent', 'shopping', 'low', null),
--   ('Sister', 'sister@upi', 2000, 'sent', 'person', 'low', null);
