-- =====================================================================
-- PIANO DI PRODUZIONE GR26 · schema Supabase
-- Incolla tutto in Supabase → SQL Editor → New query → Run.
-- Si può rilanciare senza rischi: non duplica né cancella i dati.
-- =====================================================================

create table if not exists public.voci (
  id            uuid primary key default gen_random_uuid(),
  giorno        date not null,
  inizio        text not null,                 -- 'HH:MM'
  fine          text not null default '',      -- 'HH:MM'
  area          text not null,                 -- Service, ScuolaZoo, Logistica...
  categoria     text not null default '',      -- categoria del palinsesto
  location      text not null default '',
  attivita      text not null,
  responsabile  text not null default '',
  fornitore     text not null default '',
  materiali     text not null default '',
  materiali_ok  boolean not null default false,
  lingua        text not null default '',
  stato         text not null default 'Da confermare',
  note          text not null default '',
  updated_at    timestamptz not null default now(),
  updated_by    text not null default ''
);

create index if not exists voci_giorno_inizio_idx on public.voci (giorno, inizio);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_voci_touch on public.voci;
create trigger trg_voci_touch before update on public.voci
  for each row execute function public.touch_updated_at();

-- Sicurezza: solo chi ha fatto il login (utenti creati da te) legge e modifica.
alter table public.voci enable row level security;

drop policy if exists "team legge" on public.voci;
drop policy if exists "team inserisce" on public.voci;
drop policy if exists "team modifica" on public.voci;
drop policy if exists "team elimina" on public.voci;
create policy "team legge"      on public.voci for select to authenticated using (true);
create policy "team inserisce"  on public.voci for insert to authenticated with check (true);
create policy "team modifica"   on public.voci for update to authenticated using (true) with check (true);
create policy "team elimina"    on public.voci for delete to authenticated using (true);

-- Aggiornamenti in tempo reale sui telefoni di tutti
do $$
begin
  alter publication supabase_realtime add table public.voci;
exception when duplicate_object then null;
end $$;

-- Dati iniziali: le 122 voci del palinsesto GRW26 (24-27 ottobre).
-- Vengono caricati solo se la tabella è ancora vuota.
insert into public.voci (giorno, inizio, fine, area, categoria, location, attivita, responsabile, fornitore, materiali, lingua, stato, note)
select s.giorno::date, s.inizio, s.fine, s.area, s.categoria, s.location, s.attivita, s.responsabile, s.fornitore, s.materiali, s.lingua, s.stato, s.note
from (values
  ('2026-10-24', '11:00', '18:00', 'Logistica', 'Operation', 'VALENCIA TERMINAL', 'Check in Terminal', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '11:00', '18:00', 'Logistica', 'Operation', 'RECEPTION', 'Check-In & Info Point', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '11:00', '18:00', 'Logistica', 'Other', 'LIBRARY', 'Weroad shop by Vibes', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '11:30', '18:00', 'Service', 'Entertainment', 'ACAPULCO - OUTDOOR DECK', 'Meeting point', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-24', '16:30', '18:30', 'Service', 'Plenary', 'CALA BLANCA - OUTDOOR DECK', 'Venue Set - Up', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '18:30', '20:00', 'Service', 'Plenary', 'CALA BLANCA - OUTDOOR DECK', 'Global Welcome Meeting', 'Paky', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '19:45', '21:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 1', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '21:15', '22:30', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 2', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '20:00', '22:00', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Dinner - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '20:00', '00:00', 'Logistica', 'Operation', 'WEROAD INFO DESK', 'WR Info Point', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '22:30', '00:00', 'ScuolaZoo', 'Workshop & Activity', 'SPORT CENTER (LEFT SIDE) - MINIGOLF', 'Minigolf', 'Staff ScuolaZoo', '', 'Mazze, palline', 'Multi', 'Da confermare', ''),
  ('2026-10-24', '22:30', '00:00', 'ScuolaZoo', 'Workshop & Activity', 'SPORT CENTER', 'Basketball Shooting Competition', 'Staff ScuolaZoo', '', '2 Pallone basket', 'Multi', 'Da confermare', ''),
  ('2026-10-24', '23:15', '00:00', 'Logistica', 'Other', 'THEATRE', 'Plenaria Italia Rehearse', 'Sandro, Paky, Vantraxx + Staff', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-24', '22:30', '01:30', 'Service', 'Entertainment', 'CALA BLANCA - OUTDOOR DECK', 'Opening Night', 'Giubal', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '01:00', '03:00', 'Service', 'Entertainment', 'SAVANNAH', 'Opening Night - AfterParty', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-24', '01:00', '04:00', 'Service', 'Entertainment', 'DISCO', 'Opening Night - AfterParty', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '07:30', '10:00', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '07:30', '08:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER', 'Morning Stretching', '', '', '50 Tappetini, Cassa a batteria', 'Multi', 'Confermato', ''),
  ('2026-10-25', '08:00', '10:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '08:30', '09:15', 'Service', 'Venue Setup', 'SHAKER LOUNGE', 'Venue Set - Up', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '08:30', '10:00', 'Service', 'Venue Setup', 'THEATRE', 'Opening Theatre & final Rehearse', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '09:00', '10:30', 'Service', 'Entertainment', 'SOMBRERO BAR - OUTDOOR DECK', 'Morning Club', 'Perry', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '09:30', '10:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Yoga', 'Mamen Moreno', '', '35 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '09:00', '09:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (SOLARIUM BACK) - OUTDOOR DECK', 'WeTrain – Workout', 'Emanuel Di Giacinto', '', '40 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '09:15', '10:30', 'Service', 'Plenary', 'SHAKER LOUNGE', 'Plenaria WE', 'Giubal', '', '', 'DE', 'Confermato', ''),
  ('2026-10-25', '10:00', '11:30', 'Service', 'Plenary', 'THEATRE', 'Plenaria ITA', 'Paky - Vantraxx', '', '', 'ITA', 'Confermato', ''),
  ('2026-10-25', '10:00', '12:00', 'ScuolaZoo', 'Workshop & Activity', 'GAME AREA', 'Ping Pong Torunament', 'Staff ScuolaZoo', '', '4 Racchette, 5 Palline ping pong', 'Multi', 'Confermato', ''),
  ('2026-10-25', '10:00', '12:00', 'ScuolaZoo', 'Workshop & Activity', 'GAME AREA', 'Table Soccer Tournament', 'Staff ScuolaZoo', '', 'Palline biliardino', 'Multi', 'Confermato', ''),
  ('2026-10-25', '10:45', '11:45', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'Life Coaching', 'Ariane Paraskevopoulos', '', '', 'ENG', 'Da confermare', ''),
  ('2026-10-25', '10:45', '11:45', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER', 'Basket', 'Samer Muhandes', '', '2 Pallone basket', 'ENG', 'Confermato', ''),
  ('2026-10-25', '11:00', '13:00', 'Service', 'Entertainment', 'ACAPULCO - OUTDOOR DECK', 'Chilling Point', 'Perry', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '10:30', '11:45', 'Service', 'Plenary', 'SHAKER LOUNGE', 'Plenaria FR', 'Giubal', '', '', 'FR', 'Confermato', ''),
  ('2026-10-25', '11:45', '13:00', 'Service', 'Plenary', 'THEATRE', 'Plenaria ES', 'Paky', '', '', 'ES', 'Confermato', ''),
  ('2026-10-25', '10:30', '11:15', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Pilates', 'Antonia Hirsch', '', '35 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '12:00', '13:00', 'ScuolaZoo', 'Workshop & Activity', 'SPORT CENTER', 'Football tournament 5vs5', 'Staff ScuolaZoo', '', 'Pallone calcio', 'Multi', 'Confermato', ''),
  ('2026-10-25', '10:30', '11:30', 'ScuolaZoo', 'Workshop & Activity', 'SOMBRERO BAR - OUTDOOR DECK', 'Community Games', 'Staff ScuolaZoo', '', 'Giochi in scatola, Carte', 'ENG', 'Confermato', ''),
  ('2026-10-25', '12:00', '13:00', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (SOLARIUM BACK) - OUTDOOR DECK', 'CrossFit', 'Federico Lettieri', '', 'Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '12:00', '13:00', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Morning Stretching', '', '', '35 Tappetini, Cassa a batteria', 'Multi', 'Confermato', ''),
  ('2026-10-25', '12:30', '18:30', 'ScuolaZoo', 'Operation', 'WEROAD INFO DESK', 'WR Info Point', 'Staff ScuolaZoo', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '12:30', '14:30', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Lunch - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '13:15', '14:30', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Lunch - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '13:15', '14:30', 'Food & Beverage', 'Food & Beverage', 'L''IBISCUS RESTAURANT', 'Team WR Lunch', 'Perry', '', '', 'Multi', 'Confermato', 'Menu a tavola'),
  ('2026-10-25', '12:00', '13:15', 'Service', 'Plenary', 'SHAKER LOUNGE', 'Plenaria DE', 'Giubal', '', '', 'ENG', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'MEETING ROOM', 'Content Creation & Social Media', 'Matteo Tavanti', '', 'Proiettore', 'ITA', 'Da confermare', ''),
  ('2026-10-25', '14:15', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'DISCO', 'Theatrical improvisation', 'Fabio Leonardi', '', '', 'ENG', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (SOLARIUM BACK) - OUTDOOR DECK', 'Natural Therapies & Massage Hacks', 'Claudia Gavardi', '', '30 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Pilates', 'Antonia Hirsch', '', '35 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '14:30', '16:00', 'ScuolaZoo', 'Workshop & Activity', 'SPORT CENTER', 'Football tournament 5vs5', 'Staff ScuolaZoo', '', 'Palla calcetto', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '16:30', 'ScuolaZoo', 'Workshop & Activity', 'GAME AREA', 'Ping Pong Torunament', 'Staff ScuolaZoo', '', '4 Racchette, 5 Palline ping pong', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '16:30', 'ScuolaZoo', 'Workshop & Activity', 'GAME AREA', 'Table Soccer Tournament', 'Staff ScuolaZoo', '', 'Palline biliardino', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '17:30', 'ScuolaZoo', 'Workshop & Activity', 'SPORT CENTER (LEFT SIDE) - MINIGOLF', 'Mini golf', 'Staff ScuolaZoo', '', 'Mazze, palline', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:15', 'Workshop & Activity', 'Workshop & Activity', 'ACAPULCO - OUTDOOR DECK', 'Acqua Dance Gym', 'Marie Coville', '', 'Archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'Feelings, Unfiltered', 'Sarah America', '', 'Proiettore, Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'SOMBRERO BAR - OUTDOOR DECK', 'Meet-Up Zone', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'SHAKER LOUNGE', 'From day one to the IRL movement…', 'Paolo + Erika + Fabio / Staff', '', 'Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:30', 'Workshop & Activity', 'Workshop & Activity', 'MEETING ROOM', 'Personal Storytelling', 'Erik Eklund', '', 'Proiettore, Carta, Penne', 'ENG', 'Da confermare', ''),
  ('2026-10-25', '15:15', '16:00', 'Workshop & Activity', 'Workshop & Activity', 'ACAPULCO - OUTDOOR DECK', 'Dominican Bachata', 'Valentina Colombo + Eloisa d''Ermilio', '', 'Archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:15', 'Workshop & Activity', 'Workshop & Activity', 'DISCO', 'Reggaeton', 'Mattea Di Nunno Matarrese', '', 'Archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Acroyoga', 'Giulia Mantovani', '', '35 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:30', 'ScuolaZoo', 'Workshop & Activity', 'SOMBRERO BAR - OUTDOOR DECK', 'Community Games', 'Staff ScuolaZoo', '', 'Giochi in scatola, Carte', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:00', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (SOLARIUM BACK) - OUTDOOR DECK', 'WeTrain Workout', 'Emanuel Di Giacinto', '', '40 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:15', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'Meet WeRoad''s newest communities [private welcome]', 'Giusy · coreani, americani e travel tribe (20 pax)', '', 'Proiettore, Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '16:15', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'Scouters 2027, your first meetup on board [private welcome]', 'Giusy', '', 'Proiettore, Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:30', 'Workshop & Activity', 'Workshop & Activity', 'SHAKER LOUNGE', 'WeRoad goes USA: inside our American…', 'Dan + Paolo', '', 'Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '14:30', '15:30', 'Workshop & Activity', 'Workshop & Activity', 'THEATRE', 'Behind WeMeet: create events that bring people together', 'Lampe & Stacc + moderatore (A&C Lead/Simone?)', '', 'Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '15:30', '16:30', 'Workshop & Activity', 'Workshop & Activity', 'THEATRE', 'WeRoad X & Passion lead trips: who builds the trips of tomorrow', 'Lampe, Vale, Mautino + moderatore (A&C lead/TP?)', '', 'Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '16:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'ACAPULCO - OUTDOOR DECK', 'Sensual Bachata', 'Alessandro Sepali + Grazia Cipri', '', 'Archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '16:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER', 'Basket Tournament', 'Samer Muhandes', '', '2 Palle da Basket', 'ENG', 'Confermato', ''),
  ('2026-10-25', '16:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (SOLARIUM BACK) - OUTDOOR DECK', 'CrossFit', 'Federico Lettieri', '', 'Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '16:30', '17:30', 'Workshop & Activity', 'Workshop & Activity', 'SHAKER LOUNGE', 'New Cool Sh*t: help us build the coordination tools', 'Ivan + Danilo', '', 'Giraslide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '16:15', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'DISCO', 'Commercial Dance', 'Natalia Divar Conde', '', 'Archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '15:00', '15:45', 'Workshop & Activity', 'Workshop & Activity', 'FUSION RESTAURANT AREA', 'Laughter Yoga', 'Alessio Taglioni', '', 'Cassa a batteria e archetto', 'ENG', 'Da confermare', ''),
  ('2026-10-25', '16:30', '17:30', 'Workshop & Activity', 'Workshop & Activity', 'SPORT CENTER (RIGHT SIDE) - OUTDOOR DECK', 'Yoga', 'Mamen Moreno', '', '35 Tappetini, Cassa a batteria e archetto', 'ENG', 'Confermato', ''),
  ('2026-10-25', '16:30', '18:00', 'Workshop & Activity', 'Workshop & Activity', 'GYM', 'Gym Session - No Host', 'Senza host', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '17:00', '17:45', 'Workshop & Activity', 'Workshop & Activity', 'DISCO', 'Zumba', 'Amena Nour', '', 'Archetto, Adattatori audio', 'ENG', 'Confermato', ''),
  ('2026-10-25', '17:30', '18:30', 'Workshop & Activity', 'Workshop & Activity', 'SHAKER LOUNGE', 'New Cool Sh*t: WeWallet & web check-in', 'Matteo Risso', '', 'Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '17:00', '18:00', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'New Cool Sh*t: a first look at WeRoad Loyalty', 'Marika', '', 'Proiettore, Gira Slide', 'Multi', 'Confermato', ''),
  ('2026-10-25', '15:45', '16:45', 'Workshop & Activity', 'Workshop & Activity', 'FUSION RESTAURANT AREA', 'Set yourself free', 'Dana Flügel', '', 'Cassa a batteria, Spazio chiuso', 'ENG', 'Da confermare', ''),
  ('2026-10-25', '17:45', '18:30', 'Workshop & Activity', 'Workshop & Activity', 'DISCO', 'Fitness Dance', 'Kaz - Khalid- Afzal', '', 'Archetto, Adattatori audio', 'ENG', 'Confermato', ''),
  ('2026-10-25', '18:00', '20:00', 'Service', 'Entertainment', 'ACAPULCO - OUTDOOR DECK', 'Happy Hour', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-25', '20:00', '23:00', 'ScuolaZoo', 'Operation', 'WEROAD INFO DESK', 'WR Info Point', 'Staff ScuolaZoo', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '19:45', '21:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 1 1920''s Dressed', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '20:00', '20:45', 'Service', 'Entertainment', 'THEATRE', 'MSC Theatre Show', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '21:15', '22:30', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 2 1920''s Dressed', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '20:00', '22:00', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Dinner - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '22:00', '22:45', 'Service', 'Entertainment', 'THEATRE', 'MSC Theatre Show', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '23:30', '03:00', 'Service', 'Entertainment', 'SAVANNAH', '1920s Night', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '23:00', '04:00', 'Service', 'Entertainment', 'DISCO', '1920s Night', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '23:30', '03:00', 'Service', 'Entertainment', 'AMBER', '1920s Night', '', '', '', 'Multi', 'Annullato', ''),
  ('2026-10-25', '23:00', '02:00', 'Service', 'Entertainment', 'CARD ROOM', 'Secret Meeting Zone', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '23:00', '02:00', 'Service', 'Entertainment', 'FUSION RESTAURANT AREA', 'Secret Meeting Zone', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-25', '23:00', '02:00', 'Service', 'Entertainment', 'MEETING ROOM', 'TBD', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '07:30', '10:00', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '08:00', '10:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '08:00', '12:00', 'Logistica', 'Operation', 'WEROAD INFO DESK', 'WR Info Point', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '10:00', '10:15', 'Service', 'Venue Setup', 'THEATRE', 'Opening Theater e final Rehearse BPM', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '10:15', '12:15', 'Service', 'Plenary', 'THEATRE', 'BPM Team WR', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '09:00', '17:30', 'Logistica', 'Other', 'DAY OUT EXPERIENCE', 'Day Out Excursion from Livorno', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '10:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'ACAPULCO - OUTDOOR DECK', 'Chilling Point', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '10:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'CARD ROOM', 'Smart working area', '', '', 'Modem Wifi', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '13:00', '14:30', 'Food & Beverage', 'Food & Beverage', 'L''IBISCUS RESTAURANT', 'Team WR Lunch', '', '', '', 'Multi', 'Confermato', 'Menu a tavola'),
  ('2026-10-26', '14:30', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'MEETING ROOM', 'Smart working area', '', '', 'Modem Wifi', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '15:15', '16:30', 'Logistica', 'Other', 'RECEPTION', 'Msc Tour With Captain', '', '', '', 'Multi', 'Confermato', 'Solo Team selezionato'),
  ('2026-10-26', '10:00', '17:00', 'Workshop & Activity', 'Workshop & Activity', 'SOMBRERO BAR - OUTDOOR DECK', 'Smart working area', '', '', 'Modem Wifi', 'Multi', 'Confermato', ''),
  ('2026-10-26', '09:00', '12:00', 'Logistica', 'Other', 'LIBRARY', 'Weroad shop by Vibes', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '21:00', '00:00', 'Logistica', 'Other', 'LIBRARY', 'Weroad shop by Vibes', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '12:30', '14:30', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Lunch - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '12:30', '14:30', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Lunch - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '16:00', '21:00', 'Logistica', 'Operation', 'WEROAD INFO DESK', 'WR Info Point', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '18:00', '20:00', 'Service', 'Entertainment', 'CALA BLANCA - OUTDOOR DECK', 'US Welcome onBoard', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '15:00', '16:30', 'Logistica', 'Other', 'THEATRE', '"Into the light" Closing Rehearse', 'Ludovica, Vantraxx, Paky, Sandro', '', '', '', 'Da confermare', ''),
  ('2026-10-26', '19:45', '21:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 1', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '21:15', '22:30', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Dinner – Slot 2', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '20:00', '22:00', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Dinner - No Slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '22:00', '00:00', 'Service', 'Entertainment', 'SHAKER LOUNGE', 'Open Mic & Stend Up Comedy', '', '', '', 'Multi', 'Da confermare', ''),
  ('2026-10-26', '23:00', '01:00', 'Service', 'Venue Setup', 'THEATRE', 'Closing Event "Into the light"', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '00:00', '01:00', 'Service', 'Entertainment', 'THEATRE', 'Closing Event "Into the light"', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '00:30', '02:00', 'Service', 'Entertainment', 'SHAKER LOUNGE', 'Closing Night - Silent', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-26', '00:30', '04:00', 'Service', 'Entertainment', 'DISCO', 'Closing NIght - Dj set', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-27', '07:30', '10:30', 'Food & Beverage', 'Food & Beverage', 'BUFFET RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-27', '08:00', '10:00', 'Food & Beverage', 'Food & Beverage', 'VILLA BORGHESE RESTAURANT', 'Breakfast - No slot', '', '', '', 'Multi', 'Confermato', ''),
  ('2026-10-27', '08:30', '13:00', 'Logistica', 'Operation', 'RECEPTION', 'Check Out', '', '', '', 'Multi', 'Confermato', '')
) as s(giorno, inizio, fine, area, categoria, location, attivita, responsabile, fornitore, materiali, lingua, stato, note)
where not exists (select 1 from public.voci);

-- Responsabile per location, giorno per giorno
create table if not exists public.loc_resp (
  giorno date not null,
  location text not null,
  responsabile text not null default '',
  updated_at timestamptz not null default now(),
  updated_by text not null default '',
  primary key (giorno, location)
);
alter table public.loc_resp enable row level security;
drop policy if exists "team tutto" on public.loc_resp;
create policy "team tutto" on public.loc_resp for all to authenticated using (true) with check (true);
do $$
begin
  alter publication supabase_realtime add table public.loc_resp;
exception when duplicate_object then null;
end $$;

-- Team (chi se ne occupa: ScuolaZoo, WeRoad, MSC…), separato dall'area
alter table public.voci add column if not exists team text not null default '';
