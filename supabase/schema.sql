-- Supabase schema for Entertainment Tracker
-- Updated to match the requested table structure

create extension if not exists "pgcrypto";

-- Domain enums
create type public.media_type as enum ('film', 'show', 'game');
create type public.watch_status as enum ('watchlist', 'watching', 'watched');

-- Users
create table public.users (
  id uuid not null primary key default gen_random_uuid(),
  username text unique,
  email text not null unique,
  avatar_url text,
  created_at timestamptz not null default now()
);

-- Entertainment
create table public.entertainment (
  id uuid not null primary key default gen_random_uuid(),
  external_id text,
  title text not null,
  type public.media_type not null,
  description text,
  poster text,
  release_date date,
  genres text[] not null default '{}'::text[],
  developer text,
  studio text,
  rating numeric(3,2)
);

-- User library
create table public.user_library (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  status public.watch_status not null default 'watchlist',
  started_at timestamptz,
  completed_at timestamptz,
  progress int not null default 0,
  hours_played numeric(6,2) not null default 0
);

-- Reviews
create table public.reviews (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  rating int check (rating between 1 and 5),
  review text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Lists
create table public.lists (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  description text,
  created_at timestamptz not null default now()
);

-- List Items
create table public.list_items (
  list_id uuid not null references public.lists(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  order_index int not null default 0,
  primary key (list_id, entertainment_id)
);

-- Row-level security policies
alter table public.users enable row level security;
create policy "Users: owner can select own user row"
  on public.users for select
  using (id = auth.uid());
create policy "Users: owner can insert own user row"
  on public.users for insert
  with check (id = auth.uid());
create policy "Users: owner can update own user row"
  on public.users for update
  using (id = auth.uid());
create policy "Users: owner can delete own user row"
  on public.users for delete
  using (id = auth.uid());

alter table public.entertainment enable row level security;
create policy "Entertainment: public read access"
  on public.entertainment for select
  using (true);
create policy "Entertainment: no writes via anon"
  on public.entertainment for insert, update, delete
  using (false);

alter table public.user_library enable row level security;
create policy "User library: owner can select own rows"
  on public.user_library for select
  using (user_id = auth.uid());
create policy "User library: owner can insert own rows"
  on public.user_library for insert
  with check (user_id = auth.uid());
create policy "User library: owner can update own rows"
  on public.user_library for update
  using (user_id = auth.uid());
create policy "User library: owner can delete own rows"
  on public.user_library for delete
  using (user_id = auth.uid());

alter table public.reviews enable row level security;
create policy "Reviews: owner can select own reviews"
  on public.reviews for select
  using (user_id = auth.uid());
create policy "Reviews: owner can insert own reviews"
  on public.reviews for insert
  with check (user_id = auth.uid());
create policy "Reviews: owner can update own reviews"
  on public.reviews for update
  using (user_id = auth.uid());
create policy "Reviews: owner can delete own reviews"
  on public.reviews for delete
  using (user_id = auth.uid());

alter table public.lists enable row level security;
create policy "Lists: owner can select own lists"
  on public.lists for select
  using (user_id = auth.uid());
create policy "Lists: owner can insert own lists"
  on public.lists for insert
  with check (user_id = auth.uid());
create policy "Lists: owner can update own lists"
  on public.lists for update
  using (user_id = auth.uid());
create policy "Lists: owner can delete own lists"
  on public.lists for delete
  using (user_id = auth.uid());

alter table public.list_items enable row level security;
create policy "List items: owner can select items in own lists"
  on public.list_items for select
  using (exists (
    select 1 from public.lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can insert items in own lists"
  on public.list_items for insert
  with check (exists (
    select 1 from public.lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can update items in own lists"
  on public.list_items for update
  using (exists (
    select 1 from public.lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can delete items in own lists"
  on public.list_items for delete
  using (exists (
    select 1 from public.lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
