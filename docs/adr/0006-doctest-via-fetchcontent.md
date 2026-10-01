# 0006. Test with doctest, fetched with FetchContent

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

Unit tests need a framework integrated with CTest and the VSCode Testing panel. Candidates:
doctest (single header, fast to compile) and Catch2. Dependency options: FetchContent, vcpkg,
Conan. MSVC's debug C runtime reports assertions and heap errors in a modal dialog, which blocks
unattended test runs.

## Decision

- doctest v2.5.3, fetched with `FetchContent` from the release tarball, pinned with
  `URL_HASH SHA256`, declared `SYSTEM`.
- A shared test `main` (`testing/`, target `cpp_lab_test_main`) that sends debug-CRT reports to
  stderr and disables the `abort()` dialog, instead of doctest's own `doctest_with_main`.
- `cpp_lab_add_tests(<target> <sources…>)` creates a test executable, applies the warnings and
  registers every `TEST_CASE` with CTest (`doctest_discover_tests`).
- vcpkg only if heavier dependencies become necessary (would need its own ADR).

## Consequences

- Reproducible: the download is verified against the hash.
- Each build folder has its own copy (`build/<preset>/_deps/`); the first configure needs network
  access.
- No warnings from doctest's headers despite the strict warning flags.
- Test failures and debug-CRT errors show in the test output and fail the test instead of
  waiting for a click. Playground programs and projects keep the normal `main` (dialog available for
  interactive debugging).
- Tests are discovered by running the test executable at build time.
