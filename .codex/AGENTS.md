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

## Monitoring

- Negli altri progetti attiva il monitoring solo quando l'utente lo chiede; i progetti che lo richiedono esplicitamente fanno eccezione. Usa lo script personale `~/.config/custom/agent-monitor.py`.
- Attivazione: esegui `~/.config/custom/agent-monitor.py open` una volta all'inizio del lavoro monitorato. Apre o riusa un terminale Alacritty nel workspace i3 7, con una sessione tmux dedicata. Non cambiare la configurazione i3 o spostare altre finestre.
- In CardTrader, quando l'hook `PreToolUse` in `~/.codex/hooks.json` è caricato e autorizzato, esegui i comandi terminale normalmente: `~/.config/custom/agent-monitor-hook.py` inserisce automaticamente il wrapper e ricava il nome dell'operazione. Verifica l'attivazione con un comando innocuo prima di affidarti al monitoring automatico. Il comando resta nel contesto di esecuzione e nei permessi del tool; il viewer host gestisce soltanto i pane e non esegue il lavoro al posto del tool.
- Per operazioni il cui nome automatico sarebbe generico, come script Python inline, aggiungi sulla prima riga `# agent-monitor: <nome-descrittivo>`. L'hook usa quel nome senza richiedere il wrapper esplicito; Git, test e lint possono mantenere i nomi automatici.
- Il monitor mostra davanti al nome una categoria comune a tutti i progetti: `[READ]`, `[EDIT]`, `[TEST]`, `[LINT]`, `[GIT ]`, `[DB  ]`, `[CMD ]`. CMD identifica comandi semplici del terminale come `sleep`, `printf`, `echo` e `true`. Gli script riconosciuti usano `[R:py]`, `[R:js]`, `[R:rb]`, `[R:sh]`, ecc.; le operazioni senza tipologia riconosciuta mostrano `[    ]`. Le parentesi contengono sempre 4 caratteri per mantenere l'allineamento.
- Se l'hook non è attivo, o per gli altri progetti quando viene richiesto il monitoring, usa `~/.config/custom/agent-monitor.py run <nome-operazione> -- <comando> <argomenti>`. Usa nomi descrittivi, ad esempio `test-system-3-worker`, `test-models-8-worker`, `rubocop`. Non aggiungere il wrapper quando è già inserito dall'hook.
- Il monitor mostra subito l'operazione nello storico e apre automaticamente un pane per l'output se il comando supera un secondo. I comandi rapidi non aprono pane. I comandi di gestione (`open`, `status`, `show`) non vanno avvolti nel wrapper.
- Usa una sola finestra tmux: la panoramica “Activity” resta sempre a sinistra, con le sezioni “RUNNING” sopra e “COMPLETED” sotto, aggiornate dal viewer. I contatori sono tra parentesi accanto ai titoli, in grigio. Ogni task in corso mostra nome e durata, con il comando indentato sotto; quelli completati mostrano nome, durata ed exit code. I nomi occupano 25 caratteri e vengono troncati con ellissi. Le righe sono colorate: ciano in corso, verde riuscito, rosso fallito, giallo interrotto; i task appena completati passano dal ciano al colore del proprio esito in 5 secondi. `status` mantiene comando, directory e percorso del log completi. Senza task lunghi occupa tutto lo schermo; con un task lo schermo è diviso a metà; con due task è diviso in tre colonne uguali. Con più task, la panoramica resta a sinistra per tutta l'altezza e occupa un terzo; i task si distribuiscono nelle due colonne a destra, dividendone l'altezza in parti uguali, ad esempio `Activity | task1/task3 | task2/task4`.
- Non cambiare scheda o focus quando iniziano o terminano i task. I pane dei task si chiudono alla fine e quelli rimasti si ridistribuiscono automaticamente, anche al ridimensionamento del terminale. Usa `Ctrl-b` seguito da una freccia per selezionare un pane e `Ctrl-b [` per lo scrollback.
- Consultazione: `~/.config/custom/agent-monitor.py status` mostra lo storico; `~/.config/custom/agent-monitor.py show <id>` rilegge l'output salvato. I log sono in `/tmp/agent-monitor-<uid>/`, accessibili solo all'utente, e possono essere rimossi dal sistema al riavvio. Non versionarli nei dotfiles.
- Il wrapper restituisce l'exit code del comando e mantiene l'output disponibile anche ai tool: continua a monitorarlo e verifica l'esito, non affidarti solo alla finestra visibile. Chiudere il terminale del monitor non interrompe i task. Lo script è per comandi non interattivi.
- Passa comandi e argomenti separatamente, senza `eval`. Se servono variabili d'ambiente visibili nel comando, usa `run <nome> -- env RAILS_ENV=test PARALLEL_WORKERS=8 <comando>`. Mantieni limiti di worker, priorità ridotta e lock della suite prescritti dal progetto: il monitor non li applica automaticamente.
- Non registrare comandi o output contenenti credenziali, token o dati riservati. Con l'hook attivo, metti `# agent-monitor: off` sulla prima riga del comando per escluderlo dal monitoring; senza hook, eseguilo fuori dal wrapper. Mantieni l'output minimizzato e segnala l'esclusione senza mostrare segreti. Le esclusioni automatiche per alcune sorgenti sensibili note non sostituiscono questa valutazione. Le operazioni tramite tool non terminali, come `apply_patch`, restano nei tool dedicati e negli aggiornamenti in chat.

## Workflow locale — solo CardTrader

Queste regole valgono esclusivamente per CardTrader e i suoi worktree, non per gli altri progetti.

- In CardTrader usa sempre il monitoring descritto nella sezione “Monitoring” per i comandi terminale, sia in modalità diretta sia in modalità isolata, salvo le esclusioni per dati riservati e i comandi di gestione del monitor.

### Modalità di lavoro

- **Diretta, default:** sviluppa e testa nella directory principale `/home/geremia/dev/CardTrader`.
- **Isolata, su richiesta:** sviluppa e testa in un worktree esterno mentre l'utente usa la directory principale per il server development e la review manuale. Non modificarla durante il lavoro; trasferisci solo modifiche complete e verificate.
- «Passiamo in isolata» e «torniamo in diretta» selezionano la modalità per il lavoro corrente, fino alla successiva richiesta di cambio. Non attivare l'isolamento automaticamente solo perché esiste un worktree.
- Prima di cambiare modalità, controlla branch, modifiche staged e unstaged e test in corso in entrambe le directory. Preserva le modifiche dell'utente; non trasferire modifiche incomplete e non eliminare il worktree tornando in diretta.

### Esecuzione test

- Queste regole valgono sia in modalità diretta sia in modalità isolata. Usa al massimo **3 worker per i system test** (`PARALLEL_WORKERS=3`) e **8 worker per gli altri test** (`PARALLEL_WORKERS=8`). In Rails sono processi, non thread. Preferisci run separati e consecutivi; se un run include anche system test, usa 3 worker per tutto il run.
- Prima dei test, verifica senza esporre segreti che la configurazione `test` punti a MySQL locale: database `cardtrader_test`, socket `/run/mysqld/mysqld.sock`, con i database dei worker derivati dal nome di test. Ricontrolla se la configurazione cambia. Non eseguire migrazioni o comandi development come parte del setup dei test.
- Esegui una sola suite alla volta: i worktree condividono i servizi locali, i database e gli indici di test. Per i system test usa `RAILS_ENV=test PARALLEL_WORKERS=3 flock -n /tmp/cardtrader-test-suite.lock nice -n 10 ionice -c 2 -n 7 bin/rails test test/system/ --verbose`; per gli altri usa `RAILS_ENV=test PARALLEL_WORKERS=8 flock -n /tmp/cardtrader-test-suite.lock nice -n 10 ionice -c 2 -n 7 bin/rails test <file non-system> --verbose`. Se il lock è occupato, non avviare un'altra suite e non interrompere processi altrui. Verifica anche eventuali run avviati senza lock.
- Non editare i file della directory sottoposta ai test mentre il run è in corso.

### Lint e Git

- Esegui il lint a priorità ridotta: `nice -n 10 ionice -c 2 -n 7 bundle exec rubocop -a --cache false <file.rb>`; per JS usa il binario ESLint installato con `--fix`, con la stessa priorità ridotta.
- Commit e push restano soggetti alle autorizzazioni già definite; migrazioni e modifiche al database richiedono un passaggio separato.

### Setup e trasferimento in modalità isolata

- Riusa il worktree per tutta la durata del task: non ricrearlo a ogni modifica. Quello del task outbound è `/home/geremia/dev/CardTrader-codex-outbound`, sul branch `codex/outbound-mini-hub-shipments`, derivato da `outbound-mini-hub-shipments`. Per altri task, crea un worktree esterno e un branch distinto dal branch reviewato, dopo aver controllato `git worktree list` e lo stato Git.
- I file locali necessari sono `config/database.yml`, `config/elasticsearch.yml`, `config/redis.yml` e `config/master.key`: crea nel worktree symlink ai corrispondenti file della directory development, se mancanti. Non modificarli tramite i link, non stampare credenziali e non copiarli in Git.
- Puoi collegare `node_modules` dalla directory development solo se `package.json` e `yarn.lock` coincidono. Se cambiano le dipendenze, usa un'installazione separata. Le gemme già installate sono riutilizzabili dopo `bundle check`.
- Mantieni separati `tmp`, `log`, cache degli assets, upload, chiavi JWT generate dai test e altri file generati. Non collegare queste directory a quelle development. Il primo run può ricompilare gli assets; conserva la cache per i run successivi.
- Trasferisci nella directory development solo modifiche complete, con lint e test pertinenti riusciti. Un'anteprima non ancora verificata richiede una richiesta esplicita. Prima di trasferire, controlla branch, diff e modifiche dell'utente; non sovrascrivere modifiche sovrapposte.
- Per trasferire commit autorizzati usa un merge, con directory di destinazione pulita. Per modifiche richieste unstaged, applica una patch della versione verificata, dopo `git apply --check`. Verifica che la versione trasferita coincida con quella testata.
