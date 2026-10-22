# Piano di produzione GR26 · web app

App per telefono (anche da computer) che il team apre da un link, senza account Claude.
Agenda, timeline per location, lista materiali, modifica in tempo reale, esportazione CSV.

## Prima di tutto: provala subito
Apri `index.html` nel browser. Con le due chiavi vuote parte in **modalità demo** con le 122 voci del palinsesto, salvate solo sul tuo dispositivo. Serve per vedere come funziona. Per lavorare in team serve il passaggio qui sotto.

## Messa online (circa 15 minuti, tutto gratis)

### 1. Database (Supabase)
1. Vai su supabase.com, crea un account e un **New project** (scegli una regione in Europa, salva la password del database).
2. Menu **SQL Editor → New query**: incolla tutto il contenuto di `schema.sql` e premi **Run**.
   Crea la tabella, la sicurezza, il tempo reale e carica le 122 voci. Puoi rilanciarlo senza duplicare nulla.

### 2. Accessi del team
1. **Authentication → Sign In / Providers → Email**: disattiva **Allow new users to sign up**. Così nessuno può registrarsi da solo.
2. **Authentication → Users → Add user → Create new user**: inserisci email e password e spunta **Auto Confirm User**.
   Crea un utente per persona, oppure uno solo condiviso da tutto il team (l'email può anche essere inventata, es. `team@gr26.it`).

### 3. Collega l'app
1. **Project Settings → API**: copia **Project URL** e la chiave pubblica **anon** (inizia con `eyJ`; in alcune versioni della dashboard sta nella scheda *Legacy API Keys*).
2. Apri `index.html` con un editor di testo, cerca `CONFIG` (in alto nello script) e incolla i due valori:
   ```js
   var CONFIG = { SUPABASE_URL: 'https://xxxx.supabase.co', SUPABASE_ANON_KEY: 'eyJ...' };
   ```
   La chiave anon è pubblica per progettazione: i dati sono protetti dal login.

### 4. Pubblica
- **GitHub Pages** (attuale): l'app è pubblicata da questo repository su https://vantraxx99.github.io/piano-produzione-gr26/ — ogni push su `main` aggiorna il sito.
- **GitHub Pages**: crea un repository, carica tutti i file, poi *Settings → Pages → Branch: main, cartella /root*.

Il link serve https: il login e l'uso offline non funzionano da `file://`.

### 5. Sui telefoni
- iPhone: apri il link in Safari → Condividi → **Aggiungi alla schermata Home**.
- Android: Chrome → menu → **Installa app**.
Resta aperto in tutto schermo come un'app e si apre anche senza rete (ultimi dati salvati, sola lettura).

## Come si usa
- **Giorni** in alto (20–27 ott), **aree** sotto: tocca per filtrare. Lente per cercare e filtrare per location e categoria.
- **Agenda**: elenco per orario, "ORA" sulle attività in corso. **Timeline**: una colonna per location, tocca una cella vuota per aggiungere. **Materiali**: lista per location con spunta "pronti".
- Tocca un'attività per vedere i dettagli, cambiare stato con un tap o modificarla. **+** per aggiungerne una.
- Menu ⋯ → **Esporta vista (CSV)** esporta solo ciò che stai filtrando (es. solo Service del 25). Su telefono si apre il foglio di condivisione (WhatsApp, Drive, mail). Si apre in Excel e Fogli.
- Gli orari dopo mezzanotte (fino alle 06:00) restano nella serata del giorno scelto.

## Note
- Aree assegnate in automatico dal palinsesto: ScuolaZoo se il referente è "Staff ScuolaZoo"; Service per Plenary, Venue Setup, Entertainment; Logistica per Operation e Other. Si cambiano da ogni scheda.
- Titoli troncati nel PDF originale da ricontrollare: "WeRoad goes USA: inside our American…" e "From day one to the IRL movement…".
- I giorni 20–23 (pre-produzione) sono vuoti: il palinsesto parte dal 24.
- Per pubblicare una nuova versione dell'app cambia `VERSION` in `sw.js` (es. `pp-v2`), altrimenti alcuni telefoni tengono la vecchia.
- Il piano gratuito di Supabase mette in pausa il progetto dopo 7 giorni senza uso; si riattiva con un clic dalla dashboard.
