> Deutsche Uebersetzung von [`docs/faq.md`](../../../docs/faq.md). Die englische
> Fassung ist massgeblich; bei Abweichungen gilt das Original.

# FAQ

Die "Warum ist das passiert, und was mache ich jetzt?"-Momente, ueber die am Anfang fast alle
stolpern. Jeder Eintrag benennt das Symptom, erklaert, warum es passiert, und nennt dir die eine
Sache, die du als Naechstes tun solltest. Wenn dir hier ein Wort neu ist, wirf zuerst einen Blick
ins [Glossar](glossary.md).

## "Das Verzeichnis existiert bereits" (oder eine Datei wurde uebersprungen)

**Was du siehst.** Wenn du in einen Ordner scaffoldest, der bereits Dateien enthaelt, erscheinen
Zeilen wie `skip README.md (exists; --force to overwrite)`, oder `wt.sh` verweigert den Dienst mit
`worktree folder already exists: <path>`.

**Warum.** Das ist ein Sicherheitsnetz, kein Fehler. Die Werkzeuge ueberschreiben vorhandene
Dateien nie, ausser du verlangst es ausdruecklich - du kannst also keine Arbeit verlieren, wenn du
einen Befehl zweimal ausfuehrst. Eine `skip`-Zeile bedeutet, dass diese eine Datei schon da war und
unberuehrt blieb; alles andere wurde trotzdem geschrieben.

**Was zu tun ist.** Waehle eine Option:

- Wenn das genau die Dateien sind, die du willst, bist du fertig - die Skips sind erwartet.
- Wenn du in einem leeren Ordner neu anfangen wolltest, waehle einen neuen, leeren
  [Pfad](glossary.md#path) (siehe
  [Einen Ordner waehlen](../GETTING-STARTED.md#choosing-a-folder-for-your-project)) und fuehre den
  Befehl erneut aus.
- Wenn du wirklich ersetzen willst, was dort liegt, fuehre den Befehl erneut mit `--force` aus -
  aber erst, wenn du sicher bist, dass nichts in diesem Ordner wichtig ist.

## "Not a git repository"

**Was du siehst.** Ein Git-Befehl oder `devblueprint doctor` meldet
`not a git repository - run git init`. Ein einfaches `git status` sagt
`fatal: not a git repository (or any of the parent directories)`.

**Warum.** Git verfolgt nur Ordner, die zu einem **[Repo](glossary.md#repo)** gemacht wurden (ein
Ordner mit einer versteckten `.git`-Historie darin). Der Ordner, in dem du stehst, wurde nie
initialisiert, oder du bist eine Ebene ueber dem Projekt und musst hineinwechseln.

**Was zu tun ist.**

- Wenn du im falschen Ordner bist, wechsle mit `cd` in das Projektverzeichnis und versuche es
  erneut - mit `pwd` siehst du, wo du tatsaechlich bist.
- Wenn dieser Ordner wirklich ein neues Projekt ohne Historie ist, fuehre einmal `git init` aus, um
  das Repo zu erstellen, und mach dann weiter.

## "Der Quality Gate ist rot" (`make check` fehlgeschlagen)

**Was du siehst.** `make check` bricht mit einem Fehler ab, oder `doctor --run-gate` meldet
`quality gate failed`. Die Ausgabe scrollt vorbei mit einer [Lint](glossary.md#lint)-Beschwerde,
einem fehlgeschlagenen Test oder einem Typfehler.

**Warum.** Der [Quality Gate](glossary.md#quality-gate) buendelt die Lint-, Typecheck-, Test- und
Build-Schritte des Projekts in einem einzigen Befehl, und er *soll* fehlschlagen, sobald einer
davon ein Problem findet - genau das ist seine Aufgabe. Ein roter Gate ist die Pruefung bei der
Arbeit, die etwas abfaengt, bevor es die [CI](glossary.md#ci) erreicht.

**Was zu tun ist.** Push noch nicht - behebe es zuerst lokal.

- Lies die Ausgabe von *oben*, nicht von unten: Der erste Fehler ist meist die eigentliche Ursache,
  und spaetere Zeilen sind oft nur Folgerauschen.
- Viele Lint- und Formatierungsprobleme loesen sich von selbst - fuehre den Gate nach dem Speichern
  erneut aus und pruefe, ob das Werkzeug eine automatische Korrektur anbietet.
- Behebe eine Sache, fuehre dann erneut `make check` aus. Wiederhole, bis es durchlaeuft. Erst dann
  push.

## "Ich bin auf dem falschen Branch" (oder auf `develop`/`master` committet)

**Was du siehst.** `git status` zeigt `On branch develop` (oder `master`), obwohl du einen
Feature-[Branch](glossary.md#branch) erwartet hast, oder du merkst, dass ein
[Commit](glossary.md#commit) irgendwo gelandet ist, wo er nicht hingehoert.

**Warum.** In diesem Repo arbeitest du nie direkt auf den langlebigen Branches: `master` bleibt
deploybar und `develop` ist der gemeinsame Integrations-Branch. Jede Aufgabe bekommt ihren
**eigenen** [Worktree](glossary.md#worktree) und Branch, erstellt mit
`scripts/wt.sh new <type>/<slug>`, damit parallele Arbeit nie kollidiert. Auf `develop` zu landen
bedeutet meist, dass der Worktree-Schritt uebersprungen wurde.

**Was zu tun ist.**

- Wenn du **noch nichts committet hast**, erstelle einfach den Worktree, in dem du haettest starten
  sollen: `scripts/wt.sh new <type>/<slug>` zweigt vom aktuellen `develop` ab und gibt einen Pfad
  aus - erledige dort deine gesamte Arbeit.
- Wenn du **bereits auf den falschen Branch committet hast**, halte vor dem Push inne und bitte um
  Hilfe beim Verschieben des Commits, statt zu raten - die Loesung (ein Branch plus ein Reset) ist
  einfach, aber leicht falsch zu machen. Siehe [den Git-Workflow](engineering/git-workflow.md), wie
  die Branches zusammenpassen.

---

Immer noch festgefahren oder auf etwas gestossen, das hier nicht steht? Oeffne ein Issue oder frag
im Kanal deines Teams - ein fehlender Eintrag ist es wert, ergaenzt zu werden.
