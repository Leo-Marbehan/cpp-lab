# 0008. Keep a single PowerShell script; write other tooling in C++

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

Some tasks need a script: installing the toolchain, entering the MSVC developer environment,
shortcuts for common commands. Scripts tend to multiply. Shortcuts are most useful when they are
available in every shell, i.e. loaded from the PowerShell profile.

## Decision

- Exactly one PowerShell script in this repository: `scripts/cpp-lab.ps1` (not written yet).
  It contains only what must run inside the current shell (changing directory, entering the
  developer environment), thin wrappers around `cmake`/`ctest`, and the toolchain installation
  as a function. Loading it only defines functions.
- It works as a profile extension: dot-sourcing it from a PowerShell profile
  (`. <repo>\scripts\cpp-lab.ps1`) makes its commands available in every shell. It finds the
  repository from its own location, so it works from any clone.
- Any other tooling with real logic is written in C++, or Python if C++ is lacking.

## Consequences

- Tooling changes are versioned with the build they drive.
- The script must stay small and fast to load; logic moves to C++ tools.
- Things CMake can do (formatting targets, workflow presets) are done in CMake, not in scripts.
