<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=evlist/wp-plugin-codespace)

# wp-plugin-codespace

🧰 A lightweight, shareable Codespaces/devcontainer scaffold for WordPress plugin authors.

This repository makes it straightforward for WordPress plugin authors to provide a zero‑install, ready‑to‑use development environment. The devcontainer is preconfigured with PHP, WP‑CLI, a webserver and editor settings so contributors, contractors, and reviewers can open a Codespace (or use a local devcontainer) and start working immediately.

## 🔎 Why this repo exists
- Problem: onboarding for WordPress plugin development often requires installing PHP, a webserver, a database, extensions and bootstrapping WordPress locally.
- Goal: remove that friction — clone, open a Codespace, and start coding.

## 👥 Who should use this
This template is intended for:
- WordPress plugin authors and maintainers who want a reproducible, shareable development environment.
- People who need to demo or test a plugin quickly without asking contributors to set up local infrastructure.
- Teams that want an easy way to adopt template improvements via a simple updater.

## ✨ What this provides
- A compact `.devcontainer/` and a required `.vscode/` directory preconfigured for plugin development (think of `.vscode/` as template configuration similar to `/etc` on a system).
- A single installer/updater script to add or refresh the devcontainer and editor snippets in your plugin repo.
- A convention for Codespace-specific configuration: copy `.devcontainer/.cs_env` into your workspace as `./.cs_env` and edit values as needed.
- Useful CLI tools installed in the Codespace, such as `gh` (GitHub CLI) and `reuse`.
- Conservative update semantics (baseline `.orig`, upstream samples `.dist`, backups `.bak.*`) that preserve local edits.

## ⚙️ Main principles
- Track only the minimal configuration required for a reproducible dev environment.
- Keep secrets out of git; the template provides `.devcontainer/.cs_env` which you can copy to `./.cs_env` and edit locally or provide values via Codespaces secrets.
- Use a single script as both installer and updater so repositories can stay in sync with the template without losing local customizations.
- Make updates explicit and reversible with baselines, samples and backups.

## 🚀 Quick install (recommended, minimal)
1. Download the installer to your workstation (do not add it to the repo):
   ```bash
   curl -L -o ~/Downloads/install.sh \
     https://raw.githubusercontent.com/evlist/wp-plugin-codespace/main/.devcontainer/bin/install.sh
   chmod +x ~/Downloads/install.sh
   ```
2. From a local, up‑to‑date clone of your plugin repository:
   ```bash
   cd /path/to/your-plugin-repo
   bash ~/Downloads/install.sh
   ```
   - On first run the script acts as an installer and will guide you through initial choices.
   - On subsequent runs the same script acts as the updater.
3. Inspect the changes, then commit and push:
   ```bash
   git add .
   git commit -m "Add Codespace/devcontainer"
   git push
   ```
4. Open your repository in a GitHub Codespace or locally with Remote - Containers.

## 🔁 Updater (inside Codespace)
- The Codespace image exposes two convenient aliases:
  - `cs_install` — run the installer (initial setup).
  - `cs_update`  — run the updater (same script, named for clarity).
- Both aliases point to the same `bin/install.sh` script and simplify interactive updates from inside the Codespace.

## 📝 Environment files (manual approach)
- We keep Codespace-specific variables separate from project `.env` files.
- The template ships `.devcontainer/.cs_env`. If you want Codespace-specific values, copy it to the workspace root and edit:
  ```bash
  cp .devcontainer/.cs_env ./.cs_env
  ```
- Alternatively, provide values using Codespaces repository secrets.
- The installer/updater does not automatically create or modify `./.cs_env` or project `.env`; creating or updating `./.cs_env` is intentionally manual.

## 🧪 Dry-run and automation
- Preview changes without modifying files:
  ```bash
  bash ~/Downloads/install.sh --dry-run
  ```
- Choose an upstream ref: `--ref <branch-or-tag>` (default: `stable`).
- Run non-interactively: `--yes`.
- Use `--dry-run` in CI to detect issues (for example, accidental ignores) before merging.

## 📝 Recommended .gitignore hints
Keep secrets and updater artifacts out of git:
```
.env
.env.*
.vscode/*.dist
.vscode/*.bak.*
.devcontainer/tmp/
.devcontainer/var/
```

## 📁 Project Structure

```
.
├── .cs_env                        # Local environment variables (workspace-local; copy from .devcontainer/.cs_env if needed)
├── bootstrap-local.sh             # Local bootstrap script
├── .devcontainer/
│   ├── devcontainer.json          # VS Code devcontainer configuration
│   ├── docker-compose.yml         # Docker Compose services definition
│   ├── Dockerfile                 # WordPress container with WP-CLI
│   ├── README.md                  # Technical notes
│   ├── .cs_env                    # Template environment variables (copy to workspace root to customize)
│   └── bin/
│       ├── bootstrap-wp.sh        # Bootstrap: DB, Apache, WP core, symlinks, calls local bootstrap if present
│       ├── install.sh             # Install and update script
│       └── merge-env.sh           # Merge .cs_env files
├── .vscode/
│   ├── launch.json                # Static PHP debug config (single mapping)
│   └── intelephense-stubs/
│       └── wp-cli.php             # Editor-only stub for WP-CLI
└── plugins-src/
    └── hello-world/               # Sample plugin directory
        ├── hello-world.php
        └── README.md
```

---

## Credits

This plugin was inspired by examples and guidance from:

- [WordPress Plugin Developer Handbook](https://developer.wordpress.org/plugins/)
- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Admin Bar API (`admin_bar_menu` / `add_node`)](https://developer.wordpress.org/reference/hooks/admin_bar_menu/)
- [Admin Notices (`admin_notices`)](https://developer.wordpress.org/reference/hooks/admin_notices/)
- [WP‑CLI Handbook and Commands Cookbook](https://make.wordpress.org/cli/handbook/) · [Commands cookbook](https://make.wordpress.org/cli/handbook/commands-cookbook/)
- [Hello Dolly plugin](https://wordpress.org/plugins/hello-dolly/) for a minimal plugin structure
- [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards)

Developed in GitHub Codespaces with assistance from GitHub Copilot.

## License

This project is dual-licensed:

- GPL-3.0-or-later OR
- MIT

You may choose either license. See the [LICENSE](LICENSE) file and the full texts in the LICENSES/ directory.

### Note to self

To update the license year:
```
$ reuse annotate -r --year "2025-2026" --copyright "Eric van der Vlist <vdv@dyomedea.com>" --license "GPL-3.0-or-later OR MIT" --merge-copyrights --fallback-dot-license .
```