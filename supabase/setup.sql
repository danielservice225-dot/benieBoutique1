-- Bénie Boutique : configuration Supabase pour le catalogue et l'espace vendeur
-- À exécuter UNE FOIS dans Supabase > SQL Editor > New query.
-- Ce script supprime volontairement tous les produits de démonstration existants.
-- Les commandes, elles, sont conservées.

create extension if not exists pgcrypto;

create table if not exists public.products (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.sellers (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text,
  customer_phone text,
  customer_email text,
  items jsonb not null default '[]'::jsonb,
  total_fcfa numeric(12,0) not null default 0,
  status text not null default 'pending',
  payment_status text not null default 'unpaid'
);

alter table public.products enable row level security;
alter table public.sellers enable row level security;
alter table public.orders enable row level security;

create or replace function public.is_benie_seller()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.sellers s
    where s.user_id = auth.uid() and s.active = true
  );
$$;

revoke all on function public.is_benie_seller() from public;
grant execute on function public.is_benie_seller() to anon, authenticated;

drop policy if exists "Public can read products" on public.products;
create policy "Public can read products" on public.products
for select to anon, authenticated using (true);

drop policy if exists "Sellers can insert products" on public.products;
create policy "Sellers can insert products" on public.products
for insert to authenticated with check (public.is_benie_seller());

drop policy if exists "Sellers can update products" on public.products;
create policy "Sellers can update products" on public.products
for update to authenticated using (public.is_benie_seller()) with check (public.is_benie_seller());

drop policy if exists "Sellers can delete products" on public.products;
create policy "Sellers can delete products" on public.products
for delete to authenticated using (public.is_benie_seller());

drop policy if exists "Sellers can read seller list" on public.sellers;
create policy "Sellers can read seller list" on public.sellers
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Public can create orders" on public.orders;
create policy "Public can create orders" on public.orders
for insert to anon, authenticated with check (true);

drop policy if exists "Sellers can read orders" on public.orders;
create policy "Sellers can read orders" on public.orders
for select to authenticated using (public.is_benie_seller());

drop policy if exists "Sellers can update orders" on public.orders;
create policy "Sellers can update orders" on public.orders
for update to authenticated using (public.is_benie_seller()) with check (public.is_benie_seller());

drop policy if exists "Sellers can delete orders" on public.orders;
create policy "Sellers can delete orders" on public.orders
for delete to authenticated using (public.is_benie_seller());

grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
grant select on public.sellers to authenticated;
grant select, insert, update, delete on public.orders to authenticated;
grant insert on public.orders to anon;

-- Nettoyage demandé : retire tous les anciens produits fictifs du catalogue.
delete from public.products;

-- ÉTAPE SUIVANTE :
-- 1) Créez un utilisateur dans Authentication > Users (ou utilisez celui déjà créé).
-- 2) Copiez son UUID et exécutez :
-- insert into public.sellers(user_id,email,active)
-- values ('COLLER-ICI-UUID-AUTH-USER', 'votre-email@example.com', true)
-- on conflict (user_id) do update set email=excluded.email, active=true;
