# AGENTS.md

Instructions for AI coding agents (and humans) working in this repository.

## Project

A personal C++20 monorepo for practicing C++: single-file programs in `playground/`, projects,
and shared code in `common/`.
Windows only, CMake + Ninja, MSVC (main) and clang (second compiler), VSCode.

## Layout

```text
common/        static library `common`: include/common/*.hpp, src/, tests/
playground/    every *.cpp (subfolders included) is its own executable pg_<path>, linked to common
projects/      every <name>/ with a CMakeLists.txt is added automatically
templates/     project templates used by cmake/new_project.cmake
scripts/       cpp-lab.ps1: shell commands (the only PowerShell script, see ADR 0008)
testing/       shared test main (cpp_lab_test_main)
cmake/         compiler_flags.cmake (flags, ASan, warnings), doctest.cmake (tests), format.cmake,
               new_project.cmake (generator), generator_check.cmake (templates self-test),
               pre_commit.cmake (git hook checks)
.githooks/     pre-commit, commit-msg (enabled per clone with git config core.hooksPath .githooks)
docs/          setup.md, conventions.md, vscode.md, shell.md, adr/ (architecture decision records)
.vsconfig      Visual Studio components required (used by Install-CppLabToolchain)
```

## Build and test

MSVC presets need the Visual Studio developer environment (`Launch-VsDevShell.ps1 -Arch amd64
-HostArch amd64`, or "Developer PowerShell for VS 2026"). VSCode's CMake Tools sets it up by
itself. The clang presets also work from a plain shell.

```powershell
cmake --list-presets=all             # configure, build, test and workflow presets
cmake --preset msvc-debug            # configure  → build/msvc-debug/
cmake --build --preset msvc-debug    # build      → executables in build/msvc-debug/bin/
ctest --preset msvc-debug            # test (includes format_check)
cmake --build --preset clang-debug --target format   # format every C++ file

cmake --workflow --preset lint       # clang-tidy + warnings as errors + formatting
cmake --workflow --preset check      # same + all tests (clang)
cmake --workflow --preset check-msvc # MSVC, warnings as errors + all tests (developer environment)
```

Before saying a change works: run `cmake --workflow --preset check` and
`cmake --workflow --preset check-msvc`; both must pass.

Shortcuts for humans: dot-source `scripts/cpp-lab.ps1` (from a PowerShell profile) for `cppdir`,
`vsdev` (enter the developer environment), `cppbuild`, `cpptest`, `cppchk` (both check workflows),
`cppnew`, `cppclean` (see `docs/shell.md`). They only wrap the commands above. Keep that script small: anything with
real logic is written in C++ or CMake, not PowerShell.

Fix clang-tidy findings rather than silencing them. When a suppression is justified, name the
check and give the reason (`// NOLINTNEXTLINE(check-name): reason`); never a bare `// NOLINT`.
See `docs/conventions.md`.

## Adding code

- **Single-file program:** add `playground/[<folder>/…]<name>.cpp` with a `main`. Nothing else;
  `playground/math/primes.cpp` becomes `pg_math_primes`. Each `.cpp` is a separate program, so
  helpers shared inside a folder must be headers (`.hpp`). Anything bigger is a project.
- **Project:** generate it, never copy another one: `cmake -DNAME=<snake_case> -P
  cmake/new_project.cmake`. It creates `<name>_lib` (library), `<name>` (executable whose `main`
  wraps its body in `common::run_main`) and `<name>_tests`, plus a `README.md`. Every target added
  later calls `cpp_lab_set_warnings(<target>)`. To change what new projects look like, edit
  `templates/project/`; the check workflows build a project generated from it.
- **Tests:** `cpp_lab_add_tests(<target> <sources…>)`, then link the library under test with
  `target_link_libraries(<target> PRIVATE <lib>)`. Test files are named `test_<topic>.cpp`.
- **Shared code:** move code into `common/` only once it is needed in at least two places.
  `common/CMakeLists.txt` lists its sources explicitly.
- **Dependencies:** none without an ADR. Fetch with `FetchContent`, pinned by URL + SHA256.

## Where knowledge goes

| What                                                 | Where              |
| ---------------------------------------------------- | ------------------ |
| Why the _current_ code is non-obvious                | Short code comment |
| Why a change was made                                | Commit message     |
| Decisions with lasting impact, alternatives, history | ADR in `docs/adr/` |
| Old code                                             | Git history        |

- **No comments** narrating decisions, history, or "changed from …/previously …".
- **No comments** restating what the code obviously does.
- Tooling, build and dependency changes get an ADR (`docs/adr/0000-template.md`). ADRs are never
  rewritten: a changed decision gets a new ADR, and the old one is marked
  `Superseded by NNNN`.
- ADRs exist at two levels, same template and rules:

  | A decision about…                                                   | Goes in                     |
  | ------------------------------------------------------------------- | --------------------------- |
  | one project's code, design or algorithms                            | `projects/<name>/docs/adr/` |
  | the build, tooling, `common/`, the conventions, or several projects | `docs/adr/`                 |

  If the ADR would mean nothing once the project is deleted, it belongs to the project. Project
  ADRs are numbered per project; the folder is created with the first one.

## Code style

Follow [docs/conventions.md](docs/conventions.md).

## Public repository

This repository is public.

- Don't describe planned or unimplemented projects in any committed file (code, examples, docs,
  ADRs, test data, commit messages). A project is mentioned once it exists in `projects/`.
- No personal machine details (user folders, machine names) in committed files.

## Git

- **Never stage, unstage or commit** (`git add`, `git reset`, `git commit`, …) unless explicitly instructed to do so. Read-only commands (`status`, `diff`, `log`) are fine.
- Don't add entries to `.gitignore` unless asked; it grows by hand as needs appear.
- Commits go through the hooks in `.githooks/` (formatting, personal paths, machine name, a private
  word list). When committing on request, never bypass them (`--no-verify`) unless explicitly
  told to; fix the finding instead.
