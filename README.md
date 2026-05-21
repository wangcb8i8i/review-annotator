<div align="center">
  <div>
    <img src="./res/icon.svg" alt="Plan Reviewer" width="110px" height="110px">
  </div>

  <h1 style="margin-top: 10px;">Claude Code Plan Reviewer</h1>

  <h2>Review, annotate, and give feedback on Claude Code plans — right in the browser</h2>

  <div align="center">
    <a href="https://github.com/wangcb8i8i/review-annotator/graphs/commit-activity"><img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/m/wangcb8i8i/review-annotator"/></a>
    <a href="https://www.python.org/downloads/"><img alt="Python" src="https://img.shields.io/badge/python-3.7+-blue.svg"/></a>
    <a href="#license"><img alt="License" src="https://img.shields.io/badge/license-MIT-green"/></a>
  </div>

  <p>
    <a href="#why-plan-reviewer">Why?</a>
    ◆ <a href="#quick-start">Quick Start</a>
    ◆ <a href="#features">Features</a>
    ◆ <a href="#installation">Installation</a>
    ◆ <a href="#architecture">Architecture</a>
    ◆ <a href="#how-it-works">How It Works</a>
  </p>
</div>

## Why Plan Reviewer?

Claude Code writes execution plans as Markdown files in `~/.claude/plans/`. Those plans are great for Claude, but hard for humans to review in a terminal. Plan Reviewer gives you a polished browser UI to read plans, and lets you attach inline comments that get written back into the plan files — so Claude Code can read and respond to your feedback.

- **Rich rendering** — Markdown with syntax highlighting, Mermaid diagrams, and polished typography
- **Inline annotations** — Comment on sections or selected text; comments sync bidirectionally with `.md` files
- **Live updates** — SSE-powered real-time refresh when plan files change on disk
- **Zero dependencies** — Python 3 standard library on the server, vanilla HTML/CSS/JS on the frontend
- **Dark & light themes** — Toggle between themes, preference persisted in the browser

## Quick Start

```bash
# 1. Clone and start the server
git clone https://github.com/wangcb8i8i/review-annotator.git
cd review-annotator
python3 server.py

# 2. Open in browser
open http://localhost:23456

# 3. Point to a plans directory (optional)
python3 server.py --plans-dir /path/to/your/plans
```

> **Prerequisites**: Python 3.7+ (no pip install needed)
>
> **Need more options?** See [Installation](#installation) below for configuration and packaging.

## Features

### Plan Browser

The left sidebar lists all plan files in the watched directory. Switch between the file list and a document outline that tracks your scroll position with an `IntersectionObserver`.

### Inline Comments

Hover over any section heading to attach a comment, or select text and use the floating tooltip. Comments support five types:

| Type | Use for |
|------|---------|
| Comment | General feedback or discussion |
| Suggestion | Proposed changes or improvements |
| Question | Clarifications needed |
| Approve | Sign-off on sections |
| Reject | Flag issues or blockers |

Comments appear in the right panel **and** get injected into the plan `.md` file as formatted markdown blocks — so Claude Code sees them when reading the plan.

### Bidirectional Sync

Comments are stored as JSON in `~/.claude/plans/.reviews/` **and** embedded in plan `.md` files. If you manually edit a comment in the `.md` file, the server parses it back into the JSON store on the next file change.

### Mermaid Diagrams

Mermaid diagrams render inline with lazy loading. Click any diagram to open a fullscreen zoom view.

### Live Reload

The server polls the plans directory every second and pushes changes to the browser via SSE. File creations, modifications, and deletions show as toast notifications.

### Directory Switching

Click the directory label in the top bar to switch the watched directory at runtime — no restart needed.

## Installation

### From Source

```bash
git clone https://github.com/wangcb8i8i/review-annotator.git
cd review-annotator
python3 server.py --port 23456
```

The server prints:

```
╭─ Markdown Review & Annotation
│ Open: http://localhost:23456
│ Plans:   ~/.claude/plans
│ Reviews: ~/.claude/plans/.reviews
╰─ Ctrl+C to stop
```

### Configuration

**Option 1: Command-line flags**

```bash
python3 server.py --port 8080 --plans-dir ~/my-project/plans
```

**Option 2: Environment variable**

```bash
export PLAN_REVIEWER_PORT=8080
python3 server.py
```

### Distribution Package

Run `./pack.sh` to create `plan-view.zip` — a self-contained bundle of `server.py`, `index.html`, and `res/`. Unzip and run anywhere with Python 3.

## Architecture

### System Overview

<div align="center">
  <img src="./res/icon.svg" alt="Plan Reviewer" width="120">
</div>

```
┌──────────────────────────────────────────────────────────┐
│                      Browser                             │
│  ┌─────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │ Sidebar │  │ Markdown Preview │  │ Comments Panel  │ │
│  │ (plans/ │  │ (marked +        │  │ (comment cards) │ │
│  │ outline)│  │  highlight.js)   │  │                 │ │
│  └─────────┘  └──────────────────┘  └─────────────────┘ │
│                       │ SSE                               │
└───────────────────────┼──────────────────────────────────┘
                        │
┌───────────────────────┼──────────────────────────────────┐
│               Server (Python 3 stdlib)                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐ │
│  │ HTTP API │  │ SSE Hub  │  │ File Watcher (1s poll) │ │
│  │ /api/*   │  │ /events  │  │                        │ │
│  └────┬─────┘  └────┬─────┘  └───────────┬────────────┘ │
│       │             │                     │               │
│  ┌────┴─────────────┴─────────────────────┴────────────┐ │
│  │              Comment Engine                         │ │
│  │  JSON store (.reviews/) ←→ MD injection (plan .md)  │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │  ~/.claude/plans/     │
            │  ├── plan-1.md        │
            │  ├── plan-2.md        │
            │  └── .reviews/        │
            │      ├── plan-1.json  │
            │      └── plan-2.json  │
            └───────────────────────┘
```

### Stack

| Layer | Technology |
|-------|-----------|
| Server | Python 3 stdlib (`http.server`, `threading`, `pathlib`) |
| Markdown | marked (MIT) |
| Syntax highlighting | highlight.js (BSD-3-Clause) |
| Diagrams | Mermaid (ESM bundle) |
| Frontend | Vanilla HTML/CSS/JS — no framework |
| Fonts | Preview Sans Medium, Preview Mono |

## How It Works

### Comment Flow

1. You select text or hover a section heading in the browser
2. A composer appears — type your comment, pick a type, press Cmd+Enter
3. The comment is saved to `~/.claude/plans/.reviews/{plan-id}.json`
4. The server injects a formatted comment block into the plan `.md` file:

```markdown
### 💡 Suggestion (on: "Database schema section") [Line 42]

> Consider adding an index on the `user_id` column

_— Reviewer, 2026/05/21 16:39_
```

5. When Claude Code reads the plan, it sees your feedback and can act on it

### SSE Events

The server pushes these events to the browser:

| Event | Trigger |
|-------|---------|
| `plans-changed` | File created, modified, or deleted in the plans directory |
| `comments-changed` | Comment added, resolved, or deleted |
| `hook-trigger` | External POST to `/api/hook-trigger` |

The frontend debounces refreshes (500ms) and uses signature-based diffing to avoid re-rendering unchanged content.

## Contributing

Contributions are welcome. Areas where help is most valuable:

- **Syntax theme support** — add more highlight.js themes beyond github-dark/github
- **Comment threading** — reply chains on comments
- **Diff view** — show what changed between plan versions
- **Mobile layout** — improve responsive breakpoints below 640px

```bash
git clone https://github.com/YOUR_USERNAME/review-annotator.git
cd review-annotator
git checkout -b feature/your-feature
```

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>
    <strong>Built for reviewing Claude Code plans in a browser</strong><br>
    <sub>Zero dependencies · Two core files · Instant start</sub>
  </p>
</div>
