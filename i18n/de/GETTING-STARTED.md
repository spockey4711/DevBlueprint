> Deutsche Uebersetzung von [`GETTING-STARTED.md`](../../GETTING-STARTED.md). Die englische
> Fassung ist massgeblich; bei Abweichungen gilt das Original.

# Erste Schritte

Neu im Terminal, bei git oder beim Programmieren allgemein? Dann fang hier an. Diese Anleitung
bringt dich von "nichts installiert" bis zu deinem ersten gruenen Pull Request und erklaert jeden
Schritt in einfacher Sprache - und *warum* er so aussieht, wie er aussieht. Keine Vorkenntnisse
noetig.

Wenn du dich mit Terminal, git und Paketmanagern schon auskennst, kannst du diese Anleitung
ueberspringen und direkt zur [README](../../README.md) gehen - sie deckt dasselbe schneller ab.

> **Nichts installieren wollen?** Jedes DevBlueprint-Projekt bringt eine fertige Cloud-Umgebung
> mit. Oeffne es in **GitHub Codespaces** (oder einem lokalen Dev Container) und du hast in
> wenigen Minuten einen funktionierenden Editor samt Toolchain - ohne irgendetwas auf deinem
> Rechner zu installieren. Siehe
> [Zero-install-Setup: Codespaces und Dev Containers](../../docs/codespaces.md) - das ist der
> schnellste Einstieg und erspart dir die Voraussetzungen weiter unten.

> Diese Anleitung entsteht in Etappen. Mit _(coming soon)_ markierte Abschnitte sind Platzhalter,
> die in Kuerze gefuellt werden; die Ueberschriften zeigen schon, was geplant ist, damit du
> weisst, was dich erwartet.

## Voraussetzungen

Bevor du dein erstes Projekt aufsetzt, brauchst du vier installierte Dinge:

- ein **Terminal** - das Fenster, in dem du Befehle tippst, statt zu klicken,
- **git** - das Werkzeug, das die Geschichte deiner Aenderungen aufzeichnet,
- **Node** - die Laufzeitumgebung, mit der der Befehl `devblueprint` laeuft, und
- einen **Code-Editor** - in dem du die Dateien des Projekts liest und schreibst.

Du installierst sie einmal, und jedes kuenftige Projekt nutzt sie wieder. Arbeite die vier der
Reihe nach durch. Jeder Block unten kann gefahrlos genau so kopiert und eingefuegt werden, wie er
dasteht - nimm einfach die Zeilen fuer dein Betriebssystem. Nach jeder Installation folgt ein
Pruefbefehl und die Ausgabe, die du bei Erfolg sehen solltest. Wenn die Ausgabe dem Beispiel
aehnelt (die Versionsnummern werden abweichen, das ist in Ordnung), bist du fertig; wenn
`command not found` erscheint, wurde die Installation nicht abgeschlossen - fuehre sie erneut aus
oder oeffne ein frisches Terminal, damit es den neuen Befehl kennt.

> **macOS: zuerst Homebrew installieren.** Die macOS-Schritte unten nutzen
> [Homebrew](https://brew.sh), den Standard-Paketmanager fuer den Mac. Installiere ihn einmal,
> indem du das hier in dein Terminal einfuegst und den Anweisungen folgst (es fragt nach deinem
> Passwort):
>
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```
>
> Am Ende gibt es zwei `Next steps`-Zeilen aus, die mit `echo` und `eval` beginnen - fuehre diese
> aus, damit `brew` in deinem PATH liegt, und bestaetige dann mit `brew --version` (du solltest
> `Homebrew 4.x.x` sehen).

### 1. Ein Terminal

Du hast mit ziemlicher Sicherheit schon eines - du musst es nur finden und oeffnen:

- **macOS** - druecke Cmd+Space, tippe `Terminal`, druecke Enter.
- **Windows** - druecke die Start-Taste, tippe `Terminal`, druecke Enter. (Auf aelteren
  Windows-Versionen ohne Terminal installiere zuerst *Windows Terminal* aus dem Microsoft Store
  und oeffne es dann auf diesem Weg.)
- **Linux** - druecke Ctrl+Alt+T oder oeffne dein Anwendungsmenue und suche nach `Terminal`.

Tippe das hier und druecke Enter, um zu bestaetigen, dass das Terminal reagiert:

```bash
echo "hello"
```

Du solltest sehen:

```text
hello
```

Lass dieses Fenster offen - du fuehrst jeden folgenden Befehl darin aus.

### 2. git

Installiere es:

- **macOS**
  ```bash
  brew install git
  ```
- **Windows**
  ```powershell
  winget install --id Git.Git -e
  ```
- **Linux** (Debian / Ubuntu; auf anderen den Paketmanager deiner Distribution nutzen)
  ```bash
  sudo apt update && sudo apt install -y git
  ```

Schliesse dann das Terminal und oeffne es erneut, damit es den neuen Befehl kennt, und pruefe:

```bash
git --version
```

Du solltest eine Zeile wie diese sehen (die Zahlen weichen ab):

```text
git version 2.43.0
```

### 3. Node

Node bringt `npm` mit, und genau das holt und startet `devblueprint`.

- **macOS**
  ```bash
  brew install node
  ```
- **Windows**
  ```powershell
  winget install --id OpenJS.NodeJS.LTS -e
  ```
- **Linux** (Debian / Ubuntu; installiert das aktuelle LTS von NodeSource)
  ```bash
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs
  ```

Oeffne das Terminal erneut und pruefe dann beide Befehle:

```bash
node --version
npm --version
```

Du solltest zwei Versionszeilen wie diese sehen (auch hier weichen die Zahlen ab):

```text
v22.14.0
10.9.2
```

### 4. Ein Code-Editor

Wir verwenden in dieser Anleitung durchgehend [Visual Studio Code](https://code.visualstudio.com)
(VS Code) - es ist kostenlos, laeuft auf allen drei Systemen, und DevBlueprint bringt
Einstellungen mit, die es gut zusammenspielen lassen.

- **macOS**
  ```bash
  brew install --cask visual-studio-code
  ```
- **Windows**
  ```powershell
  winget install --id Microsoft.VisualStudioCode -e
  ```
- **Linux** - lade die `.deb` / `.rpm` von
  [code.visualstudio.com/download](https://code.visualstudio.com/download) herunter und oeffne sie
  mit deinem Software-Installer, oder nutze den Store deiner Distribution.

Alle drei Installer fuegen deinem Terminal einen `code`-Befehl hinzu. Oeffne das Terminal erneut
und pruefe:

```bash
code --version
```

Du solltest drei Zeilen sehen - eine Versionsnummer, einen langen Commit-Hash und deine
Architektur:

```text
1.96.4
cd4ee3b1c348a13bafd8f9ad8060705f6d4b9cba
arm64
```

> Wenn `code` auf macOS `command not found` meldet, oeffne VS Code einmal, druecke
> Cmd+Shift+P, fuehre *Shell Command: Install 'code' command in PATH* aus und oeffne dann das
> Terminal erneut.

Wenn alle vier Pruefungen durchlaufen, hast du alles, was du brauchst. Sobald du DevBlueprint
selbst hast, kannst du die Grundlagen in einem Schritt bestaetigen, statt jeden Befehl einzeln zu
pruefen:

```bash
bin/devblueprint doctor --env
```

Es prueft, ob git, Node und eine funktionierende Shell vorhanden sind, und gibt, falls etwas
fehlt, den genauen Copy-paste-Befehl aus, um es auf deinem System zu installieren. Wenn es
*all prerequisites present* meldet, bist du bereit. Entscheide als Naechstes,
[wo das Projekt liegen soll](#einen-ordner-fuer-dein-projekt-waehlen).

## Einen Ordner fuer dein Projekt waehlen

Bevor du irgendetwas aufsetzt, musst du entscheiden, *wo auf deinem Computer* die Dateien des
Projekts liegen sollen. Dieser Ort ist einfach ein Ordner (auch Verzeichnis genannt). Jetzt einen
sinnvollen zu waehlen haelt alles aufgeraeumt, und ein paar der Regeln unten verhindern Fehler,
ueber die am Anfang fast alle stolpern.

### Was ein Pfad ist

Ein **Pfad** ist die Adresse einer Datei oder eines Ordners auf deinem Computer, so wie eine
Strassenadresse auf ein Haus zeigt. `~/Projects/myapp` ist ein Pfad; `/Users/you/Documents`
ebenso. Das Terminal ist immer in genau einem Ordner - deinem **Arbeitsverzeichnis** - und viele
Befehle wirken auf diesen Ordner, sofern du nichts anderes angibst.

### Absolute und relative Pfade

Es gibt zwei Arten, einen Pfad zu schreiben, und der Unterschied ist wichtig:

- Ein **absoluter Pfad** buchstabiert den vollstaendigen Ort von ganz oben auf deinem Laufwerk
  aus, also meint er denselben Ort, egal wo dein Terminal gerade ist. Auf macOS und Linux beginnt
  er mit einem Schraegstrich (`/Users/you/Projects/myapp`) oder mit der `~`-Abkuerzung unten; auf
  Windows beginnt er mit einem Laufwerksbuchstaben (`C:\Users\you\Projects\myapp`).
- Ein **relativer Pfad** wird ab deinem aktuellen Arbeitsverzeichnis gelesen. `myapp` heisst "ein
  Ordner namens `myapp` in dem Ordner, in dem ich gerade bin", `./myapp` meint dasselbe
  ausdruecklich, und `../myapp` heisst "eine Ebene hoeher, dann in `myapp`".

Faustregel fuer diese Anleitung: Wenn du DevBlueprint sagst, wohin ein Projekt soll (die
`--target`-Option, die du spaeter siehst), nimm einen **absoluten Pfad**. Dann tut der Befehl
dasselbe, egal in welchem Ordner dein Terminal gerade steckt.

### Was `~` bedeutet

`~` (eine "Tilde") ist die Kurzform fuer deinen **Home-Ordner** - `/Users/you` auf macOS,
`/home/you` auf Linux, `C:\Users\you` auf Windows. `~/Projects/myapp` ist also ein absoluter Pfad,
der zu `/Users/you/Projects/myapp` expandiert. Ein `~` zu schreiben haelt Befehle kurz und laesst
denselben Befehl auf einem anderen Rechner oder Benutzerkonto funktionieren.

Ein Haken: `~` wird vom Terminal expandiert, es funktioniert also nur, wenn du es im Terminal
tippst. Fuege einen `~`-Pfad nicht in einen grafischen "Ordner oeffnen"-Dialog ein - dort ist es
nur ein woertliches Zeichen, nicht dein Home-Ordner.

### Keine Leerzeichen (und Sonderzeichen) im Pfad

Benenne Ordner mit **Kleinbuchstaben, Ziffern und Bindestrichen** - `my-app`, `side-project-2`.
Vermeide Leerzeichen und Satzzeichen. Ein Leerzeichen ist fuer das Terminal die Trennung zwischen
einem Argument und dem naechsten, also wird ein Pfad wie `~/My Projects/app` als zwei getrennte
Dinge gelesen und der Befehl schlaegt fehl; du muesstest ihn jedes Mal in Anfuehrungszeichen
setzen. Akzentbuchstaben und Symbole sorgen fuer aehnliche Ueberraschungen. Nimm lieber
`~/Projects/my-app` statt `~/My Projects/My App`, dann denkst du nie wieder darueber nach.

### Eine gute Standardwahl: `~/Projects/<name>`

Im Zweifel bewahre deinen gesamten Code unter einem einzigen `~/Projects`-Ordner auf, mit einem
Unterordner pro Projekt. Ein Projekt namens `myapp` liegt dann unter `~/Projects/myapp`. Das ist
leicht zu merken, liegt nicht im Weg von Desktop und Downloads, und jedes Projekt steht neben
seinen Geschwistern.

Lege den `Projects`-Ordner einmal an (den Projektordner selbst musst du nicht anlegen - das
erledigt der Befehl `devblueprint init` im naechsten Abschnitt fuer dich):

```bash
mkdir -p ~/Projects
```

`mkdir` erstellt ein Verzeichnis; die Option `-p` legt fehlende uebergeordnete Ordner an und
bleibt still, falls der Ordner schon existiert, sodass der Befehl gefahrlos mehrfach ausgefuehrt
werden kann.

### Den Ordner im Terminal oeffnen

Um in einen Ordner zu "gehen", nutze im Terminal `cd` ("change directory") und bestaetige dann mit
`pwd` ("print working directory"), wo du gelandet bist:

```bash
cd ~/Projects/myapp
pwd
```

Du solltest den vollen absoluten Pfad ausgegeben bekommen, z. B. `/Users/you/Projects/myapp`. So
pruefst du, dass du am richtigen Ort bist, bevor du einen Befehl ausfuehrst, der auf den aktuellen
Ordner wirkt.

### Den Ordner im Editor oeffnen

Oeffne den **ganzen Ordner**, nicht eine einzelne Datei - nur so sieht der Editor das gesamte
Projekt (alle Dateien, die git-Historie, das Quality Gate) auf einmal. In VS Code, vom Terminal
aus:

```bash
code ~/Projects/myapp
```

Wenn deine Shell `command not found: code` meldet, oeffne VS Code einmal, druecke `Cmd+Shift+P`
(macOS) oder `Ctrl+Shift+P` (Windows/Linux), um die Befehlspalette zu oeffnen, und fuehre
**Shell Command: Install 'code' command in PATH** aus. Danach funktioniert der `code`-Befehl.

Keine Terminal-Abkuerzung? Du kannst auch immer zuerst den Editor oeffnen und
**File > Open Folder...** nutzen, dann den Ordner waehlen, den du erstellt hast. So oder so:
oeffne den Ordner statt einer einzelnen Datei.

## Dein erster Durchlauf

Zeit, ein echtes Projekt aufzusetzen. Wir bauen eines namens `hello-world` von nichts bis zu
seinem ersten Pull Request und fuehren jeden Befehl der Reihe nach aus. Kopiere jeden Block,
fuehre ihn aus und pruefe, dass das, was du siehst, zur gezeigten Ausgabe passt. Wenn ein Schritt
anders aussieht, halte dort an und vergleiche - es ist leichter, einen Schritt zu beheben als
zehn.

Jeder Befehl nutzt `devblueprint`, das Werkzeug, das du in den
[Voraussetzungen](#voraussetzungen) installiert hast. Wenn du die Installation uebersprungen hast
und nur Node besitzt, ersetze ueberall `devblueprint` durch `npx devblueprint` - das laedt und
startet dasselbe Werkzeug bei Bedarf.

Wir nutzen die Variante `generic`. Eine *Variante* ist die stack-spezifische Schicht (Next.js,
Python, Swift, ...); `generic` fuegt keine Sprach-Toolchain hinzu, also nichts extra zu
installieren, und das Quality Gate laeuft sofort. Sobald du dich sicher fuehlst, zeigt
`devblueprint list` die Varianten mit echten Stacks - tausche `--variant generic` spaeter gegen
eine davon.

### 1. Das Projekt aufsetzen

Das ist der eine Befehl, der alles erstellt. `--target` ist der Ort, an den der Projektordner
kommt (siehe [Einen Ordner waehlen](#einen-ordner-fuer-dein-projekt-waehlen) fuer das Warum von
`~/Projects/...`), `--name` ist der Name, und `--variant` ist der Stack.

```bash
devblueprint init --target ~/Projects/hello-world --name hello-world --variant generic
```

Du solltest sehen, wie es jede Datei auflistet, waehrend es sie schreibt, und dann einen
"Next steps"-Block:

```
Scaffolding 'hello-world' (Generic (language-agnostic)) into ~/Projects/hello-world
  branches: develop -> master   gate: make check
  agents: claude

  wrote docs/engineering/git-workflow.md
  ...
  wrote docs/project/backlog.md

Done. Next steps:
  1. cd ~/Projects/hello-world
  2. ./setup.sh   (wires configs + pre-commit hook + installs the toolchain)
  3. git init && git branch -M master && git switch -c develop
  4. Start a task in its own worktree:  ./scripts/wt.sh new feat/first-task
```

> **Tipp:** Willst du sehen, was ein Befehl tut, bevor er deine Festplatte anfasst? Fuehre zuerst
> `devblueprint plan ...` mit denselben Flags aus. Es gibt genau das aus, was `init` schreiben
> wuerde, und aendert nichts. `init` kann ausserdem gefahrlos erneut ausgefuehrt werden - es
> ueberschreibt nie eine Datei, die du schon hast.

Die naechsten Schritte sind deine Checkliste. Wir gehen jeden davon durch.

### 2. In den Ordner wechseln und die Toolchain einrichten

```bash
cd ~/Projects/hello-world
./setup.sh
```

`setup.sh` richtet die lokalen Pruefungen ein, die vor jedem Commit automatisch laufen. Du
solltest sehen:

```
Wiring the generic toolchain...
  wrote .githooks/pre-commit
  not a git repo yet - after 'git init' run: git config core.hooksPath .githooks

Toolchain wired.
```

Es erinnert dich daran, dass der Pre-commit-Hook erst aktiv wird, sobald der Ordner ein
git-Repository ist - was genau der naechste Schritt ist.

### 3. Unter Versionskontrolle stellen

Hier passieren drei Dinge: `git init` macht aus dem Ordner ein Repository, die `config`-Zeile
schaltet den Pre-commit-Hook ein, den `setup.sh` gerade geschrieben hat, und der erste Commit
haelt alles fest, was das Geruest erstellt hat.

```bash
git init
git config core.hooksPath .githooks
git add -A
git commit -m "chore: scaffold project with DevBlueprint"
```

Erstelle nun die zwei langlebigen Branches. `master` ist der stabile, immer funktionierende
Branch; `develop` ist der Ort, an dem die taegliche Arbeit zuerst integriert wird. Du verbringst
deine Zeit auf `develop` und auf Branches davon.

```bash
git branch -M master
git switch -c develop
```

Du solltest jetzt auf `develop` sein, mit einem Commit:

```
Switched to a new branch 'develop'
```

### 4. Pruefen, dass das Fundament stimmt

`doctor` prueft, dass jede Datei, die das Geruest erzeugt haben sollte, vorhanden und der Hook
verdrahtet ist. Das ist deine "hat es geklappt"-Bestaetigung fuer den ganzen Durchlauf.

```bash
devblueprint doctor --target .
```

Jede Zeile sollte `ok` lauten und mit einer Entwarnung enden:

```
  ok    CLAUDE.md
  ok    CONTRIBUTING.md
  ...
  ok    pre-commit hook wired

doctor: all foundation files present (scaffolded from DevBlueprint 0.1.0; current 0.1.0)
```

### 5. Das Remote anlegen und pushen

Der Arbeitsablauf erstellt jede Aufgabe in einem eigenen *Worktree* (naechster Abschnitt), und
dafuer braucht es eine Kopie deines Repositorys auf GitHub, von der aus verzweigt wird. Der
`gh`-Befehl unten erstellt das GitHub-Repository und pusht beide Branches in einem Schritt (`gh`
ist GitHubs offizielles Kommandozeilenwerkzeug; falls du es nicht hast, erstelle ein leeres
Repository auf github.com und folge stattdessen dessen "push an existing repository"-Zeilen).

```bash
gh repo create hello-world --private --source=. --remote=origin --push
git push -u origin develop
```

Damit ist dein erster Durchlauf abgeschlossen: ein vollstaendig aufgesetztes Projekt, unter git,
mit beiden Branches auf GitHub. Als Naechstes machen wir eine echte Aenderung.

## Deine erste Aufgabe

Jede Arbeit - ein Fix, ein neues Feature, eine Doku-Anpassung - folgt derselben kurzen Schleife:
verzweigen, aendern, pruefen, committen, pushen, Pull Request. Es einmal hier zu tun macht jede
kuenftige Aenderung zur Routine. Unsere Aufgabe: dem Projekt eine `README.md` hinzufuegen.

### 1. Die Aufgabe in einem eigenen Worktree starten

Ein *Worktree* ist ein eigener Ordner, der einen Branch enthaelt, sodass jede Aufgabe isoliert
bleibt und sich dein Hauptordner nie unter dir veraendert. `wt.sh new` erstellt einen, verzweigt
von `develop`. Der Name ist `<type>/<short-slug>` - hier `docs`, weil wir Dokumentation
hinzufuegen.

```bash
./scripts/wt.sh new docs/add-readme
```

Es gibt den Pfad aus, in dem du arbeitest - kopiere diese `cd`-Zeile und fuehre sie aus:

```
Worktree ready for 'docs/add-readme':
  cd /path/to/.worktrees/hello-world/docs-add-readme
Do all work there. The hello-world clone stays on master.
```

```bash
cd /path/to/.worktrees/hello-world/docs-add-readme
```

### 2. Die Aenderung machen

Erstelle eine `README.md`, wie du magst - mit deinem Editor oder mit diesem Einzeiler:

```bash
printf '# hello-world\n\nMy first project, scaffolded with DevBlueprint.\n' > README.md
```

### 3. Das Quality Gate ausfuehren

Bevor du irgendetwas committest, fuehre das Gate aus. Es ist derselbe Satz Pruefungen, den CI
ausfuehrt, also bedeutet ein lokales Bestehen keine Ueberraschungen spaeter. Fuer die Variante
`generic` ist das:

```bash
make check
```

In einem frischen generic-Projekt sind die Pruefungen Platzhalter (sie geben `TODO: wire the ...`
aus) und der Befehl endet ohne Fehler - das ist ein bestandenes, "gruenes" Gate. In einer Variante
mit echtem Stack fuehrt derselbe Befehl Linter, Typpruefer, Tests und Build fuer dich aus.

```
check-env: environment configuration is valid
TODO: wire the linter for this project
TODO: wire the type checker (or remove this target)
TODO: wire the test runner
TODO: wire the build/compile step
```

Lieber einen Knopf als einen auswendig gelernten Befehl? Jedes Projekt bringt eine
`.vscode/tasks.json` mit, also kannst du in VS Code `Cmd+Shift+B` (macOS) oder `Ctrl+Shift+B`
(Windows/Linux) druecken, um das ganze Gate auszufuehren, oder **Terminal > Run Task...** oeffnen,
um einen einzelnen Schritt zu waehlen (Lint, Tests, Build). Die Aufgabe fuehrt das echte Gate
deiner Variante aus - dasselbe, das CI ausfuehrt - also bleibt es ehrlich, waehrend du die
Pruefungen verdrahtest.

### 4. Committen

Halte die Aenderung mit einer kurzen, strukturierten Nachricht fest. Das Praefix `docs:` ist ein
[Conventional-Commit](../../CONTRIBUTING.md)-Typ - es sagt, *welche Art* von Aenderung das ist.

```bash
git add README.md
git commit -m "docs: add project README"
```

### 5. Pushen und einen Pull Request oeffnen

Pushe den Branch zu GitHub und oeffne dann einen *Pull Request* (PR) - eine Anfrage, deine
Aenderung in `develop` zu mergen, wo sie vor dem Landen geprueft werden kann.

```bash
git push -u origin docs/add-readme
gh pr create --base develop --fill
```

`gh` gibt die URL des neuen Pull Requests aus:

```
https://github.com/<you>/hello-world/pull/1
```

Das ist dein erster gruener PR. In einem echten Projekt prueft ihn jemand und merged ihn in
`develop`; in deinem eigenen Projekt kannst du ihn von dieser Seite aus selbst mergen.

### 6. Nach dem Merge aufraeumen

Sobald der PR gemerged ist, entferne den fertigen Worktree und seinen Branch mit einem Befehl
(fuehre ihn aus deinem Hauptprojektordner aus):

```bash
cd ~/Projects/hello-world
./scripts/wt.sh gc
```

Starte dann die naechste Aufgabe wieder mit `./scripts/wt.sh new ...`. Diese Schleife -
verzweigen, aendern, pruefen, committen, pushen, PR, aufraeumen - ist der gesamte alltaegliche
Arbeitsablauf. Alles andere in dieser Doku ist nur Detail obendrauf.

## Wie es weitergeht

- [Zero-install-Setup: Codespaces und Dev Containers](../../docs/codespaces.md) - oeffne jedes
  Projekt in einer fertigen Cloud-Umgebung, ohne lokale Installation.
- [README](../../README.md) - die schnelle Uebersicht und die vollstaendige Befehlsreferenz.
- [`CONTRIBUTING.md`](../../CONTRIBUTING.md) - der taegliche Prozess im Detail.
- [`docs/`](../../docs/) - die Engineering-Standards, Konventionen und der Qualitaetsmassstab
  hinter dem Arbeitsablauf.
