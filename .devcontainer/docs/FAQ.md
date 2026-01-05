<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

# FAQ — Frequently Asked Questions

## Installation & Setup

### Q: What's the fastest way to get started?
**A:** Click the Codespaces badge in the README of this repository, create a new Codespace, and use the interactive installer from within the Codespace. It will guide you through exporting the scion into your repository.

### Q: Can I use graft.sh without GitHub Codespaces?
**A:** Yes! You can download and run `graft.sh` from any workstation with Git, Bash, and rsync installed. See the Quick Start section in the main README.

### Q: Do I need to be a maintainer to use graft.sh?
**A:** No. End users can run `graft.sh install` or `graft.sh export` to apply the scion to their repository. Advanced flags like `--push` and `--dry-run` are available for automation and careful review.

### Q: What if my repository already has a `.devcontainer/` or `.vscode/` folder?
**A:** The installer runs a preflight check to detect potential conflicts. If files would be overwritten, it prompts you interactively with options: keep local changes, replace, backup+replace, or save a sample copy. Use `--dry-run` to preview without committing.

---

## Understanding Scion, Stock & Graft

### Q: What does "scion," "stock," and "graft" mean in this context?
**A:** These terms come from gardening:
- **Scion** = the devcontainer template (this repository)
- **Stock** = your repository receiving the scion
- **Graft** = the act of applying the scion to your repository

Think of it like grafting a fruit tree branch onto a rootstock: the scion (template) doesn't replace the stock (your repo), it integrates with it.

### Q: Is my repository modified permanently?
**A:** No. The scion files are added to your repository, but you control them. You can:
- Accept all changes and commit
- Cherry-pick which files to commit
- Reject the graft entirely (the installer is non-destructive in `--dry-run`)

### Q: Can I use the scion with projects other than WordPress?
**A:** Yes! The current examples target WordPress, but the pattern is generic. You can customize `.devcontainer/`, remove WordPress-specific parts, and add your own tools and scripts.

---

## Updates & Maintenance

### Q: How do I update the scion to a newer version?
**A:** Run `bash .devcontainer/bin/graft.sh upgrade` (or `cs_update` inside a Codespace). The script will:
1. Clone the latest scion
2. Compare your local files with the previous scion version
3. Prompt you for each change

### Q: What are `.orig`, `.dist`, and `.bak` files?
**A:** These are part of the Debian-inspired update mechanism:
- **`.orig`** (scion previous) = snapshot of the file when the scion was last applied. Used to detect your local changes.
- **`.dist`** (scion sample) = the latest scion version, saved when you choose to keep your local version instead of updating.
- **`.bak.<timestamp>`** = timestamped backup created before a destructive replace action.

### Q: Should I commit `.orig` and `.dist` files?
**A:** `.orig` should be committed (it tracks the scion baseline). `.dist` files are typically gitignored but can be committed if you want to preserve samples. Check your `.gitignore`.

### Q: What if I have local edits to a scion file?
**A:** When updating, you'll be prompted with options:
- **Keep local** = ignore the new scion version
- **Replace** = accept the new version (loses your edits)
- **Backup + Replace** = save your version as `.bak.<timestamp>` then update
- **Save sample** = keep local but save the new version as `.dist`
- **Merge** = attempt a 3-way merge using the scion baseline

---

## Troubleshooting

### Q: The installer aborts saying files would be ignored by .gitignore. What do I do?
**A:** Your repository's `.gitignore` prevents the scion from being installed. Either:
1. Update `.gitignore` to exclude the scion paths (`.devcontainer/`, `.vscode/`)
2. Run the installer interactively to review and fix ignores
3. Use `--dry-run` to see exactly which files are affected

### Q: I ran the graft but forgot `--dry-run`. Can I undo it?
**A:** Yes. The installer creates a Git branch (default: `graft/TIMESTAMP`). If you haven't pushed or committed, simply:
```bash
git checkout main      # switch back to main
git branch -D graft/TIMESTAMP  # delete the graft branch
```
If you've already committed, use `git revert` or `git reset` to undo.

### Q: Files are present locally but not committed. Why?
**A:** Your `.gitignore` likely ignores them. Check with:
```bash
git check-ignore -v .devcontainer/
git check-ignore -v .vscode/
```
Then either update `.gitignore` or manually add/commit the files.

### Q: The merge attempt failed. Now what?
**A:** A merge can produce conflicts if your local edits and the scion changes are incompatible. The script will:
1. Show a preview of the merged result
2. Let you accept or discard it
3. Fall back to `--keep local` if you discard

If unsure, use `--dry-run` to preview before running the real update.

### Q: I want to downgrade or use a specific scion version. How?
**A:** Edit `.devcontainer/.cs_env.d/graft.local.env` and change the `SCION_REF` field. For example:
```bash
# Graft scion provenance - generated by graft.sh export
# This file tracks which scion version was grafted into this stock repository
SCION_ID=evlist/codespaces-grafting
SCION_REF=v1.0.0
SCION_COMMIT=abc123def456...
SCION_INSTALLED_AT=2026-01-05T10:30:45Z
```
Then run `bash .devcontainer/bin/graft.sh upgrade` to re-apply that version.

---

## Design Decisions

### Q: Why save a `.orig` baseline instead of just replacing files?
**A:** It allows future updates to detect whether you've made local changes. When updating, the script compares:
- Local file vs. scion (previous) → detects your edits
- Scion (previous) vs. scion (new) → detects what changed upstream

This is inspired by Debian's dpkg, which uses a similar approach for package config files.

### Q: Why not auto-source `./.cs_env` at runtime?
**A:** The script is designed to work in minimal environments (fresh clones, CI) without hidden dependencies. Auto-sourcing a workspace file can introduce surprising behavior. Instead, you can:
- Export env variables before running the script
- Create a wrapper script that sources and then calls graft.sh
- Set environment variables in CI/Codespaces Secrets

### Q: Why are there separate `.cs_env` and `.cs_env.d/` directories?
**A:** The `.d/` convention (from Debian) allows modular configuration:
- `.cs_env` = baseline defaults
- `.cs_env.d/*` = optional modules, sourced in alphabetical order
- Each module can be independently enabled/disabled

This scales better than a monolithic `.env` file.

### Q: What's the difference between `install`, `export`, and `upgrade`?
**A:**
- **`install`** (scion → stock) = apply the scion into a repository
- **`export`** (stock as scion) = package your repository as a new scion template
- **`upgrade`** (stock with scion) = update the scion in an already-grafted repository

---

## Advanced Usage

### Q: Can I customize the scion before installing it?
**A:** Yes. You can:
1. Fork this repository
2. Make your changes
3. Run `graft.sh --scion <your-fork>` to use your custom version
4. Or set `UPSTREAM_SCION` to your fork in `.devcontainer/.cs_env`

### Q: How do I use graft.sh in CI?
**A:** Example GitHub Actions workflow:
```yaml
- name: Preview graft changes
  run: bash .devcontainer/bin/graft.sh --dry-run

- name: Apply graft
  run: bash .devcontainer/bin/graft.sh --non-interactive --push
```

### Q: Can I graft into a non-GitHub repository?
**A:** Yes, as long as it's a Git repository with an origin remote. `graft.sh` uses `git` commands, not GitHub-specific APIs (except for pushing with `gh`).

### Q: What about monorepos? Can I graft multiple projects?
**A:** `graft.sh` works at the repository root. For monorepos, you'd need to:
1. Run it once per project directory (if they have separate `.devcontainer/`)
2. Or create a unified scion that supports multiple subprojects

---

## Support & Contributions

### Q: I found a bug or have a feature request. Where do I report it?
**A:** Open an issue on the [GitHub repository](https://github.com/evlist/codespaces-grafting/issues). Please include:
- What you're trying to do
- The command you ran
- Output/error messages
- Relevant context (OS, Git version, Bash version)

### Q: Can I contribute improvements?
**A:** Absolutely! Fork the repository, make your changes, and submit a pull request. Make sure to:
- Test with `--dry-run` on a sample repository
- Update documentation if you change behavior
- Follow the existing code style

### Q: What's the license?
**A:** Dual-licensed: GPL-3.0-or-later OR MIT. You can choose whichever suits your needs.

---

## Performance & Limitations

### Q: How long does a typical graft take?
**A:** Usually 10–30 seconds, depending on:
- Network speed (cloning the scion from GitHub)
- Disk speed (copying/syncing files)
- Number of files to process
- Whether prompts are shown (interactive mode is slower)

Use `--non-interactive` to skip prompts and speed up automated runs.

### Q: Are there any size limits?
**A:** No hard limits, but:
- Cloning a very large repository may take time
- Many files to sync will be slower
- Very large `.vscode/` configs may conflict more

### Q: Can I use graft.sh on Windows?
**A:** Yes, if you have Git Bash, WSL, or a similar Bash environment. The script is pure Bash with standard Unix tools (rsync, git, etc.).

---

Last updated: 2026-01-05
