# Glossar

> Deutsche Uebersetzung von [`docs/glossary.md`](../../../docs/glossary.md). Die englische
> Fassung ist massgeblich; bei Abweichungen gilt das Original.

Verstaendliche Definitionen der Begriffe, die in der Dokumentation dieses Repos vorkommen. Je ein
Satz; wenn eine Doku ein Wort verwendet, das du nicht kennst, schlage es zuerst hier nach. An
anderer Stelle in der Doku verweist die erste Nennung jedes Begriffs direkt auf seinen Eintrag
hier unten.

- <a id="terminal"></a>**Terminal** - das Textfenster, in dem du Befehle eingibst und ihre
  Ausgabe liest, statt auf Schaltflaechen zu klicken.
- <a id="path"></a>**Path** - die Adresse einer Datei oder eines Ordners auf deinem Computer, etwa
  `docs/glossary.md` oder `/Users/you/projects`.
- <a id="repo"></a>**Repo** - kurz fuer "Repository": der Ordner, der die Dateien deines Projekts
  zusammen mit der vollstaendigen Historie jeder von git aufgezeichneten Aenderung enthaelt.
- <a id="branch"></a>**Branch** - ein benannter, paralleler Arbeitsstrang im Repo, sodass du Dinge
  aendern kannst, ohne die Hauptversion zu stoeren, bis du bereit bist.
- <a id="commit"></a>**Commit** - ein gespeicherter Schnappschuss deiner Aenderungen mit einer
  kurzen Nachricht, die sie beschreibt; die kleinste Einheit der Historie in git.
- <a id="pr"></a>**PR** - kurz fuer "Pull Request": ein Vorschlag, die Commits eines Branches in
  einen anderen zu ueberfuehren (mergen), den andere pruefen, bevor er angenommen wird.
- <a id="worktree"></a>**Worktree** - ein separater Ordner, der auf seinen eigenen Branch
  ausgecheckt ist, sodass du an mehreren Branches gleichzeitig arbeiten kannst, ohne in einem
  Ordner hin- und herzuwechseln.
- <a id="ci"></a>**CI** - kurz fuer "Continuous Integration": der automatisierte Dienst, der deine
  Pruefungen (Build, Lint, Tests) bei jedem Push ausfuehrt, damit Probleme frueh auffallen.
- <a id="lint"></a>**Lint** - eine automatisierte Pruefung, die Stilprobleme und wahrscheinliche
  Fehler im Code markiert, bevor ein Mensch sie bemerken muss.
- <a id="variant"></a>**Variant** - eine der stack-spezifischen Auspraegungen dieses Blueprints
  (zum Beispiel ein backend-go- oder sveltekit-Setup), die ihr eigenes Tooling ueber die
  gemeinsame Grundlage legt.
- <a id="quality-gate"></a>**Quality gate** - der eine Befehl (`make check`), der vor dem Push
  erfolgreich sein muss und die Lint-, Typecheck-, Test- und Build-Schritte des Projekts
  buendelt.
