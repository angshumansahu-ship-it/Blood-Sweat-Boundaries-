-- Blood, Sweat & Boundaries — proposed Supabase/Postgres schema
-- Apply only after creating a Supabase project and reviewing RLS policies.

create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table public.leagues (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Blood, Sweat & Boundaries',
  invite_code text not null unique,
  owner_id uuid not null references public.profiles(id),
  is_private boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.league_members (
  league_id uuid not null references public.leagues(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','admin','member')),
  joined_at timestamptz not null default now(),
  primary key (league_id,user_id)
);

create table public.tournaments (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.leagues(id) on delete cascade,
  name text not null,
  format text not null default 'T20',
  status text not null default 'draft' check (status in ('draft','upcoming','active','completed')),
  starts_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  name text not null,
  short_name text
);

create table public.players (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  external_player_id text,
  team_id uuid references public.teams(id) on delete set null,
  name text not null,
  role text not null check (role in ('Batter','Bowler','All-rounder','Wicketkeeper')),
  is_active boolean not null default true,
  unique (tournament_id, external_player_id)
);

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  external_match_id text,
  home_team_id uuid references public.teams(id),
  away_team_id uuid references public.teams(id),
  starts_at timestamptz not null,
  status text not null default 'scheduled',
  locked_at timestamptz,
  unique (tournament_id, external_match_id)
);

create table public.squads (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (tournament_id,user_id)
);

create table public.squad_players (
  squad_id uuid not null references public.squads(id) on delete cascade,
  player_id uuid not null references public.players(id),
  primary key (squad_id,player_id)
);

create table public.match_lineups (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  captain_player_id uuid not null references public.players(id),
  vice_captain_player_id uuid not null references public.players(id),
  submitted_at timestamptz not null default now(),
  unique (match_id,user_id),
  check (captain_player_id <> vice_captain_player_id)
);

create table public.match_lineup_players (
  lineup_id uuid not null references public.match_lineups(id) on delete cascade,
  player_id uuid not null references public.players(id),
  primary key (lineup_id,player_id)
);

create table public.player_match_stats (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  player_id uuid not null references public.players(id),
  runs integer not null default 0,
  balls_faced integer not null default 0,
  fours integer not null default 0,
  sixes integer not null default 0,
  wickets integer not null default 0,
  overs_bowled numeric(5,1) not null default 0,
  runs_conceded integer not null default 0,
  maidens integer not null default 0,
  catches integer not null default 0,
  run_outs integer not null default 0,
  stumpings integer not null default 0,
  bowled_lbw_wickets integer not null default 0,
  player_of_match boolean not null default false,
  source_payload jsonb,
  updated_at timestamptz not null default now(),
  unique (match_id,player_id)
);

create table public.scoring_rule_sets (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  version integer not null,
  rules jsonb not null,
  active boolean not null default false,
  created_at timestamptz not null default now(),
  unique (tournament_id,version)
);

create table public.fantasy_scores (
  match_id uuid not null references public.matches(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  points numeric(10,2) not null default 0,
  breakdown jsonb not null default '{}'::jsonb,
  calculated_at timestamptz not null default now(),
  primary key (match_id,user_id)
);

-- Before production: enable RLS on every table and add policies so users can
-- read only leagues they belong to, write only their own squad/lineup, and
-- mutate tournaments/player pools/matches only as league admins.
