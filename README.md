# cpp-lab

A personal monorepo for practicing modern C++ (C++20): single-file experiments, small projects,
and the shared code they grow into. One build configuration for everything, strict by default.

- **CMake + Ninja**, configured through presets; two compilers, **MSVC** and **clang**.
- **Strict checks**: warnings as errors, ~450 clang-tidy checks, clang-format, AddressSanitizer.
- **Tests** with doctest, one CTest test per test case.
- **No per-project setup**: a new playground file or project is picked up by the build
  automatically; projects are generated from templates.
- Windows and VSCode.

## Quick start

Requirements and full setup: [docs/setup.md](docs/setup.md).

```powershell
. .\scripts\cpp-lab.ps1
Install-CppLabToolchain               # pinned toolchain; -WhatIf to preview

cmake --preset clang-debug
cmake --build --preset clang-debug
.\build\clang-debug\bin\pg_hello.exe

cmake --workflow --preset check       # everything: lint, warnings as errors, tests
```

The MSVC presets need the Visual Studio developer environment: run `vsdev` first (defined by
`scripts/cpp-lab.ps1`). VSCode sets it up by itself.

## Layout

| Path | Content |
| ---- | ------- |
| `playground/` | Every `.cpp` (subfolders included) is its own program: `playground/math/primes.cpp` → `pg_math_primes` |
| `projects/` | Projects, one folder each, created with `cmake -DNAME=<name> -P cmake/new_project.cmake` |
| `common/` | Shared library `common` (`#include <common/…>`) with its tests |
| `testing/` | Shared test runner |
| `cmake/` | Compiler flags, tests, formatting, project generator |
| `templates/` | Project templates |
| `scripts/` | `cpp-lab.ps1`: shell commands and toolchain installer |
| `docs/` | Setup, conventions, cheat sheets, decision records |

## Documentation

| Document | Content |
| -------- | ------- |
| [docs/setup.md](docs/setup.md) | New machine to passing checks, tested versions, pitfalls |
| [docs/conventions.md](docs/conventions.md) | C++ style, naming, formatting, linting, suppressions |
| [docs/vscode.md](docs/vscode.md) | VSCode shortcuts and command IDs |
| [docs/shell.md](docs/shell.md) | Shell commands (`cppbuild`, `cppchk`, …) |
| [docs/adr/](docs/adr/) | Architecture decision records: why things are the way they are |
| [AGENTS.md](AGENTS.md) | Rules for AI coding agents (and humans) |

## License

[MIT](LICENSE).
