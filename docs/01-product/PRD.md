# PRD: Agent Project Kit

## 1. Produktname

Agent Project Kit

## 2. Kurzbeschreibung

Agent Project Kit ist ein Open-Source-CLI- und Template-System fuer AI-gestuetzte Softwareentwicklung. Es hilft Solo-Buildern, kleinen Teams und Entwicklern, die mit Tools wie Claude Code, Codex, Cursor oder anderen AI-Coding-Agenten arbeiten, ihre Projekte von Beginn an professionell zu strukturieren.

Das Tool erzeugt auf Basis weniger Terminal-Eingaben eine standardisierte Projektstruktur mit Produktdokumenten, Architekturdateien, Feature-Spezifikationen, Agenten-Regeln, Task-Dateien, Qualitaetschecklisten und optionalen Source-/Testordnern fuer verschiedene Projekttypen.

Ziel ist es, chaotisches Vibecoding in einen klaren, spec-driven Entwicklungsprozess zu ueberfuehren.

---

## 3. Problem

AI-Coding-Tools ermoeglichen es heute, sehr schnell Software zu bauen. Viele Nutzer starten jedoch ohne klare Struktur, ohne MVP-Grenzen, ohne saubere Architekturentscheidungen und ohne dokumentierte Anforderungen.

Dadurch entstehen typische Probleme:

- Projekte wachsen unkontrolliert.
- Features werden gebaut, bevor klar ist, ob sie zum MVP gehoeren.
- AI-Agenten erhalten zu viel, zu wenig oder falschen Kontext.
- Anforderungen, Architektur und Tasks sind nicht sauber getrennt.
- Neue AI-Sessions verlieren den bisherigen Projektkontext.
- Code wird erzeugt, ohne dass Akzeptanzkriterien oder Qualitaetsregeln existieren.
- Solo-Builder wissen oft nicht, welche Dokumente, Ordner und Standards sie ueberhaupt brauchen.
- Kleine Projekte wirken schnell wie Prototypen, obwohl sie langfristig wartbar sein sollen.

Das Kernproblem ist nicht, dass Nutzer keinen Code generieren koennen. Das Kernproblem ist, dass sie kein professionelles Projektsystem haben, das AI-Coding sauber steuert.

---

## 4. Ziel

Agent Project Kit soll eine standardisierte Grundlage fuer AI-gestuetzte Softwareprojekte bereitstellen.

Das Produkt soll Nutzern helfen:

- ein neues Projekt sauber zu initialisieren,
- Produktidee, MVP und Non-Goals zu dokumentieren,
- Architekturentscheidungen festzuhalten,
- Features in klaren Spezifikationen zu beschreiben,
- Aufgaben fuer AI-Agenten kontrollierbar zu machen,
- relevante Kontextdateien fuer AI-Coding-Sessions bereitzustellen,
- Source- und Testordner passend zum Projekttyp anzulegen,
- Best Practices ohne grosses Vorwissen zu uebernehmen,
- Scope Creep zu reduzieren,
- professionelle Softwareentwicklung auch als Solo-Builder besser umzusetzen.

---

## 5. Nicht-Ziele

Agent Project Kit soll in der ersten Version nicht:

- eine eigene IDE sein,
- einen eigenen AI-Agenten ersetzen,
- Code automatisch vollstaendig implementieren,
- eine Cloud-Plattform sein,
- Login, Accounts oder Team-Verwaltung enthalten,
- ein Jira-, Linear- oder Notion-Ersatz sein,
- ein vollwertiges Projektmanagementsystem sein,
- automatisch perfekte Architekturentscheidungen treffen,
- bestehende Repositories tiefgehend analysieren,
- kostenpflichtige AI-APIs voraussetzen.

Das Produkt soll bewusst lokal, einfach, transparent und Open Source bleiben.

---

## 6. Zielgruppe

### 6.1 Primaere Zielgruppe

Solo-Builder, Indie-Hacker, Entwickler, Studenten mit fortgeschrittenem technischem Interesse und kleine Teams, die AI-Coding-Tools verwenden und ihre Projekte professioneller strukturieren moechten.

Typische Nutzer:

- Personen, die mit Claude Code, Codex, Cursor oder ChatGPT Software bauen.
- Entwickler, die haeufig neue MVPs oder Prototypen starten.
- Solo-Founder, die ihre Idee sauber strukturieren wollen.
- Kleine Agenturen oder Teams, die wiederholbare Projektstandards brauchen.
- Junior Developer, die lernen moechten, wie professionelle Projektstruktur aussieht.

### 6.2 Sekundaere Zielgruppe

- Open-Source-Maintainer
- Tech-Blogger
- AI-Tool-Enthusiasten
- Teams, die interne Standards fuer AI-Coding definieren moechten

---

## 7. Nutzer-Personas

### Persona 1: Solo-Builder

Der Solo-Builder hat eine Produktidee und nutzt AI-Tools, um schneller zu bauen. Er kann einfache technische Entscheidungen treffen, verliert aber schnell den Ueberblick ueber Features, Architektur, Tasks und Prioritaeten.

Beduerfnis:

- schnell starten,
- klare Struktur erhalten,
- MVP nicht ueberladen,
- AI-Agenten mit gutem Kontext versorgen.

### Persona 2: Junior Developer

Der Junior Developer moechte lernen, wie man ein Softwareprojekt professionell strukturiert. Er weiss oft nicht, welche Dokumente, Ordner und Standards sinnvoll sind.

Beduerfnis:

- Beispiele,
- Vorlagen,
- klare Erklaerungen,
- Best Practices,
- wiederverwendbare Projektstruktur.

### Persona 3: Kleines Team oder Agentur

Ein kleines Team baut regelmaessig Web-Apps, interne Tools oder MVPs. Jedes Projekt startet etwas anders, wodurch Qualitaet und Struktur schwanken.

Beduerfnis:

- standardisierte Initialisierung,
- konsistente Dokumentation,
- klare Agenten-Regeln,
- wiederholbare Projekt-Setups.

---

## 8. Produktprinzipien

Agent Project Kit folgt diesen Prinzipien:

### 8.1 Spec-first statt Code-first

Jedes Projekt soll zuerst ueber Ziel, Scope, Architektur und Features beschrieben werden, bevor Code geschrieben wird.

### 8.2 Opinionated, aber anpassbar

Das Tool soll klare Empfehlungen geben. Nutzer sollen nicht vor einem leeren Blatt stehen. Gleichzeitig muessen Dateien und Templates leicht anpassbar sein.

### 8.3 Lokal und transparent

Alle generierten Dateien liegen im Projektverzeichnis. Es gibt keine versteckte Cloud-Logik und keine proprietaeren Datenformate.

### 8.4 AI-tool-agnostisch

Das System soll mit verschiedenen AI-Coding-Tools funktionieren, darunter Claude Code, Codex, Cursor, GitHub Copilot und generische LLM-Chats.

### 8.5 Kontext statt Chaos

AI-Agenten sollen nicht das gesamte Projekt ungefiltert lesen muessen. Das Tool soll helfen, relevante Kontextdateien fuer konkrete Aufgaben zu buendeln.

### 8.6 MVP-Schutz

Neue Ideen sollen nicht automatisch gebaut werden. Sie sollen gegen den MVP-Scope geprueft und entweder eingeordnet, verschoben oder als offene Frage markiert werden.

### 8.7 Beispiele vor Theorie

Das Repo soll viele Beispiele enthalten, weil Nutzer oft nicht wissen, was sie eigentlich brauchen oder wie gute Projektdateien aussehen.

---

## 9. Kernfunktionen

### 9.1 Projektinitialisierung

Der Nutzer kann ueber einen Terminal-Befehl ein neues Projekt initialisieren.

Beispiel:

```bash
npx agent-project-kit init
```

Das CLI fragt grundlegende Informationen ab:

- Projektname
- Projekttyp
- Framework oder Tech-Stack
- Projektphase
- bevorzugtes AI-Coding-Tool
- gewuenschte Strenge der Standards
- Zielverzeichnis

Beispielauswahl:

```txt
Project type:
- Web App
- API Backend
- iOS App
- React Native App
- Portfolio
- Internal Tool
- Custom

Framework:
- Next.js
- Vite + React
- FastAPI
- SwiftUI
- React Native
- Other

Project maturity:
- Idea only
- MVP planning
- Existing codebase
- Refactor existing project

AI tool:
- Claude Code
- Cursor
- Codex
- GitHub Copilot
- Generic LLM
```

Output:

Das Tool erstellt im Zielverzeichnis eine passende Projektstruktur mit Dokumenten, Agenten-Dateien, Feature-Specs und optionalen Source-/Testordnern.

---

### 9.2 Generierte Basisdokumente

Jedes Projekt erhaelt standardmaessig eine Dokumentationsstruktur.

Beispiel:

```txt
docs/
  00-inbox/
    questions.md
    raw-ideas.md
    decisions-needed.md

  01-product/
    PRD.md
    MVP-FREEZE.md
    USER-STORIES.md
    NON-GOALS.md
    ROADMAP.md

  02-architecture/
    ARCHITECTURE.md
    TECH-STACK.md
    FILETREE.md
    DATA-MODEL.md
    API-CONTRACTS.md
    SECURITY.md

  03-features/
    _feature-template.md

  04-tasks/
    NOW.md
    NEXT.md
    BACKLOG.md
    BLOCKED.md
    DONE.md

  05-quality/
    ACCEPTANCE-CRITERIA.md
    TEST-PLAN.md
    REVIEW-CHECKLIST.md
    RELEASE-CHECKLIST.md

  06-agent-context/
    CODING-RULES.md
    OUTPUT-RULES.md
    CONTEXT-RULES.md
    PROMPTS.md
```

---

### 9.3 AGENTS.md Generator

Das Tool erstellt eine zentrale `AGENTS.md` Datei.

Diese Datei enthaelt Regeln fuer AI-Agenten, zum Beispiel:

- welche Projektdateien wichtig sind,
- welche Ordnerstruktur eingehalten werden muss,
- wie Codeaenderungen dokumentiert werden sollen,
- welche Dateien nicht ohne Zustimmung geaendert werden duerfen,
- wie Tests ausgefuehrt werden,
- welche Coding-Konventionen gelten,
- wie neue Features geplant werden muessen.

Beispielinhalt:

```md
# AGENTS.md

## Role

You are assisting with a spec-driven software project. Do not implement features before reading the relevant product, architecture, and feature documents.

## Rules

- Read `docs/01-product/MVP-FREEZE.md` before suggesting new scope.
- Every new feature must have a feature spec in `docs/03-features/`.
- Do not change architecture decisions without updating `docs/02-architecture/ARCHITECTURE.md`.
- After implementation, update relevant task files.
- Prefer small, reviewable changes.
- Do not add dependencies without explaining why.
```

---

### 9.4 Projekttyp-spezifische Templates

Das Tool unterstuetzt verschiedene Projekttypen.

#### Web App

Beispielstruktur:

```txt
src/
  app/
  components/
  features/
  lib/
  server/
  styles/

tests/
  unit/
  integration/
  e2e/
```

Zusaetzliche Dokumente:

```txt
docs/02-architecture/ROUTES.md
docs/02-architecture/AUTH.md
docs/02-architecture/API-CONTRACTS.md
```

#### API Backend

Beispielstruktur:

```txt
app/
  routes/
  services/
  repositories/
  models/
  schemas/
  core/

tests/
  unit/
  integration/
```

Zusaetzliche Dokumente:

```txt
docs/02-architecture/API-CONTRACTS.md
docs/02-architecture/DATABASE.md
docs/02-architecture/SECURITY.md
```

#### iOS App

Beispielstruktur:

```txt
Sources/
  App/
  Features/
  Shared/
  Core/
  DesignSystem/

Tests/
  UnitTests/
  UITests/
```

Zusaetzliche Dokumente:

```txt
docs/02-architecture/NAVIGATION.md
docs/02-architecture/STATE-MANAGEMENT.md
docs/05-quality/ACCESSIBILITY-CHECKLIST.md
docs/05-quality/APP-STORE-READINESS.md
```

#### Portfolio

Beispielstruktur:

```txt
src/
  components/
  content/
  pages/
  styles/

docs/
  01-product/
  02-architecture/
  03-features/
```

Zusaetzliche Dokumente:

```txt
docs/01-product/PERSONAL-BRANDING.md
docs/01-product/CONTENT-PLAN.md
```

---

### 9.5 Feature-Spec Generator

Der Nutzer kann ueber das CLI eine neue Feature-Spezifikation erstellen.

Beispiel:

```bash
apkit add feature
```

Das CLI fragt:

- Feature-Name
- Problem
- Ziel
- Nutzer
- MVP-Relevanz
- Akzeptanzkriterien
- betroffene Dateien oder Module
- Abhaengigkeiten
- offene Fragen

Output:

```txt
docs/03-features/auth.feature.md
```

Beispielstruktur:

```md
# Feature Spec: Authentication

## Status

Draft

## Problem

Users need a secure way to access private project data.

## Goal

Allow users to create an account, log in, log out, and maintain a secure session.

## Non-Goals

- OAuth
- Team accounts
- Passwordless login
- Admin dashboard

## User Stories

- As a user, I want to create an account.
- As a user, I want to log in securely.
- As a user, I want to log out.

## Acceptance Criteria

- User can register with email and password.
- Passwords are securely hashed.
- Invalid login attempts return clear errors.
- Auth state is persisted securely.
- Tests cover successful and failed login.

## Open Questions

- Should email verification be required for MVP?
```

---

### 9.6 MVP-Freeze System

Das Projekt enthaelt eine zentrale Datei:

```txt
docs/01-product/MVP-FREEZE.md
```

Diese Datei definiert:

- MVP-Ziel
- erlaubte Features
- explizit ausgeschlossene Features
- Entscheidungsregel fuer neue Ideen
- Validierungskriterium fuer das MVP

Beispiel:

```md
# MVP Freeze

## MVP Goal

Build the smallest version that validates the core product value.

## Allowed in MVP

- Project initialization
- Base documentation generation
- AGENTS.md generation
- Feature spec generation
- Basic examples

## Not Allowed in MVP

- Cloud sync
- User accounts
- Web dashboard
- Paid plans
- Full AI integration
- GitHub App

## Rule

If a feature does not directly support the MVP goal, move it to BACKLOG.md.
```

---

### 9.7 Context Packs

Das Tool kann ausgeben, welche Dateien fuer eine bestimmte AI-Coding-Session relevant sind.

Beispiel:

```bash
apkit context auth
```

Output:

```txt
For the next AI coding session, load these files:

1. AGENTS.md
2. docs/01-product/PRD.md
3. docs/01-product/MVP-FREEZE.md
4. docs/02-architecture/AUTH.md
5. docs/03-features/auth.feature.md
6. docs/05-quality/TEST-PLAN.md

Task instruction:
Implement only the authentication scope described in auth.feature.md.
Do not modify unrelated features.
Update docs/04-tasks/NOW.md after completion.
```

Ziel:

AI-Agenten sollen praezisen Kontext erhalten, statt unkontrolliert das gesamte Projekt zu lesen.

---

### 9.8 Decision Records

Das Tool ermoeglicht das Anlegen von Architekturentscheidungen.

Beispiel:

```bash
apkit add decision
```

Output:

```txt
docs/02-architecture/decisions/0001-use-nextjs.md
```

Template:

```md
# Decision: Use Next.js

## Status

Accepted

## Context

The project requires a web frontend with routing, server-side rendering options, and a strong ecosystem.

## Decision

Use Next.js as the primary web framework.

## Alternatives Considered

- Vite + React
- Remix
- Astro

## Consequences

Positive:
- Strong ecosystem
- Good deployment support
- Familiar structure

Negative:
- More framework complexity
- Potential overkill for very small apps
```

---

### 9.9 Examples

Das Repo soll umfangreiche Beispiele enthalten.

Beispiele:

```txt
examples/
  web-saas/
  ios-habit-app/
  fastapi-api/
  portfolio-site/
  internal-tool/
```

Jedes Beispiel enthaelt:

- ausgefuellte PRD
- MVP-Freeze
- Architekturdateien
- Feature-Specs
- Tasks
- AGENTS.md
- Beispiel-Source-Tree

Ziel:

Nutzer sollen nicht bei null anfangen, sondern gute Beispiele uebernehmen und anpassen koennen.

---

### 9.10 Prompt Library

Das Repo enthaelt wiederverwendbare Prompts fuer verschiedene Aufgaben.

Beispiele:

```txt
prompts/
  init-project.md
  create-feature-spec.md
  mvp-freeze-check.md
  architecture-review.md
  task-breakdown.md
  code-review.md
  update-docs-after-change.md
```

Diese Prompts sollen mit Claude Code, Codex, Cursor oder generischen LLMs funktionieren.

---

## 10. CLI-Befehle

Fuer Version 0.1 sind folgende Befehle geplant:

```bash
apkit init
```

Initialisiert ein Projekt.

```bash
apkit add feature
```

Erstellt eine neue Feature-Spec.

```bash
apkit add decision
```

Erstellt einen Architecture Decision Record.

```bash
apkit context
```

Erzeugt eine Liste relevanter Kontextdateien fuer eine AI-Coding-Session.

```bash
apkit doctor
```

Prueft, ob zentrale Projektdateien fehlen.

```bash
apkit examples
```

Listet verfuegbare Beispielprojekte und Templates.

---

## 11. Anforderungen

### 11.1 Funktionale Anforderungen

#### FR-1: Projektinitialisierung

Das CLI muss ein neues Projektverzeichnis oder ein bestehendes Verzeichnis initialisieren koennen.

Akzeptanzkriterien:

- Nutzer kann Zielverzeichnis auswaehlen.
- Bestehende Dateien werden nicht ohne Warnung ueberschrieben.
- Das Tool erzeugt eine vollstaendige Dokumentationsstruktur.
- Das Tool erzeugt je nach Projekttyp passende Source- und Testordner.

#### FR-2: Template-Auswahl

Das CLI muss passende Templates basierend auf Projekttyp und Framework auswaehlen.

Akzeptanzkriterien:

- Web App erzeugt Web-App-spezifische Dateien.
- iOS App erzeugt iOS-spezifische Dateien.
- API Backend erzeugt Backend-spezifische Dateien.
- Custom erzeugt nur Base-Struktur.

#### FR-3: AGENTS.md-Erzeugung

Das CLI muss eine Agenten-Regeldatei erzeugen.

Akzeptanzkriterien:

- Datei enthaelt Projekttyp, Regeln, Testbefehle und Kontextregeln.
- Datei ist editierbar.
- Datei verweist auf relevante Dokumente.

#### FR-4: Feature-Spec-Erzeugung

Das CLI muss neue Feature-Spec-Dateien erzeugen koennen.

Akzeptanzkriterien:

- Dateiname wird aus Feature-Name generiert.
- Template enthaelt alle Pflichtabschnitte.
- Nutzer kann zwischen leerem und gefuehrtem Modus waehlen.

#### FR-5: Context-Pack-Ausgabe

Das CLI muss relevante Dateien fuer eine Aufgabe vorschlagen koennen.

Akzeptanzkriterien:

- Output ist kopierbar.
- Output enthaelt Dateiliste.
- Output enthaelt kurze Arbeitsanweisung fuer AI-Agenten.
- Output beruecksichtigt Feature-Dateien, falls vorhanden.

#### FR-6: Doctor-Check

Das CLI muss pruefen koennen, ob wichtige Dateien fehlen.

Akzeptanzkriterien:

- Fehlende Basisdateien werden angezeigt.
- Optional kann das Tool fehlende Dateien wiederherstellen.
- Bestehende Dateien werden nicht ungefragt ueberschrieben.

### 11.2 Nicht-funktionale Anforderungen

#### NFR-1: Einfachheit

Das Tool muss ohne komplexe Einrichtung nutzbar sein.

Ziel:

```bash
npx agent-project-kit init
```

soll reichen.

#### NFR-2: Keine Cloud-Abhaengigkeit

Das Tool darf in Version 0.1 keine Cloud-Verbindung benoetigen.

#### NFR-3: Keine AI-API-Pflicht

Das Tool darf keine OpenAI-, Anthropic- oder andere AI-API voraussetzen.

#### NFR-4: Transparente Dateien

Alle generierten Artefakte muessen normale Markdown- oder Projektdateien sein.

#### NFR-5: Erweiterbarkeit

Neue Projekttypen und Templates sollen einfach ergaenzt werden koennen.

#### NFR-6: Plattform-Kompatibilitaet

Das CLI soll auf macOS, Linux und Windows funktionieren.

---

## 12. MVP-Scope

### 12.1 Enthalten in Version 0.1

Version 0.1 enthaelt:

- CLI-Initialisierung
- Base Template
- Web-App Template
- API-Backend Template
- iOS-App Template
- Portfolio Template
- AGENTS.md Generator
- Feature-Spec Generator
- Decision Record Generator
- Context-Pack-Ausgabe
- Doctor-Check
- Prompt Library
- mindestens drei vollstaendige Beispielprojekte
- ausfuehrliche README
- GUIDE.md
- STANDARDS.md

### 12.2 Nicht enthalten in Version 0.1

Version 0.1 enthaelt nicht:

- eigene AI-Integration
- Web Dashboard
- Login
- Cloud Sync
- Team-Features
- GitHub App
- VS Code Extension
- automatische Codeanalyse
- automatische Migration bestehender Projekte
- Plugin-System
- Bezahlmodell

---

## 13. Erfolgskriterien

### 13.1 Produktmetriken

Fuer Open Source sind folgende Metriken relevant:

- GitHub Stars
- GitHub Forks
- npm Downloads
- Anzahl Issues
- Anzahl externer Pull Requests
- Anzahl erstellter Beispielprojekte
- Erwaehnungen auf Reddit, Hacker News, X, LinkedIn oder Blogs

### 13.2 Fruehindikatoren

Ein frueher Erfolg liegt vor, wenn:

- Nutzer das Repo klonen und Templates verwenden.
- Nutzer eigene Projekttypen vorschlagen.
- Nutzer Issues mit Verbesserungsvorschlaegen erstellen.
- Nutzer Beispiele fuer eigene Projekte beitragen.
- Das Tool in AI-Coding-Workflows erwaehnt wird.

### 13.3 Ziel fuer Version 0.1

- Erste stabile CLI-Version veroeffentlichen.
- Mindestens drei gute Beispielprojekte bereitstellen.
- README so klar machen, dass ein neuer Nutzer in unter fuenf Minuten starten kann.
- Projekt auf GitHub veroeffentlichen.
- Erste Nutzer ueber persoenliche Kanaele, Reddit, Hacker News oder LinkedIn gewinnen.

---

## 14. Risiken

### Risiko 1: Zu generisch

Wenn das Tool zu allgemein bleibt, wirkt es wie eine Sammlung leerer Markdown-Dateien.

Gegenmassnahme:

- Starke Beispiele.
- Opinionated Defaults.
- Konkrete Projekttypen.
- Klare Empfehlungen.

### Risiko 2: Zu komplex

Wenn zu viele Dateien erzeugt werden, fuehlen sich Nutzer erschlagen.

Gegenmassnahme:

- Modi anbieten: Lightweight, Balanced, Strict.
- Gute README.
- Klare Erklaerung jeder Datei.
- Optional weniger Dateien generieren.

### Risiko 3: Kein echter Unterschied zu bestehenden Tools

Andere Tools bewegen sich ebenfalls Richtung spec-driven development.

Gegenmassnahme:

- Fokus auf Solo-Builder und AI-Coding-Workflows.
- AI-tool-agnostisch bleiben.
- Sehr gute Templates liefern.
- Context Packs als klares Differenzierungsmerkmal nutzen.

### Risiko 4: Zu viel Arbeit an Beispielen

Gute Beispiele sind aufwendig.

Gegenmassnahme:

- Mit drei starken Beispielen starten.
- Community-Beitraege ermoeglichen.
- CONTRIBUTING.md fuer neue Templates anbieten.

### Risiko 5: Schlechte Positionierung

Wenn das Tool als "Vibecoding-Tool" bezeichnet wird, kann es unserioes wirken.

Gegenmassnahme:

- Sprache: spec-driven, agent-ready, project structure, professional workflows.
- Vibecoding nur als Problemkontext erwaehnen, nicht als Hauptbranding.

---

## 15. Offene Fragen

- Soll das Projekt `Agent Project Kit`, `AI Project OS`, `SpecForge` oder anders heissen?
- Soll das CLI ueber `npx` laufen oder zusaetzlich als Homebrew-Paket verfuegbar sein?
- Sollen Source-Ordner wirklich erzeugt werden oder nur optional?
- Wie viele Dateien sollen im Lightweight-Modus erzeugt werden?
- Soll es eigene Templates fuer Claude Code, Cursor und Codex geben?
- Soll `AGENTS.md` im Root liegen oder zusaetzlich unter `docs/06-agent-context/`?
- Soll das Tool bestehende Projekte initialisieren koennen?
- Soll es spaeter eine AI-API-Integration geben?
- Wie stark sollen die Templates technische Entscheidungen vorgeben?
- Soll jedes Template eigene Beispiel-Dateien enthalten?

---

## 16. Annahmen

- Nutzer arbeiten bereits mit AI-Coding-Tools oder moechten damit starten.
- Nutzer sind bereit, Markdown-Dateien im Projekt zu pflegen.
- Nutzer profitieren von klaren Projektstandards.
- Der groesste Mehrwert liegt zunaechst in Struktur, Templates und Beispielen, nicht in eigener AI-Automatisierung.
- Ein CLI ist der richtige Einstieg, weil Zielnutzer technisch genug sind, Terminal-Befehle auszufuehren.
- Open Source ist die richtige Strategie, um Vertrauen, Feedback und Verbreitung zu gewinnen.

---

## 17. Release-Plan

### Version 0.1: Foundation Release

Ziel:

Ein nutzbares Open-Source-CLI mit professionellen Templates.

Umfang:

- CLI init
- Base Template
- Web App Template
- API Backend Template
- iOS Template
- AGENTS.md
- PRD.md
- MVP-FREEZE.md
- Feature-Spec Template
- Context-Pack Ausgabe
- README
- GUIDE
- drei Beispiele

### Version 0.2: Workflow Release

Ziel:

Bessere Workflows fuer taegliche Nutzung.

Umfang:

- `apkit add feature`
- `apkit add decision`
- `apkit doctor`
- bessere Validierung
- mehr Beispiele
- Claude/Cursor/Codex-spezifische Dateien

### Version 0.3: Ecosystem Release

Ziel:

Mehr Reichweite und Community-Beitraege.

Umfang:

- CONTRIBUTING.md
- Template Contribution Guide
- weitere Projekttypen
- GitHub Issue Templates
- Launch-Material
- Demo-GIF oder Terminal-Recording

### Version 1.0: Stable Standard

Ziel:

Stabile, gut dokumentierte Version mit klarer API fuer Templates.

Umfang:

- stabile CLI-Befehle
- semantische Versionierung
- Template-Versionierung
- robuste Tests
- saubere Dokumentation
- Community-Beispiele

---

## 18. Technische Empfehlung

Fuer das CLI wird TypeScript mit Node.js empfohlen.

Begruendung:

- einfache Nutzung ueber `npx`
- gute Plattform-Kompatibilitaet
- leicht zu veroeffentlichen ueber npm
- passend fuer Entwickler-Zielgruppe
- viele gute CLI-Bibliotheken

Empfohlener Stack:

```txt
Language: TypeScript
Runtime: Node.js
CLI Framework: commander oder cac
Prompts: @clack/prompts oder enquirer
Validation: zod
File operations: fs-extra
Formatting: prettier optional
Testing: vitest
Package Manager: pnpm
Distribution: npm
```

---

## 19. Beispiel-User-Journey

Ein Nutzer moechte eine Web-App mit Next.js bauen.

1. Nutzer fuehrt aus:

```bash
npx agent-project-kit init
```

2. CLI fragt:

```txt
Project name: meal-planner
Project type: Web App
Framework: Next.js
AI tool: Claude Code
Mode: Balanced
```

3. Tool erzeugt:

```txt
meal-planner/
  AGENTS.md
  docs/
    00-inbox/
    01-product/
    02-architecture/
    03-features/
    04-tasks/
    05-quality/
    06-agent-context/
  src/
    app/
    components/
    features/
    lib/
  tests/
    unit/
    e2e/
```

4. Nutzer oeffnet `docs/01-product/PRD.md` und fuellt Projektidee aus.

5. Nutzer erstellt ein Feature:

```bash
apkit add feature
```

6. Tool erzeugt:

```txt
docs/03-features/user-auth.feature.md
```

7. Nutzer fuehrt aus:

```bash
apkit context user-auth
```

8. Tool gibt relevante Dateien und eine Agenten-Anweisung aus.

9. Nutzer kopiert diese Anweisung in Claude Code, Codex oder Cursor.

---

## 20. Zusammenfassung

Agent Project Kit ist ein Open-Source-System fuer professionelle, AI-gestuetzte Softwareprojektstruktur.

Es loest nicht das Problem, Code zu generieren. Es loest das wichtigere Problem, AI-generierten Code in einen kontrollierten, dokumentierten und wartbaren Projektprozess einzubetten.

Der erste Produktfokus liegt auf:

- klarer Projektstruktur,
- starken Templates,
- guten Beispielen,
- Agenten-Regeln,
- MVP-Grenzen,
- Feature-Specs,
- Context Packs,
- einfacher CLI-Nutzung.

Damit positioniert sich Agent Project Kit als leichtgewichtiges, praktisches und professionelles Fundament fuer moderne AI-assisted Softwareentwicklung.
