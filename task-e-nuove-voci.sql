insert into public.voci (giorno, inizio, fine, area, team, categoria, location, attivita, responsabile, fornitore, materiali, lingua, stato, note) values
('2026-10-24','19:45','23:00','Other','Logistica','Other','LIBRARY','Weroad shop','','','','Multi','Da confermare','Dal database aggiornato'),
('2026-10-25','14:30','15:30','Workshop & Activity','ScuolaZoo','Workshop & Activity','SOMBRERO BAR - OUTDOOR DECK','Jungle Speed Game','Staff ScuolaZoo','','Giochi in scatola, Carte','Multi','Confermato','Dal database aggiornato'),
('2026-10-25','23:00','02:00','Entertainment','','Entertainment','LIBRARY','Photo point','','','','Multi','Da confermare','Dal database aggiornato'),
('2026-10-26','14:30','15:15','Other','','Other','CARD ROOM','Private Meeting Mattia Riva','','','Tv HDMI','Multi','Confermato','Dal database aggiornato'),
('2026-10-26','16:30','17:45','Other','','Other','CARD ROOM','Private Meeting Mattia Riva','','','Tv HDMI','Multi','Confermato','Dal database aggiornato');

create table if not exists public.task (
  id uuid primary key default gen_random_uuid(),
  giorno date not null,
  testo text not null,
  chi text not null default '',
  fatto boolean not null default false,
  ordine int not null default 0,
  created_at timestamptz not null default now(),
  updated_by text not null default ''
);
alter table public.task enable row level security;
drop policy if exists "task legge" on public.task;
drop policy if exists "task scrive" on public.task;
drop policy if exists "task modifica" on public.task;
drop policy if exists "task elimina" on public.task;
create policy "task legge" on public.task for select to authenticated using (true);
create policy "task scrive" on public.task for insert to authenticated with check (public.mio_ruolo() in ('admin','campi'));
create policy "task modifica" on public.task for update to authenticated using (public.mio_ruolo() in ('admin','campi')) with check (public.mio_ruolo() in ('admin','campi'));
create policy "task elimina" on public.task for delete to authenticated using (public.mio_ruolo() in ('admin','campi'));
do $$ begin alter publication supabase_realtime add table public.task; exception when duplicate_object then null; end $$;

select giorno, count(*) from public.voci group by 1 order by 1;
