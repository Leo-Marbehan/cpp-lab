# 0005. Use clangd for code intelligence in VSCode

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

VSCode needs completion, navigation and error highlighting that match the real build. Options:
the Microsoft C/C++ extension's IntelliSense, or clangd. Running both gives duplicate,
conflicting diagnostics. The Microsoft extension is still the way to use the Visual Studio
debugger (`cppvsdbg`).

## Decision

- clangd (`llvm-vs-code-extensions.vscode-clangd`, using LLVM's `clangd.exe`) for code
  intelligence, reading `compile_commands.json`.
- Microsoft C/C++ installed for debugging only, with `C_Cpp.intelliSenseEngine: disabled`.
- CMake Tools copies the active preset's `compile_commands.json` to the repo root
  (`cmake.copyCompileCommands`), so clangd follows preset changes.
- Workspace settings, recommended extensions and the debug configuration are committed in
  `.vscode/`.

## Consequences

- Editor diagnostics come from clang's parser with the exact flags of the build, including MSVC
  flags (clangd understands `cl.exe` command lines).
- clang-tidy findings show in the editor (`--clang-tidy`).
- `clangd --check=<file>` diagnoses editor problems from the command line.
- The root `compile_commands.json` and clangd's `.cache/` are generated and not committed.
