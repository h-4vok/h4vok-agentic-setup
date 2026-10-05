# Working with this repository

## Purpose

This repository documents and installs the owner's opinionated local setup. Humans and AI agents must be able to follow it without relying on previous conversations. The root README is a table of contents; procedures belong in each component's directory.

## Required working language

**Use English for all work in this repository, regardless of the language used in conversations with the owner.** A Spanish chat does not change this requirement.

Write documentation, agent instructions, code comments, docstrings, script messages, examples, validation records, and any requested commit or PR text in English. Preserve exact commands, identifiers, paths, and verbatim diagnostic output when translation would change their meaning. User-facing chat replies may follow the owner's conversational language.

## Installing on a machine

1. Read the root README and the requested component guide, including operating system and client-specific steps (Codex/Claude).
2. Detect the system, shell, commands, versions, and existing configuration before making changes. Do not assume a previous installation applies to another PC.
3. Install only the requested scope. Reuse compatible dependencies; do not reinstall or upgrade unrelated tools without a reason.
4. Save local backups of files that will change, outside the repository. Merge changes into existing configuration; never replace it wholesale or expose secrets in logs.
5. Apply each guide's explicit preferences. For Headroom: beacon off, output shaping on, and a loopback proxy.
6. Run the guide's verification steps and inspect exit codes. Distinguish installation, configuration, startup, local tests, and actual provider requests.
7. Fix issues within the authorized scope. Document extra steps, causes, and reproducible solutions in troubleshooting, and record results with dates and versions.
8. Report what works, what requires a new terminal or client restart, and what remains unverified. Do not claim measured savings without data or call a --version check an end-to-end test.

## Maintaining guides

- Use English, complete commands, and language-tagged code blocks.
- Keep one directory per component within its category. Avoid duplicating shared requirements across client guides.
- Include purpose, requirements, preferences, installation, daily usage, verification, updates, and rollback.
- Mark optional steps explicitly. Do not apply them automatically during a basic installation.
- Check commands against --help and current official sources. Record the tested version and link sources; procedures can change.
- Scripts must fail clearly, preserve unrelated configuration, and tolerate repeated execution.
- Do not commit credentials, complete personal configurations, agent histories, backups, private logs, or downloaded binaries.
- Do not commit, publish, or message third parties unless the user requests it.
- Planned directories do not authorize installing their contents.
