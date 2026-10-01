# 0009. Format with clang-format, lint with clang-tidy, gate with workflow presets

- **Status:** Accepted
- **Date:** 2026-10-01

## Context

Formatting and static analysis should be automatic, identical in the editor and on the command
line, and strict, without slowing down everyday builds. LLVM 21 provides clang-format and
clang-tidy. clang-tidy offers about 450 checks in general-purpose groups, plus organisation-
specific groups (`fuchsia-*`, `llvmlibc-*`, `altera-*`, `google-*`, `llvm-*`, …) whose rules
contradict each other or this repository's conventions. clang-tidy is slow compared to a compile.

## Decision

**Formatting** — `.clang-format`, based on LLVM style: 2-space indent, 120 columns, `char* p`
pointer style, braces always inserted, only empty functions on one line
(`AllowShortFunctionsOnASingleLine: Empty`), includes regrouped in the order of `docs/conventions.md`
(`MainIncludeChar: Any` so the matching `<common/x.hpp>` counts as the main include).
Format on save in VSCode. CMake targets `format` (rewrite) and `format-check`, and a CTest test
`format_check`, so every `ctest` run fails on unformatted files.

**Linting** — `.clang-tidy` enables every general-purpose group: `bugprone`, `cert`,
`clang-analyzer`, `concurrency`, `cppcoreguidelines`, `misc`, `modernize`, `performance`,
`portability`, `readability`. `readability-identifier-naming` enforces the naming table.
Disabled:

| Check | Why |
| ----- | --- |
| `bugprone-easily-swappable-parameters` | Flags every function with two parameters of the same type. |
| `modernize-use-trailing-return-type` | Would require `auto f() -> int` everywhere. |
| `portability-avoid-pragma-once` | Contradicts the `#pragma once` convention; every compiler used supports it. |
| `readability-identifier-length` | Flags conventional short names (`i`, `n`, `e`). |

`playground/.clang-tidy` additionally disables `bugprone-exception-escape`: for single-file
programs an exception escaping `main` (reported by `std::terminate`) is acceptable, and a
`try`/`catch` in every file isn't worth it. Projects keep the check; their `main` wraps its body
in `common::run_main`, a `noexcept` function template that catches `std::exception` (prints
`error: <what()>`) and `...` (prints `error: unknown exception`) and returns `EXIT_FAILURE`.
The `try`/`catch` exists once, in `common`, instead of in every `main`.

Magic-number checks stay enabled everywhere, tests included.

### Strictness levels

| Level | How | Contents |
| ----- | --- | -------- |
| Everyday | `msvc-debug`, `clang-debug`, … | Warnings stay warnings, no clang-tidy (the editor shows its findings through clangd). |
| `cmake --workflow --preset lint` | configure preset `clang-check` | clang-tidy with `--warnings-as-errors=*`, compiler warnings as errors (`CMAKE_COMPILE_WARNING_AS_ERROR`), `format_check` only. |
| `cmake --workflow --preset check` | configure preset `clang-check` | Same build, all tests. The gate before committing and for CI. |
| `cmake --workflow --preset check-msvc` | configure preset `msvc-check` | MSVC with warnings as errors, all tests. |

**Suppressions** always name the check and give a reason:
`// NOLINTNEXTLINE(check-name): reason`; a folder-level `.clang-tidy` with
`InheritParentConfig: true` for folder-wide exceptions. No bare `// NOLINT`.

## Consequences

- One command checks everything: `cmake --workflow --preset check` (plus `check-msvc` inside the
  developer environment).
- clang-tidy only runs in the `clang-check` build folder; everyday builds stay fast.
- `misc-include-cleaner` enforces include-what-you-use: every header whose symbols a file uses is
  included directly.
- Findings found in the existing code: missing direct includes, magic numbers, exceptions
  escaping `main` (→ `common::run_main`), the doctest configuration macro (`DOCTEST_CONFIG_IMPLEMENT`, suppressed: name
  fixed by doctest), and `<stdlib.h>` needed for the Microsoft extension `_set_abort_behavior`
  (suppressed `modernize-deprecated-headers`).
- Magic-number checks don't see literals written inside doctest macros (`CHECK(f(97))`): named
  constants in tests are a convention, not enforced.
- `common::run_main` prints with `std::fputs`/`std::fputc`, which can't throw (a `std::cerr`
  call inside a `catch` still counts as "may throw" for `bugprone-exception-escape`);
  `cert-err33-c` accepts `static_cast<void>(…)` for their ignored results.
- clang-format settings depend on its version; written against clang-format 21.
- LLVM's default `AllowShortFunctionsOnASingleLine: All` would put any short function on one
  line (`int f() { return 0; }`); `Empty` keeps that only for empty bodies (`Point() {}`).
