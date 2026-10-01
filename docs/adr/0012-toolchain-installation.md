# 0012. Install a pinned toolchain without touching existing installations

- **Status:** Accepted
- **Date:** 2026-10-01

## Context

The setup must be reproducible on another machine. Formatting and lint results depend on the
exact LLVM version, and presets on the CMake version. winget can install pinned versions of
LLVM, CMake and Ninja. Visual Studio is different: winget lists Visual Studio Community 2026
under the id `Microsoft.VisualStudio.BuildTools`, so "installing the Build Tools" on a machine
with Community upgrades Community instead; and workload ids differ between products
(`NativeDesktop` for Community, `VCTools` for the Build Tools), while component ids are shared.
The LLVM installer doesn't add itself to `PATH` by default. Machines may already have other
versions installed for other work.

## Decision

- `Install-CppLabToolchain` (in `scripts/cpp-lab.ps1`, per ADR 0008) installs **missing** tools
  with winget: LLVM 21.1.0, CMake 4.4.3, Ninja 1.13.2 (pinned); Git and VSCode (latest).
- Tools already installed are **never upgraded or downgraded**; a version different from the pin
  is reported with the `winget` command to match it.
- A tool found in its default folder but not on `PATH` gets that folder added to the user `PATH`.
- `.vsconfig` lists the required Visual Studio **components** (no workloads):
  `VC.Tools.x86.x64`, `VC.ASAN`, `Windows11SDK.26100`. Build Tools 2026 are installed with it
  only when no Visual Studio exists; an installation missing components gets instructions, not an
  automatic modification.
- Recommended VSCode extensions (`.vscode/extensions.json`) are installed if missing.
- `-WhatIf` shows every action without performing it.
- `docs/setup.md` lists the tested versions, the steps and known pitfalls.

## Consequences

- A new machine needs PowerShell 7, Git and winget, then one command.
- Upgrading a pinned tool is a deliberate change: update the version in `scripts/cpp-lab.ps1`
  and `docs/setup.md`, reformat if clang-format changed, run the checks, and record it (new ADR
  if the change is significant).
- Visual Studio's MSVC version is not pinned (it follows Visual Studio updates); the tested
  version is recorded in `docs/setup.md`.
