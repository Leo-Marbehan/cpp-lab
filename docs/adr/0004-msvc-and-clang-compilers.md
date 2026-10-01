# 0004. Use MSVC as the main compiler and clang as the second

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

Options on Windows: MSVC (Visual Studio), GCC via MSYS2 (UCRT64), clang. Found on the machine:
Visual Studio Community 2026 (MSVC 14.51, with AddressSanitizer) and LLVM 21 (clang targeting
the MSVC ABI, clangd, clang-tidy, clang-format). MSYS2 was not installed. GCC on MSYS2 has no
AddressSanitizer.

## Decision

- MSVC is the main compiler, taken from the existing Visual Studio Community installation (the
  IDE itself is not used; VSCode is the editor). The standalone Build Tools are not installed.
- clang (standalone LLVM, `x86_64-pc-windows-msvc`) is the second compiler. It uses the same MSVC
  standard library and Windows SDK.
- No GCC/MSYS2.

## Consequences

- Two independent compilers catch more problems: on the same code, MSVC `/W4` reported 2
  warnings and clang's warning set 6.
- One standard library and one SDK: no second toolchain to install or keep in sync.
- clang still requires Visual Studio (or the Build Tools) for the SDK and C++ library.
- Portability to libstdc++/GCC is not checked. Can be added later (MSYS2 preset or a Linux CI
  job).
- winget lists VS Community 2026 under the id `Microsoft.VisualStudio.BuildTools`, so installing
  the Build Tools with winget on a machine that has Community upgrades Community instead.
