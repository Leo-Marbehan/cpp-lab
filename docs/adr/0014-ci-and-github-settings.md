# 0014. Run the check workflows in CI and keep GitHub settings as code

- **Status:** Accepted
- **Date:** 2026-10-01

## Context

The repository is public with a single maintainer and accepts issues but not pull requests. The
check workflows (ADR 0009) run locally; they should also run on every change, on a machine that
isn't the maintainer's. GitHub-hosted Windows runners have their own LLVM, CMake and Visual Studio
versions; a different clang-format would fail `format_check` on code that passes locally. winget
can't be relied on in runners. Many repository settings can't be files, but the GitHub CLI and
REST API can set them, and rulesets can be imported from JSON.

## Decision

- `.github/workflows/ci.yml`: a matrix job `check (clang)` / `check (msvc)` on `windows-latest`,
  triggered by pushes to `main`, every pull request, and `workflow_dispatch` restricted to the
  repository owner. Read-only token. Each job enters the Visual Studio developer environment, then
  `Install-CppLabPortableToolchain` downloads the pinned CMake, Ninja and LLVM (SHA-256 verified,
  LLVM's installer extracted with 7-Zip, no installation), then runs `Invoke-CppLabCheck`, the
  same command as locally.
- The pinned versions, URLs and hashes live in one table in `scripts/cpp-lab.ps1`
  (`$CppLabPinnedTools`), shared by `Install-CppLabToolchain` and `Install-CppLabPortableToolchain`.
- Default-branch ruleset in `.github/rulesets/main.json`: no deletion, no force push, linear
  history, both CI checks required; repository admins may bypass (direct pushes stay possible).
- Other settings in `docs/github.md` (web UI path for each) and applied by
  `Set-CppLabGitHubSettings` (GitHub CLI, idempotent, `-WhatIf`).
- Community files: `CONTRIBUTING.md` (issues welcome, pull requests closed), `SECURITY.md`
  (private vulnerability reporting), issue forms with blank issues disabled, a pull request
  checklist; Dependabot for the Actions versions.

## Consequences

- CI checks exactly what `cppchk` checks locally, with the same tool versions except MSVC.
- Each CI job downloads about 400 MB of tools (no cache yet); acceptable for a small repository.
- MSVC differences between the runner and local Visual Studio can make `check (msvc)` fail where
  local passes (or the reverse); the runner's version is printed in the job log.
- Changing a pinned tool means updating its version, URL and SHA-256 in one place.
- The first CI run can only be observed after the first push.
