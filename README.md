<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=evlist/codespaces-grafting)

<img src=".devcontainer/assets/icon.svg" alt="codespaces-grafting logo" title="codespaces-grafting" width="256" style="float:right;max-width:256px;height:auto" />

# codespaces-grafting (aka cs-grafting)

A lightweight, shareable "live Codespace" / devcontainer scaffold. Graft this Codespace into an existing repository to give it an instant, reproducible development environment.

🌱 Quick metaphor (attention)  
This project is to Codespaces what grafting is to gardening: you graft this Codespace template (the scion) into an existing repository (the stock) to add a ready-to-run development environment.

Who this is for
- Primary: WordPress plugin and theme authors (current templates and examples target WP).
- Secondary: Any project that wants a small, repeatable Codespace/devcontainer setup — the approach is intentionally generic.

Why use this
- ✨ Live Codespace: click the badge to create a Codespace from this template and export the scion into your repo (fastest path).
- ⚙️ Minimal & conservative: provides PHP, WP‑CLI and common tooling while preserving your project/editor settings.
- 🔁 Simple updater: graft.sh grafts the scion into your repo and helps you adopt template improvements safely.

Terminology (short)
- scion — the Codespace/devcontainer template (.devcontainer/.vscode)
- stock — your repository getting the scion grafted
- graft — the act of applying the scion (graft.sh)

Quick start
- Easiest (live Codespace): click the Codespaces badge → create a Codespace → export the scion into your repository via the Codespace UI.
- From a workstation:
  ```bash
  curl -L -o ~/Downloads/graft.sh \
    https://raw.githubusercontent.com/evlist/codespaces-grafting/stable/.devcontainer/bin/graft.sh
  chmod +x ~/Downloads/graft.sh
  cd /path/to/your-repo
  bash ~/Downloads/graft.sh
  ```
  Inspect the changes, commit and push the files you want to keep.

Docs and maintainers
- Short maintainer docs ship with the scion at `.devcontainer/docs/` so detailed guidance travels with the template and does not pollute stock repos.
- Current examples target WordPress; the pattern is reusable for other ecosystems.

Project structure (high level)
```
.
├── README.md
├── .devcontainer/                # scion (grafted into stock)
│   ├── README.md                 # scion maintainer notes
│   ├── docs/                     # extended scion docs (maintainers)
│   ├── assets/                   # icons, images used in scion docs
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── bin/
│       └── graft.sh              # installer/updater (graft)
├── .vscode/                      # editor templates & stubs (managed)
└── plugins-src/                  # example/sample plugin(s) (WP-focused examples)
```

Want more?
- Maintainers: see `.devcontainer/README.md` inside the scion for upgrade semantics and structure.
- Advanced docs (hooks, customization): planned under `.devcontainer/docs/`.

## License

This project is dual-licensed:

- GPL-3.0-or-later OR
- MIT

You may choose either license. See the LICENSE file and LICENSES/ directory for full texts.