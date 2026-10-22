-- Permessi per persona: admin (tutto), campi (solo alcuni campi), lettura (solo lettura)
create table if not exists public.profili (
  email text primary key,
  ruolo text not null default 'lettura' check (ruolo in ('admin','campi','lettura')),
  nome  text not null default ''
);
alter table public.profili enable row level security;
drop policy if exists "vedo il mio profilo" on public.profili;
create policy "vedo il mio profilo" on public.profili for select to authenticated
  using (lower(email) = lower(auth.jwt()->>'email'));

-- chi non è nella tabella resta admin (così gli accessi di oggi continuano a funzionare)
create or replace function public.mio_ruolo() returns text
language sql stable security definer set search_path = public as $$
  select coalesce((select ruolo from public.profili where lower(email) = lower(auth.jwt()->>'email')), 'admin');
$$;

drop policy if exists "team inserisce" on public.voci;
drop policy if exists "team modifica" on public.voci;
drop policy if exists "team elimina" on public.voci;
create policy "team inserisce" on public.voci for insert to authenticated with check (public.mio_ruolo() = 'admin');
create policy "team modifica"  on public.voci for update to authenticated using (public.mio_ruolo() in ('admin','campi')) with check (public.mio_ruolo() in ('admin','campi'));
create policy "team elimina"   on public.voci for delete to authenticated using (public.mio_ruolo() = 'admin');

-- chi ha ruolo "campi" non può cambiare titolo, giorno, orari, location, categoria, team, lingua, stato
create or replace function public.blocca_campi() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if public.mio_ruolo() = 'campi' and (
     new.attivita is distinct from old.attivita or new.giorno is distinct from old.giorno or
     new.inizio is distinct from old.inizio or new.fine is distinct from old.fine or
     new.location is distinct from old.location or new.area is distinct from old.area or
     new.team is distinct from old.team or new.categoria is distinct from old.categoria or
     new.lingua is distinct from old.lingua or new.stato is distinct from old.stato) then
    raise exception 'Con il tuo accesso puoi modificare solo staff, responsabile, materiali e note';
  end if;
  return new;
end $$;
drop trigger if exists trg_voci_campi on public.voci;
create trigger trg_voci_campi before update on public.voci for each row execute function public.blocca_campi();

drop policy if exists "team tutto" on public.loc_resp;
drop policy if exists "team legge lr" on public.loc_resp;
drop policy if exists "team scrive lr" on public.loc_resp;
create policy "team legge lr" on public.loc_resp for select to authenticated using (true);
create policy "team scrive lr" on public.loc_resp for all to authenticated using (public.mio_ruolo()='admin') with check (public.mio_ruolo()='admin');
