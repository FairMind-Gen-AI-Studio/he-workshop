# Harness Engineering con Claude Code: kit del corso

Materiale d'aula del workshop. Cinque laboratori, un repository campione per
ciascuno, più i fogli da stampare.

Il codice qui dentro accompagna i capitoli 4-7 di *Harness Engineering with
Claude Code* (Packt, Alexio Cassani). Gira davvero: le suite del Lab 5 girano
contro gli hook del Lab 4, non contro delle finte.

## Setup, adesso

```bash
git clone https://github.com/FairMind-Gen-AI-Studio/he-workshop.git
cd he-workshop
claude --version
```

### Prerequisiti

| Serve | Dove |
|---|---|
| `bash`, `git`, `jq` | Lab 4, Lab 5 |
| `docker` | Lab 3, opzionale |
| `python3` con `pyyaml` | Lab 5 |
| `npx` con `prettier` | Lab 4 |

Chi non ha Docker fa la variante di lettura del Lab 3, dichiarata sulle slide.
Il container è verificato su Docker 28.3 per macOS: altrove è terreno non
battuto, e chi vede fallire il build passa alla lettura senza problemi.

Controllo rapido:

```bash
for c in bash git jq docker python3 npx; do
  printf '%-8s %s\n' "$c" "$(command -v $c || echo MANCA)"
done
python3 -c 'import yaml; print("pyyaml ok")'
```

## Cosa c'è dentro

| Cartella | Lab | Cosa contiene |
|---|---|---|
| `kit/` | 1 | La matrice 5x4 da stampare, i fogli degli esercizi, il CLAUDE.md gonfio del Lab 2 |
| `code/ch04/` | 2 | Un contratto di repository vero: CLAUDE.md, rules, tre skill, il livello annidato in `services/api/` |
| `code/ch05/` | 3 | La base personale di deny, il devcontainer con firewall in uscita, l'allowlist dei domini |
| `code/ch06/` | 4 | Otto hook: il gate classifier, la blocklist di contrasto, l'orchestratore Stop, il log dei comandi |
| `code/ch06-pristine/` | 5 | Copia intatta del precedente. Non toccatela |
| `code/ch07/` | 5 | La suite avversariale sugli hook e lo scorer dell'eval-set |

Ogni cartella `code/` ha il suo README con la mappa file per file.

**`code/ch06-pristine/` esiste per una ragione.** La suite del Lab 5 manda i
suoi payload al `gate-aws-cli.sh` del Lab 4. Se puntasse alla copia che avete
appena modificato, chi ha sbagliato il Lab 4 vedrebbe un run rosso che non
insegna niente. Punta alla copia intatta, ed è l'unica differenza fra questo
repository e il companion del libro.

## I cinque laboratori

### Lab 1: Diagnosticate un harness (20')

Stampate `kit/matrice-5x4.md`. Riempite una riga intera, quella dove sta il
fallimento dell'Esercizio 1. Marcate ogni voce **comp** o **inf**. Nominate le
celle vuote: decisione o incidente, scritto, non pensato. Consegnate tre celle
vuote ordinate per rischio.

Chi ha un repository proprio sotto mano può usarlo al posto del campione.

### Lab 2: Un contratto che cambia comportamento (30')

```bash
cd code/ch04
```

Applicate `prompts/audit-claude-md.txt` a `kit/claude-md-gonfio.md`, 191 righe.
Tagliate riga per riga con il test del repository: se il repository sa dirlo da
solo, esce. Poi scrivete la definition of done nel contratto e cablate
`.claude/skills/verify-done/SKILL.md`. Infine aggiungete un livello annidato in
`services/api/CLAUDE.md` e scrivete su carta chi vince **prima** di provarlo.

Verifica finale: chiedete all'agente qualcosa che viola la definition of done e
guardate cosa fa. A questo livello può ancora ignorarla, ed è il punto da cui
nasce il Lab 4.

### Lab 3: I confini, come file (30')

```bash
cd code/ch05
```

Fondete `user-floor.settings.json` nel vostro `~/.claude/settings.json`, non
sovrascrivetelo. Poi provate a riaprire da un file di progetto uno dei deny
sulle credenziali: fallisce, ed è il punto dell'esercizio.

```bash
devcontainer up --workspace-folder .
# aspettate "egress policy in force"
curl -sS https://example.com          # deve essere rifiutato
curl -sS https://api.github.com/zen   # deve rispondere 200
```

Aggiungete un dominio in `.devcontainer/allowed-domains.txt` con il perchè
accanto, ricostruite, rifate la prova. Se non sapete scrivere il perché, quel
dominio non entra.

### Lab 4: Lo strato di enforcement (35')

```bash
cd code/ch06
echo '{"tool_input":{"command":"aws ssm get-parameter --name /prod/db-pw"}}' \
  | .claude/hooks/gate-aws-cli.sh
```

Quattro payload su stdin, attesi deny, deny, ask e silenzio. Leggete il JSON,
non il codice di uscita: la differenza fra "ask" e "niente" è tutto il progetto
del gate. Poi registratelo come `PreToolUse` con matcher `Bash` nel
`settings.json` e rifate le stesse prove dentro una sessione vera.

Cablate `on-stop.sh`, rompete un test, chiedete all'agente di chiudere. Non
chiude, e quello che gli torna indietro è l'output del comando, non un verdetto.

La trappola: registrate due hook Stop che dipendono l'uno dall'altro e fateli
girare qualche volta. Girano in parallelo, senza ordine. E' il motivo per cui
`on-stop.sh` è uno solo che sequenzia al proprio interno.

### Lab 5: Vedere fallire gli strumenti (25')

```bash
cd code/ch07
bash harness-tests/run.sh
```

Si legge il **testo** del fallimento, non la parola FAIL: con la gamba deny
rimossa il gate non risponde "allow", non risponde niente. Un gate che ha smesso
di negare è identico a un gate che funziona.

```bash
bash evals/run.sh score \
  --dataset evals/tasks \
  --predictions evals/runs/example-predictions.jsonl
```

Aggiungete tre righe `oversize` ai prediction e verificate che il pass rate resti
invariato. Poi scrivete un task YAML nuovo per una regola del vostro harness, e
chi arriva in fondo lo fa girare.

## Le soluzioni

Stanno sul branch `docente`, non su questo.

## Licenza

Il codice dei capitoli accompagna il libro ed è distribuito con il repository
companion di Packt. Il materiale d'aula è di FairMind.
