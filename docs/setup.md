# Machine setup

How to get from a fresh Windows machine to a passing `cppchk`. Step 3 is automated by
`Install-CppLabToolchain`, step 4 by `Enable-CppLabGitHooks`.

## Tested versions

| Tool | Version | Pinned by | Role |
| ---- | ------- | --------- | ---- |
| Windows | 11, x64 | — | |
| Visual Studio Community 2026 (or Build Tools 2026) | 18.10, MSVC 14.51 (`cl` 19.51) | `.vsconfig` (components) | Main compiler, linker, standard library, ASan |
| Windows SDK | 10.0.26100 | `.vsconfig` | Windows headers and libraries (clang uses them too) |
| LLVM | 21.1.0 | `Install-CppLabToolchain` | clang, clangd, clang-tidy, clang-format |
| CMake | 4.4.3 | `Install-CppLabToolchain` | Build description, presets, tests |
| Ninja | 1.13.2 | `Install-CppLabToolchain` | Runs the build |
| doctest | 2.5.3 | `cmake/doctest.cmake` (URL + SHA256) | Tests; downloaded at the first configure |
| PowerShell | 7.6 | — | `scripts/cpp-lab.ps1` needs 7+ |
| Git | 2.51+ | — (latest) | |
| VSCode | 1.140 | — (latest) | Editor |
| VSCode extensions | CMake Tools 1.24, clangd 0.6, C/C++ 1.34 | `.vscode/extensions.json` (latest) | |

`cmake_minimum_required(VERSION 3.28)` and `.clang-format` options depend on these versions.
A different clang-format version may format slightly differently.

## 1. Prerequisites

- **winget** (App Installer, included in Windows 11). Check: `winget --version`.
- **PowerShell 7**: `winget install --id Microsoft.PowerShell --exact`. Open "PowerShell", not
  "Windows PowerShell" (5.1).
- **Git**, to clone: `winget install --id Git.Git --exact`.

## 2. Clone

```powershell
git clone <repository URL> cpp-lab
cd cpp-lab
```

- **Keep the path short** (e.g. `C:\dev\cpp-lab`). Build folders nest deeply, and MSVC fails on
  paths over 260 characters with `fatal error C1083: Cannot open compiler generated file: '':
  Invalid argument`. A repository path of about 100 characters or less is safe.
- Avoid a folder synchronized by OneDrive or similar for the build: locked files cause random
  "file in use" / `LNK1104` errors. If the clone is in such a folder, exclude it from sync.

## 3. Install the toolchain

```powershell
. .\scripts\cpp-lab.ps1
Install-CppLabToolchain -WhatIf    # shows what would be installed or changed
Install-CppLabToolchain
```

- Missing tools are installed with winget at the versions above (Windows may ask for
  administrator rights).
- **Installed tools are not upgraded or downgraded.** A different version produces a warning with
  the `winget` command to match it.
- A tool installed but not on `PATH` (LLVM's installer doesn't add itself by default) gets its
  folder added to the user `PATH`.
- **Visual Studio**:
  - none installed → Build Tools 2026 are installed with the components of `.vsconfig`;
  - installed but missing components → a warning with the command to add them, or use the
    Visual Studio Installer: *More* → *Import configuration* → select `.vsconfig`;
  - Visual Studio Community/Professional/Enterprise work as well as the Build Tools. The IDE is
    never used.
- Missing VSCode extensions from `.vscode/extensions.json` are installed.

Then **open a new terminal** so every program sees the new `PATH`.

## 4. Git hooks

```powershell
Enable-CppLabGitHooks             # git config core.hooksPath .githooks
```

Every commit then checks its staged changes: C++ formatting, no personal path (`<drive>:\Users\<name>\…`), no
machine name, and no word from an optional private list, `.git/info/forbidden-words` (one word or
phrase per line; inside `.git/`, so never committed). The commit message is checked against the
same list. Skip once with `git commit --no-verify`.

## 5. Shell commands (optional)

Add to your PowerShell profile (`code $PROFILE`):

```powershell
. <path to cpp-lab>\scripts\cpp-lab.ps1
```

Commands: [docs/shell.md](shell.md).

## 6. VSCode

1. Open the repository folder. Accept the recommended extensions if asked.
2. CMake Tools configures automatically; pick the `msvc-debug` configure preset.
3. A `compile_commands.json` appears at the root; clangd uses it.

Shortcuts: [docs/vscode.md](vscode.md).

## 7. Verify

```powershell
cppchk                                     # or, without the shell commands:
cmake --workflow --preset check            # clang, clang-tidy, warnings as errors, all tests
vsdev; cmake --workflow --preset check-msvc
```

Both end with `100% tests passed`. The first configure of each preset downloads doctest (network
needed once per build folder).

In VSCode: `pg_hello` builds with **F7** and runs with **Ctrl+Shift+F5**; `hello.cpp` shows no
errors; the Testing panel lists the tests.

## Known pitfalls

| Symptom | Cause | Fix |
| ------- | ----- | --- |
| `fatal error C1083: Cannot open compiler generated file: '': Invalid argument` (often during the first configure) | Path longer than 260 characters inside the build folder | Clone into a shorter path |
| `cmake --preset msvc-…`: "CXX compiler identification is unknown" | Not in the Visual Studio developer environment (MSVC isn't on `PATH` otherwise) | `vsdev` (or "Developer PowerShell for VS 2026"); VSCode does it by itself |
| `winget install Microsoft.VisualStudio.BuildTools` upgrades Visual Studio Community instead | winget lists Community 2026 under the Build Tools id | Use the Visual Studio Installer, or let `Install-CppLabToolchain` decide |
| An `msvc-asan` program exits immediately with `0xC0000135` and no message | ASan runtime DLL not found | Run it from `build/msvc-asan/bin/` (the DLL is copied there at configure) |
| A *Debug Error* dialog (Abort/Retry/Ignore) blocks a run | MSVC debug runtime assertion or heap check | Expected in Debug for real bugs. Tests never show it (shared test main) |
| clang-tidy or clangd don't find `clang-tidy`/`clangd` | LLVM not on `PATH` | `Install-CppLabToolchain` adds it |
| Files show as modified right after cloning | Line endings | `.gitattributes` forces LF; run `git add --renormalize .` once if it happens |
| A removed target's `.exe` is still in `bin/` | Build systems don't delete outputs of removed targets | `cppclean <preset>` |
| Strange build errors after many changes | Stale build folder | `cmake --preset <p> --fresh`, or `cppclean <preset>` |
