<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=evlist/wp-plugin-codespace)

<img src=".devcontainer/assets/icon.svg" alt="wp-plugin-codespace logo" width="256" style="float:right" />

# wp-plugin-codespace

A lightweight, shareable "live Codespace" / devcontainer scaffold for WordPress plugin authors — clone, open a Codespace and start coding immediately.

🌱 Quick metaphor (attention)  
This repo is to Codespaces what grafting is to gardening: the scion (this Codespace template) can be grafted into your existing repository (the stock) to give it an instant, reproducible development environment.

Why use this
- ✨ Live Codespace: click the badge to create a Codespace from the template, export the scion into your repo and start coding without local setup.
- ⚙️ Minimal & conservative: provides PHP, WP‑CLI and common tooling while preserving your project/editor settings.
- 🔁 Easy updates: graft.sh (installer/updater) lets you adopt template improvements without losing local edits.

Terminology (short)
- scion — this upstream template (.devcontainer/.vscode)
- stock — your plugin repository that receives the scion
- graft — the installer/updater operation (graft.sh) that applies the scion into stock

Quick ways to get started
- Easiest (no local install): click the Codespaces badge above → create a Codespace → export the scion into your repository using the in‑Codespace helper UI.
- From a workstation (script):
  ```bash
  curl -L -o ~/Downloads/graft.sh \
    https://raw.githubusercontent.com/evlist/wp-plugin-codespace/main/.devcontainer/bin/graft.sh
  chmod +x ~/Downloads/graft.sh
  cd /path/to/your-plugin-repo
  bash ~/Downloads/graft.sh
  ```
  Inspect, commit and push the changes afterward.

Docs location
- 📚 Short and maintainer docs ship with the scion at `.devcontainer/docs/` so detailed guidance travels with the template and does not pollute stock repos.

Updated project structure (high level)
```
.
├── README.md
├── .devcontainer/                # scion (grafted into stock)
│   ├── README.md                 # scion maintainer notes (this repo)
│   ├── docs/                     # extended scion docs (maintainers)
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── bin/
│       └── graft.sh              # installer/updater (graft)
├── .vscode/                      # editor templates & stubs (managed)
└── plugins-src/                  # example/sample plugin(s)
```

Want more?
- Maintainers: see `.devcontainer/README.md` inside the scion for upgrade semantics and scion structure.
- Advanced docs (hooks, customization): planned under `.devcontainer/docs/` and `docs/` in future updates.

## License

This project is dual-licensed:

- GPL-3.0-or-later OR
- MIT

You may choose either license. See the LICENSE file and LICENSES/ directory for full texts.