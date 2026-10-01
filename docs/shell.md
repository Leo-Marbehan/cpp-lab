# Shell cheat sheet

Short PowerShell commands defined by [`scripts/cpp-lab.ps1`](../scripts/cpp-lab.ps1). They only
wrap the `cmake`/`ctest` commands of [`AGENTS.md`](../AGENTS.md), and work from any folder.

## Setup

Requires PowerShell 7. Add one line to your profile (open it with `code $PROFILE`):

```powershell
. <path to cpp-lab>\scripts\cpp-lab.ps1
```

Loading only defines the commands below; nothing runs until one is called.

## Commands

| Alias      | Function               | Does                                                                     |
| ---------- | ---------------------- | ------------------------------------------------------------------------ |
| `cppdir`   | `Set-CppLabLocation`   | Go to the repository                                                     |
| `vsdev`    | `Enter-CppLabDevShell` | Load the x64 MSVC developer environment into the current shell           |
| `cppbuild` | `Invoke-CppLabBuild`   | Configure (first time only), then build a preset                         |
| `cpptest`  | `Invoke-CppLabTest`    | Build, then run the tests                                                |
| `cppchk`   | `Invoke-CppLabCheck`   | Run the check workflows (the gate before committing)                     |
| `cppnew`   | `New-CppLabProject`    | Create `projects/<name>/` from `templates/project/`                      |
| `cppclean` | `Remove-CppLabBuild`   | Delete build folders                                                     |

Without alias: `Install-CppLabToolchain [-WhatIf]` installs the pinned toolchain on a new machine
(see [setup.md](setup.md)).

Commands using an `msvc*` preset or the `check-msvc` workflow call `vsdev` themselves.
`vsdev` does nothing if the environment is already loaded.

## Parameters and examples

| Command                                | Parameters                                    | Default                       |
| -------------------------------------- | --------------------------------------------- | ----------------------------- |
| `cppbuild [-Preset <p>] [-Target <t>]` | configure preset, single target               | `msvc-debug`, everything      |
| `cpptest [-Preset <p>] [-Filter <re>]` | configure preset, test-name regex (`ctest -R`) | `msvc-debug`, all tests      |
| `cppchk [-Workflow <w>[,<w>]]`         | workflow presets                              | `check`, `check-msvc`         |
| `cppnew -Name <name>`                  | `snake_case` project name                     | —                             |
| `cppclean <preset>` / `cppclean -All`  | one build folder, or all of `build/`; `-WhatIf` shows what would be deleted | — |

```powershell
cppbuild                          # build msvc-debug
cppbuild clang-release -Target pg_math_primes
cpptest -Filter "^is_prime"       # only the matching test cases
cppchk                            # check + check-msvc, before committing
cppchk -Workflow lint             # clang-tidy + formatting only
cppnew my_project                 # then cppbuild picks it up
cppclean msvc-asan -WhatIf
```

`-Preset` and `-Workflow` complete with **Tab**, from the presets in `CMakePresets.json`.

Full help for any command: `Get-Help <function name>` (e.g. `Get-Help Invoke-CppLabBuild`).
