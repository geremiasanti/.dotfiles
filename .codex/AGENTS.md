# Preferenze personali (valide in ogni progetto)

## Comunicazione

- Scrivi risposte sintetiche e dirette, limitate al necessario. Amplia quando te lo chiedo.
- Usa i termini tecnici appropriati, senza parafrasi o spiegazioni se non richieste.
- Mantieni la precisione e i dettagli significativi anche nelle risposte brevi. Separa i concetti e rendi evidenti le decisioni richieste.
- Descrivi il risultato finale, evitando la cronaca del lavoro, delle richieste e delle scelte abbandonate.
- Quando annullo una modifica, elimina i riferimenti dalle descrizioni e dai commenti del lavoro corrente, inclusi quelli già scritti.
- Cita esclusioni, comportamenti invariati e limiti solo quando servono a comprendere il risultato. Spiega una scelta poco evidente indicando cosa è stato escluso e perché.

## Descrizioni delle PR

- Spiega brevemente cosa cambia e a cosa serve.
- Ometti motivazioni organizzative come “primo giro di review” o il motivo per cui la PR è draft.
- Ometti sviluppi futuri e inventari di funzionalità incomplete. Segnala eventuali limiti indispensabili per comprendere il comportamento effettivo.
- Ometti il riepilogo di test e lint riusciti. Segnala eventuali problemi di verifica nel messaggio di consegna.
- Mantieni i riferimenti richiesti dal progetto, se presenti.

## Review e spiegazioni a punti

- Quando discutiamo insieme una scaletta, mantieni visibili il punto corrente, quelli chiusi e quelli da affrontare.
- Procedi nell'ordine, un punto alla volta. Chiudi ogni punto solo con la mia conferma esplicita.
- Approfondisci le sotto-domande e poi torna esplicitamente al punto di partenza. Se ci sono più parentesi annidate, richiudile in ordine inverso, con una conclusione dove serve.
- Se una domanda riguarda un punto futuro, rispondi brevemente e segna che verrà ripresa al suo turno.
- Evita domande di cortesia: chiedi la conferma di chiusura dei punti della scaletta.
- Quando presenti un punto relativo a un file, aprilo in Neovim alla riga pertinente con `~/.config/custom/nvim-open.sh <path assoluto>[:riga]`. Esegui lo script solo se esiste un socket attivo `/tmp/nvim-*.sock`; altrimenti segnalamelo.
- Se scrivo `show`, apri con lo stesso script i file di cui parla il tuo ultimo messaggio.

## Posizione del codice nuovo

- Inserisci il nuovo codice vicino alle parti con cui collabora, nel gruppo tematico appropriato e rispettando l'ordine esistente.
- Se non esiste un punto logico, aggiungilo in coda al gruppo o al file.

## Cronologia Git

- Preferisco i merge ai rebase. Valuta e proponi eventuali eccezioni.
- Non riscrivere la cronologia: niente `--amend`, reset di commit esistenti, rebase interattivi, squash o push forzati, nemmeno con `--force-with-lease`.
- Registra le correzioni con nuovi commit. Per spostare modifiche tra branch, usa un commit che le toglie dal primo e uno che le aggiunge al secondo.
- Se una riscrittura sembra indispensabile, fermati e chiedi il mio consenso. Commit e push richiedono comunque l'autorizzazione prevista sotto.

## Produzione e server condivisi

- Su produzione e server esterni o condivisi, chiedi conferma esplicita prima di esporre o copiare dati, installare pacchetti, modificare configurazioni, scrivere o ripristinare tabelle o cambiare lo stato del sistema. Presenta esattamente cosa verrà toccato e aspetta il mio consenso.
- Le letture di ricognizione, come SELECT, elenchi di file e controlli di versione, sono consentite senza conferma.

## Esecuzione test

- Usa al massimo 3 processi paralleli. Per i test Rails, prefissa sempre `PARALLEL_WORKERS=3`, ad esempio `PARALLEL_WORKERS=3 bin/rails test ...`, per lasciare la macchina utilizzabile mentre lavoro.

## Verifiche visive delle pagine web

- Quando è necessario vedere una pagina o verificare il layout, riproducila nel browser dei test e acquisisci direttamente uno screenshot, senza chiedermi di farlo se puoi riprodurla autonomamente.
- Nei progetti Rails con Capybara, usa un test system mirato: prepara i dati con le factory, autentica l'utente necessario, esegui `visit` con il route helper e poi `page.save_screenshot('/tmp/pagina.png', full: true)`.
- Apri lo screenshot con lo strumento di visualizzazione immagini e controlla il risultato prima di modificare il CSS. Non usare screenshot del desktop come prima scelta per verificare una pagina web.
- Parti dalla verifica visiva; misura posizioni e dimensioni nel DOM solo se serve per diagnosticare il problema o scrivere un test di regressione.
- Prima del commit, rimuovi il salvataggio degli screenshot e il codice diagnostico temporaneo. Mantieni un test di regressione solo se verifica un comportamento utile.

## Configurazioni personali

- Il repository dotfiles è un repository Git bare in `~/.dotfiles`, con working tree nella home. La bashrc definisce l'alias `dotfiles`.
- Proponi di versionare lì le configurazioni personali riutilizzabili tra progetti e procedi solo con il mio consenso esplicito.
- Mantieni la whitelist: abilita soltanto i singoli file concordati, senza includere intere directory.
- Escludi credenziali, token, chiavi private e altri dati riservati. Controlla il contenuto prima di aggiungerlo a Git.
- Chiedi il consenso prima di commit o push, salvo che siano già autorizzati nella richiesta corrente.

## Workflow locale — solo CardTrader

Queste regole valgono esclusivamente per CardTrader e i suoi worktree, non per gli altri progetti.

- La directory `/home/geremia/dev/CardTrader` è quella del server development e della review manuale. Sviluppa e testa in un worktree esterno, senza modificarla durante il lavoro.
- Riusa il worktree per tutta la durata del task: non ricrearlo a ogni modifica. Quello del task outbound è `/home/geremia/dev/CardTrader-codex-outbound`, sul branch `codex/outbound-mini-hub-shipments`, derivato da `outbound-mini-hub-shipments`. Per altri task, crea un worktree esterno e un branch distinto dal branch reviewato, dopo aver controllato `git worktree list` e lo stato Git.
- I file locali necessari sono `config/database.yml`, `config/elasticsearch.yml`, `config/redis.yml` e `config/master.key`: crea nel worktree symlink ai corrispondenti file della directory development, se mancanti. Non modificarli tramite i link, non stampare credenziali e non copiarli in Git.
- Puoi collegare `node_modules` dalla directory development solo se `package.json` e `yarn.lock` coincidono. Se cambiano le dipendenze, usa un'installazione separata. Le gemme già installate sono riutilizzabili dopo `bundle check`.
- Mantieni separati `tmp`, `log`, cache degli assets, upload, chiavi JWT generate dai test e altri file generati. Non collegare queste directory a quelle development. Il primo run può ricompilare gli assets; conserva la cache per i run successivi.
- Prima dei test, verifica senza esporre segreti che la configurazione `test` punti a MySQL locale: database `cardtrader_test`, socket `/run/mysqld/mysqld.sock`, con i database dei worker derivati dal nome di test. Ricontrolla se la configurazione cambia. Non eseguire migrazioni o comandi development come parte del setup dei test.
- Esegui una sola suite alla volta: i worktree condividono i servizi locali, i database e gli indici di test. Usa `RAILS_ENV=test PARALLEL_WORKERS=3 flock -n /tmp/cardtrader-test-suite.lock nice -n 10 ionice -c 2 -n 7 bin/rails test <file> --verbose`. Se il lock è occupato, non avviare un'altra suite e non interrompere processi altrui. Verifica anche eventuali run avviati senza lock.
- Esegui il lint a priorità ridotta: `nice -n 10 ionice -c 2 -n 7 bundle exec rubocop -a --cache false <file.rb>`; per JS usa il binario ESLint installato con `--fix`. Non editare i file del worktree mentre vengono testati.
- Trasferisci nella directory development solo modifiche complete, con lint e test pertinenti riusciti. Un'anteprima non ancora verificata richiede una richiesta esplicita. Prima di trasferire, controlla branch, diff e modifiche dell'utente; non sovrascrivere modifiche sovrapposte.
- Per trasferire commit autorizzati usa un merge, con directory di destinazione pulita. Per modifiche richieste unstaged, applica una patch della versione verificata, dopo `git apply --check`. Verifica che la versione trasferita coincida con quella testata. Commit e push restano soggetti alle autorizzazioni già definite; migrazioni e modifiche al database richiedono un passaggio separato.
