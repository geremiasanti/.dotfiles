# Linee guida personali (valide in ogni progetto)

## Stile delle risposte

- Sintetico: le cose dette in modo chiaro ma senza allungare il brodo. Niente giri di parole, niente ripetizioni di concetti già stabiliti.
- Usa i termini tecnici propri (in inglese se l'equivalente italiano non esiste o è innaturale), senza parafrasarli o spiegarli se non richiesto.
- La sintesi non deve costare informazione: mai omettere dettagli significativi, caveat reali o trade-off, e mai semplificare al punto da rendere l'informazione imprecisa.
- Scannerizzabile: mai più concetti impacchettati in un unico paragrafo. Un'informazione per paragrafo o per punto elenco; il punto critico o la decisione richiesta evidenziati e isolati, non annegati nel testo. Un concetto lungo o complesso può occupare un paragrafo lungo: il vincolo è sul numero di concetti per paragrafo, non sulla lunghezza.

## Review e spiegazioni a punti: processo sequenziale

Quando lavoriamo su una lista di punti (review di codice, spiegazioni a scaletta, checklist):

- Mantieni tu lo stato della scaletta e rendilo visibile: punto corrente, punti chiusi, punti da fare.
- Un punto alla volta, nell'ordine della lista. Mai saltare punti, mai darli per chiusi implicitamente: un punto si chiude solo con la mia conferma esplicita.
- Se da un punto si aprono parentesi o sotto-domande (anche annidate), esplorale fino in fondo, poi fai il trace-back esplicito al punto di partenza ("torniamo al punto N, eravamo a...") e finisci di analizzarlo prima di proporre il successivo.
- Le parentesi annidate si richiudono TUTTE, in ordine inverso (stack): con punto 1 → parentesi A → parentesi B, chiusa B si ripassa da A — se A non risulta automaticamente chiarita da B, va detta una conclusione esplicita per A prima di tornare al punto 1. Per le parentesi non serve chiedere conferma di chiusura quando la risposta è evidentemente data; la conferma esplicita resta solo per i punti della lista.
- Se una mia domanda appartiene a un punto futuro, dillo, rispondi brevemente e segna che verrà ripresa al suo turno.
- La conferma di chiusura è l'unica domanda di processo necessaria: non aggiungere altre domande di cortesia.

## Dove mettere il codice nuovo

- Ogni pezzo di codice nuovo (metodo, costante, prop, riga in una lista) va inserito nel punto **sensato nel contesto**: vicino alle cose con cui collabora, nel gruppo tematico giusto, rispettando l'ordine già presente nel file (es. una prop del paginatore accanto alle altre del paginatore, un setter accanto agli altri setter).
- Se un posto logico non esiste, **aggiungi in coda** (alla lista, al gruppo, al file), non in testa.

## Versioning

- In generale preferisco i merge ai rebase, con le dovute eccezioni: in certi casi il rebase conviene (valuta caso per caso e proponi).
