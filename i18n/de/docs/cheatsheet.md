> Deutsche Uebersetzung von [`docs/cheatsheet.md`](../../../docs/cheatsheet.md). Die englische
> Fassung ist massgeblich; bei Abweichungen gilt das Original.

# Spickzettel

Die alltaeglichen Befehle, in der Reihenfolge, in der du sie benutzt. Halte diesen Zettel offen
neben dir, bis sie sitzen. Jeder **fett** gedruckte Begriff ist im [Glossar](glossary.md) definiert;
die vollstaendige Begruendung steht im [Git-Workflow](engineering/git-workflow.md).

Ersetze alles in `<angle brackets>` durch deinen eigenen Wert. Tippe die Klammern nicht mit.

## Die normale Schleife, von oben nach unten

```bash
# 1. Sitzungsbeginn: den aktuellen Stand vom Remote holen.
git fetch

# 2. Aufgabe starten: einen Worktree dafuer anlegen, abgezweigt von develop.
#    <type> ist eines von: feat fix docs style refactor perf test build ci chore revert
#    <slug> ist ein kurzer, mit Bindestrichen getrennter Name, z. B. scroll-jitter.
./scripts/wt.sh new <type>/<slug>

# 3. Wechsle in den ausgegebenen Ordner und erledige dort DIE GESAMTE Arbeit.
cd <printed-worktree-path>

# 4. Arbeite in kleinen Schritten. Sichere nach jeder kleinen Korrektur einen Schnappschuss (einen Commit):
git add -A                                  # alles Geaenderte vormerken
git commit -m "<type>(<scope>): <summary>"  # z. B. docs(readme): fix broken link

# 5. Vor dem Push den Quality Gate ausfuehren. Er muss bestehen.
make check

# 6. Deinen Branch zum Remote pushen.
git push -u origin <type>/<slug>

# 7. Einen Pull Request nach develop oeffnen (nicht master).
gh pr create --base develop --fill

# 8. Uebergib den PR zum Review und Merge. Merge nie deinen eigenen.

# 9. Nach dem Merge den gemergten Worktree aufraeumen.
./scripts/wt.sh gc
```

## Worktree-Befehle (`scripts/wt.sh`)

Ein Ordner pro Branch, damit parallele Aufgaben nie kollidieren. Warum, steht im
[Git-Workflow](engineering/git-workflow.md).

| Befehl | Was er tut |
| --- | --- |
| `./scripts/wt.sh new <type>/<slug>` | Erstellt einen **[Worktree](glossary.md#worktree)** + **[Branch](glossary.md#branch)** von `develop`; gibt den Pfad aus, in den du mit `cd` wechselst. |
| `./scripts/wt.sh ls` | Listet deine Worktrees, jeweils markiert mit `merged` / `unmerged` / `dirty`. |
| `./scripts/wt.sh gc` | Entfernt jeden Worktree, dessen Branch bereits gemergt ist; behaelt unfertige. |
| `./scripts/wt.sh rm <branch>` | Entfernt einen Worktree von Hand (`--force`, falls er nicht committete Arbeit enthaelt). |

## Git-Befehle fuer den taeglichen Gebrauch

| Befehl | Was er tut |
| --- | --- |
| `git fetch` | Laedt den aktuellen Stand vom Remote herunter, ohne deine Dateien zu aendern. |
| `git status` | Zeigt, was du geaendert hast und welche Dateien vorgemerkt sind. |
| `git diff` | Zeigt die genauen zeilenweisen Aenderungen, die du noch nicht committet hast. |
| `git add -A` | Merkt alle deine Aenderungen fuer den naechsten **[Commit](glossary.md#commit)** vor. |
| `git commit -m "<msg>"` | Sichert einen Schnappschuss mit einer Nachricht (siehe Format unten). |
| `git push -u origin <branch>` | Sendet deinen Branch und seine Commits zum Remote hoch. |
| `git log --oneline` | Zeigt die letzten Commits, je eine Zeile. |

## Format der Commit-Nachricht

Eine logische Aenderung pro Commit. Die Zusammenfassung ist im Imperativ, kleingeschrieben, ohne
Punkt am Ende.

```
<type>(<optional scope>): <summary>
```

`<type>` ist eines von: `feat fix docs style refactor perf test build ci chore revert`.
Verweise im Footer auf eine Backlog-Aufgabe, wenn relevant, z. B. `Refs: P9-3`.

```
docs(cheatsheet): add one-page everyday-commands reference
fix(api): return typed unavailable state instead of throwing
```

## Der [Quality Gate](glossary.md#quality-gate) (`make check`)

Fuehre ihn vor jedem Push aus; er muss gruen sein. Er buendelt die Pruefungen des Projekts:

| Befehl | Was er tut |
| --- | --- |
| `make check` | Fuehrt den gesamten Gate aus ([Lint](glossary.md#lint) + Typecheck + Test + Build, soweit zutreffend). |
| `make lint` | Nur Pruefungen auf Stil und wahrscheinliche Fehler. |
| `make test` | Nur die Testsuite. |

Wenn der Gate rot ist, lies den ersten Fehler, behebe ihn, `git add -A && git commit`, und fuehre
erneut `make check` aus.

## Wenn etwas schiefgeht

- **Unsicher, was ein Wort bedeutet?** Wirf einen Blick ins [Glossar](glossary.md).
- **Willst du die vollstaendige Begruendung** hinter dem Workflow? Siehe den
  [Git-Workflow](engineering/git-workflow.md).
- **Bei einem roten Gate oder einem unerwarteten Fehler festgefahren?** Lies den ersten Fehler Zeile
  fuer Zeile, behebe die eine Sache, die er nennt, und fuehre erneut `make check` aus, bevor du
  irgendetwas anderes tust.
