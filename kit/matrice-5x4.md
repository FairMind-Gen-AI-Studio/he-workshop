# La matrice 5x4

Stampatene una copia a testa. Serve nel Lab 1 e torna nel modulo di chiusura.

Cinque componenti sulle righe, quattro ruoli sulle colonne. Ogni artefatto
deliberato del vostro harness sta in una cella. I default del runtime non sono
artefatti: contarli riempie la griglia e nasconde la forma che l'esercizio deve
rivelare.

Accanto a ogni voce scrivete **comp** se il suo esito è deterministico, **inf**
se dipende da un giudizio del modello. Serve a sapere di quali celle vi potete
fidare sotto pressione.

|                          | Guide | Sensor | Boundary | Record |
|--------------------------|-------|--------|----------|--------|
| System prompt e contesto |       |        |          |        |
| Tool e descrizioni       |       |        |          |        |
| Infrastruttura           |       |        |          |        |
| Orchestrazione           |       |        |          |        |
| Hook e middleware        |       |        |          |        |

## Le quattro domande, una per colonna

| Colonna | La domanda |
|---|---|
| Guide | Cosa alza le probabilita' di un buon primo tentativo |
| Sensor | Cosa si accorge di un tentativo cattivo |
| Boundary | Cosa l'agente non può fare nemmeno provandoci |
| Record | Cosa sopravvive alla sessione come evidenza |

## Le tre celle vuote

Alla fine del Lab 1 consegnate tre celle vuote ordinate per rischio, e accanto a
ciascuna il fallimento che avrebbe spiegato.

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________
