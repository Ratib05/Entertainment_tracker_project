-- Supabase schema for Entertainment Tracker
-- Based on the project plan: users, entertainment, library, reviews, lists, friends, activities

create extension if not exists "pgcrypto";

-- Domain enums
create type public.media_type as enum ('film', 'show', 'game');
create type public.watch_status as enum ('watchlist', 'watching', 'watched');
create type public.friendship_status as enum ('pending', 'accepted', 'blocked');
create type public.activity_type as enum (
  'library_add',
  'library_update',
  'library_remove',
  'review_create',
  'review_update',
  'review_delete',
  'list_create',
  'list_update',
  'list_item_add',
  'list_item_remove'
);

-- User profile table for app-specific metadata
create table public.profiles (
  id uuid not null primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Entertainment catalog table (movies, TV shows, games, etc.)
create table public.entertainment (
  id uuid not null primary key default gen_random_uuid(),
  external_id text,
  external_source text,
  title text not null,
  type public.media_type not null,
  summary text,
  poster_url text,
  release_date date,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- User library entries for tracking status and personal notes
create table public.library_entries (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  status public.watch_status not null default 'watchlist',
  rating int check (rating between 1 and 5),
  note text default '',
  season int,
  logged_at timestamptz not null default now(),
  watched_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, entertainment_id)
);

-- Reviews written by users for specific entertainment items
create table public.reviews (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  title text,
  body text,
  rating int check (rating between 1 and 5),
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, entertainment_id)
);

-- Custom lists created by users
create table public.custom_lists (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Items inside a custom list
create table public.list_items (
  id uuid not null primary key default gen_random_uuid(),
  list_id uuid not null references public.custom_lists(id) on delete cascade,
  entertainment_id uuid not null references public.entertainment(id) on delete cascade,
  notes text,
  position int default 0,
  added_at timestamptz not null default now(),
  unique (list_id, entertainment_id)
);

-- Future social / friends feature
create table public.friends (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  friend_id uuid not null references auth.users(id) on delete cascade,
  status public.friendship_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, friend_id)
);

-- Future activity feed table
create table public.activities (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type public.activity_type not null,
  payload jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Row-level security policies for authenticated access
alter table public.profiles enable row level security;
create policy "Profiles: owner can manage own profile"
  on public.profiles for all
  using (id = auth.uid())
  with check (id = auth.uid());

alter table public.entertainment enable row level security;
create policy "Entertainment: public read access"
  on public.entertainment for select
  using (true);
create policy "Entertainment: no writes via anon"
  on public.entertainment for insert, update, delete
  using (false);

alter table public.library_entries enable row level security;
create policy "Library entries: owner can select own entries"
  on public.library_entries for select
  using (user_id = auth.uid());
create policy "Library entries: owner can insert own entries"
  on public.library_entries for insert
  with check (user_id = auth.uid());
create policy "Library entries: owner can update own entries"
  on public.library_entries for update
  using (user_id = auth.uid());
create policy "Library entries: owner can delete own entries"
  on public.library_entries for delete
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

alter table public.custom_lists enable row level security;
create policy "Lists: owner can select own lists"
  on public.custom_lists for select
  using (user_id = auth.uid());
create policy "Lists: owner can insert own lists"
  on public.custom_lists for insert
  with check (user_id = auth.uid());
create policy "Lists: owner can update own lists"
  on public.custom_lists for update
  using (user_id = auth.uid());
create policy "Lists: owner can delete own lists"
  on public.custom_lists for delete
  using (user_id = auth.uid());

alter table public.list_items enable row level security;
create policy "List items: owner can select items in own lists"
  on public.list_items for select
  using (exists (
    select 1 from public.custom_lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can insert items in own lists"
  on public.list_items for insert
  with check (exists (
    select 1 from public.custom_lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can update items in own lists"
  on public.list_items for update
  using (exists (
    select 1 from public.custom_lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));
create policy "List items: owner can delete items in own lists"
  on public.list_items for delete
  using (exists (
    select 1 from public.custom_lists l
    where l.id = list_id and l.user_id = auth.uid()
  ));

alter table public.friends enable row level security;
create policy "Friends: owner can manage own relationship"
  on public.friends for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

alter table public.activities enable row level security;
create policy "Activities: owner can manage own activities"
  on public.activities for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
