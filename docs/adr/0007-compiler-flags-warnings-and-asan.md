# 0007. Apply conformance flags globally, warnings per target, ASan through a preset

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

MSVC's defaults are not fully standard-conforming (for example `__cplusplus` reports `199711`
whatever the standard). Strict warnings are wanted on our code, but not on third-party code.
AddressSanitizer is available with MSVC; MSVC documents `/RTC` and incremental linking as
incompatible with it (MSVC 19.51 actually accepts `/RTC1` with ASan without complaint). ASan
executables import `clang_rt.asan_dynamic-x86_64.dll`, which is only on `PATH` inside the
developer environment; without it the program exits with `0xC0000135` and no message.

## Decision

In `cmake/compiler_flags.cmake`:

- **Global** (all targets), MSVC-style frontend: `/permissive- /utf-8 /Zc:__cplusplus
  /Zc:preprocessor`.
- **Per target**, `PRIVATE`, through `cpp_lab_set_warnings(<target>)`: `/W4` (MSVC-style), or
  `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion -Wold-style-cast
  -Wnon-virtual-dtor -Woverloaded-virtual -Wimplicit-fallthrough` (GNU-style).
- Flag choice is based on `CMAKE_CXX_COMPILER_FRONTEND_VARIANT` (flag style), not the compiler id.
- **ASan:** option `CPP_LAB_ENABLE_ASAN` (MSVC only), turned on by the `msvc-asan` preset:
  adds `/fsanitize=address`, removes `/RTC1`, switches the debug linker to `/INCREMENTAL:NO`,
  and copies the ASan DLL next to the executables.
- All executables go to `build/<preset>/bin/` (`CMAKE_RUNTIME_OUTPUT_DIRECTORY`).
- Warnings are not errors (yet).

## Consequences

- Every target must call `cpp_lab_set_warnings` (done by the playground loop and
  `cpp_lab_add_tests`; projects call it themselves).
- `msvc-asan` executables run from any shell and from VSCode's debugger.
- No clang ASan preset: clang's ASan on Windows doesn't support the debug C runtime (`/MDd`).
- Warnings as errors is still open (candidate: `CMAKE_COMPILE_WARNING_AS_ERROR` in a check
  workflow).
