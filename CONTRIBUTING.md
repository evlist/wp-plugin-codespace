<!--
SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

# Contributing to codespaces-grafting

Thank you for your interest in contributing! This document outlines how you can help improve the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/codespaces-grafting.git`
3. Create a feature branch: `git checkout -b feature/my-improvement`
4. Make your changes
5. Test thoroughly (especially in a real Codespace)
6. Push to your fork and open a Pull Request

## Areas We Welcome Contributions In

### Documentation
- **FAQ improvements**: Adding new Q&A entries for common issues
- **Examples**: Use case walkthroughs (plugin dev, theme dev, etc.)
- **Translations**: Help translate docs to other languages
- **Typos/Clarity**: Fixing grammatical issues or unclear explanations

### Code
- **Bug reports**: Found an issue? Open a GitHub issue with reproduction steps
- **Script improvements**: Performance, readability, error handling
- **Shell best practices**: Applying modern bash idioms
- **Platform support**: Testing/fixing macOS, Windows, Linux variations

### Testing
- **Smoke tests**: Verify graft export/upgrade workflows
- **Edge cases**: Non-interactive mode, dry-run, various repository types
- **CI/CD improvements**: GitHub Actions optimizations

## Development Workflow

### Testing Changes
```bash
# In a Codespace (recommended)
bash .devcontainer/bin/graft.sh --help
bash .devcontainer/bin/graft.sh --dry-run --non-interactive

# Or locally
cd /path/to/test-repo
bash /path/to/codespaces-grafting/.devcontainer/bin/graft.sh --dry-run
```

### Branch Naming
- `feature/description` — new features
- `fix/description` — bug fixes
- `docs/description` — documentation only
- `refactor/description` — code cleanup (no behavior change)

### Commit Messages
Keep them concise and descriptive:
```
Short description (50 chars max)

Longer explanation if needed (wrap at 72 chars).
Mention related issues: fixes #123
```

## Code Style

- **Bash**: POSIX-compliant where possible, shellcheck clean
- **Documentation**: Markdown, clear English, consistent formatting
- **Consistency**: Follow existing patterns in the codebase

## Pull Request Process

1. Update documentation if needed
2. Test thoroughly (include both dry-run and actual execution)
3. Ensure commit messages are clear
4. Reference any related issues
5. Wait for review feedback
6. Merge will be by project maintainer

## Reporting Issues

When reporting a bug, include:
- **What happened**: Actual behavior
- **What you expected**: Expected behavior
- **Steps to reproduce**: Exact commands/actions
- **Environment**: OS, shell, Codespaces vs local
- **Logs**: Run with `--debug` flag if relevant

## License

By contributing, you agree that your contributions will be licensed under the same dual license as the project (GPL-3.0-or-later OR MIT).

## Questions?

- Check the [FAQ](docs/FAQ.md)
- Read the [MAINTAINER.md](.devcontainer/docs/MAINTAINER.md)
- Open a GitHub Discussion

Thank you! 🌱
