# Preferenze personali (valide in ogni progetto)

## Comunicazione

- Scrivi risposte sintetiche e dirette, limitate al necessario. Amplia quando te lo chiedo.
- Descrivi il risultato finale, evitando la cronaca del lavoro, delle richieste e delle scelte abbandonate.
- Quando annullo una modifica, elimina i riferimenti dalle descrizioni e dai commenti del lavoro corrente, inclusi quelli già scritti.
- Cita esclusioni, comportamenti invariati e limiti solo quando servono a comprendere il risultato. Spiega una scelta poco evidente indicando cosa è stato escluso e perché.

## Descrizioni delle PR

- Spiega brevemente cosa cambia e a cosa serve.
- Ometti motivazioni organizzative come “primo giro di review” o il motivo per cui la PR è draft.
- Ometti sviluppi futuri e inventari di funzionalità incomplete. Segnala eventuali limiti indispensabili per comprendere il comportamento effettivo.
- Ometti il riepilogo di test e lint riusciti. Segnala eventuali problemi di verifica nel messaggio di consegna.
- Mantieni i riferimenti richiesti dal progetto, se presenti.

## Configurazioni personali

- Il repository dotfiles è un repository Git bare in `~/.dotfiles`, con working tree nella home. La bashrc definisce l'alias `dotfiles`.
- Proponi di versionare lì le configurazioni personali riutilizzabili tra progetti e procedi solo con il mio consenso esplicito.
- Mantieni la whitelist: abilita soltanto i singoli file concordati, senza includere intere directory.
- Escludi credenziali, token, chiavi private e altri dati riservati. Controlla il contenuto prima di aggiungerlo a Git.
- Chiedi il consenso prima di commit o push, salvo che siano già autorizzati nella richiesta corrente.
