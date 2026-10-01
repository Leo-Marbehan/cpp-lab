# 0011. Create projects with a CMake-script generator

- **Status:** Accepted
- **Date:** 2026-10-01

## Context

Starting a project by copying an existing one leaves stale names behind (targets, namespaces,
test names). A project also needs a consistent structure to be testable: tests must link a
library, not an executable. Options: a C++ tool (needs building first, templates inside string
literals), a PowerShell script (ADR 0008 keeps PowerShell for shell-level tasks), or a CMake
script run with `cmake -P` (no build step; CMake is always available).

## Decision

- `cmake -DNAME=<name> -P cmake/new_project.cmake` creates `projects/<name>/` from the templates
  in `templates/project/` (`configure_file(… @ONLY)`, placeholder `@NAME@`).
- The name is validated: `snake_case`, not a C++ keyword, not reserved (`std`, `common`,
  `testing`, CMake/repository target names, `pg_`/`cpp_lab_` prefixes), folder not existing, no
  clash with another project's `<x>_lib`/`<x>_tests`.
- Generated layout:

  ```text
  projects/<name>/
  ├─ CMakeLists.txt              <name>_lib (static library) + <name> (executable) + <name>_tests
  ├─ README.md                   description placeholder, build/run/test commands, layout
  ├─ include/<name>/<name>.hpp   public header, included as "<name>/<name>.hpp" inside the project
  ├─ src/<name>.cpp              library code, namespace <name>
  ├─ src/main.cpp                return common::run_main([] { … });
  └─ tests/test_<name>.cpp       doctest; test names prefixed "<name>: "
  ```

- **Guard against stale templates:** the `clang-check` and `msvc-check` presets set
  `CPP_LAB_CHECK_GENERATOR=ON` (`cmake/generator_check.cmake`): every configure regenerates a
  project `generator_example` inside the build folder (a name reserved for this, allowed only with
  `-DGENERATOR_SELF_TEST=ON`) and builds it like a real project
  (warnings as errors, clang-tidy, its tests, a `format_check_generated` test). Changing a
  template re-runs the configure.

## Consequences

- A new project builds, passes the checks and has a test from the first minute.
- Templates are plain files, edited like code; the check workflows fail if they drift from the
  conventions.
- `generator_example` exists only in the check build folders, not in everyday presets.
- `projects/` contains only a `README.md` until the first project exists.
- No generator for playground files: a playground program is a single file anyway.
