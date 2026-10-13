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
