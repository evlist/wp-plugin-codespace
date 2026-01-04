<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

<img src="./assets/icon.svg" alt="scion logo" width="256" style="float:right" />

# .devcontainer — short maintainer notes

🌱 Quick metaphor (attention)  
This scion is to your repo what a plant scion is to a stock: graft the scion (this Codespace/devcontainer template) into your plugin repo to give it an instant, reproducible development environment.

Why this lives here
- Provide a zero‑install development environment (Codespaces + Remote‑Containers) for contributors.
- Keep template-level editor/workspace samples separate so maintainers can roll out improvements safely.

What’s in the scion (high level)
- devcontainer.json, Dockerfile, docker-compose.yml — container & Codespaces config
- bin/graft.sh — installer/updater script (graft) used for first‑run and upgrades
- .vscode/ — editor configuration, snippets and stubs (template-managed)
- docs/ — scion-maintainer docs (upgrade guides, internals)

Scion structure (short)
```
.devcontainer/
├── README.md        # this file (short)
├── docs/            # extended scion docs (upgrade guides, internals)
├── assets/          # icons, images used in scion docs
├── devcontainer.json
├── Dockerfile
└── bin/
    └── graft.sh      # run this to graft the scion into a repo
```

🔁 Upgrade & maintainer quick guide
- From inside a Codespace (recommended interactive flow):
  - `cs_install` — initial install (alias to bin/graft.sh)
  - `cs_update`  — interactive update (alias to bin/graft.sh)
- From a workstation (non-interactive or scripted):
  ```bash
  curl -L -o ~/Downloads/graft.sh \
    https://raw.githubusercontent.com/evlist/wp-plugin-codespace/main/.devcontainer/bin/graft.sh
  chmod +x ~/Downloads/graft.sh
  cd /path/to/your-plugin-repo
  bash ~/Downloads/graft.sh      # or: bash ~/Downloads/graft.sh --dry-run
  ```
- Dry-run recommended:
  ```bash
  bash bin/graft.sh --dry-run
  ```

Update semantics (summary)
- New upstream file → added and baseline saved as `.orig`.
- Local edits preserved when they differ from `.orig` (interactive choices: keep, replace, backup+replace, save upstream as `.dist`, or 3‑way merge).
- Upstream samples saved as `.dist` when keeping local changes.

Troubleshooting tips
- If `git check-ignore` shows required paths are ignored, fix `.gitignore` first or run interactively — the non‑dry‑run install will abort to avoid hiding template files.
- Use `.devcontainer/docs/` for step‑by‑step maintainer procedures and to record merging/upgrading policies.

## License

This project is dual-licensed:

- GPL-3.0-or-later OR
- MIT

You may choose either license. See the LICENSE file and LICENSES/ directory for full texts.