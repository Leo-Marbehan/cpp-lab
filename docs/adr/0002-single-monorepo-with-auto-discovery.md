# 0002. Use a single monorepo with automatic target discovery

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

The repository holds small, unrelated single-file programs and projects that should share one
build configuration and some common code, with no setup per project. Considered: one repository per project, git submodules, a template repository.

## Decision

- One repository. Shared code in `common/` (a static library, included as
  `<common/xxx.hpp>` via a `PUBLIC` include directory).
- The root `CMakeLists.txt` discovers targets with `file(GLOB … CONFIGURE_DEPENDS …)`:
  - every `projects/<name>/` containing a `CMakeLists.txt` is added with `add_subdirectory`;
  - every `playground/**/*.cpp` (subfolders included, `GLOB_RECURSE`) becomes an executable
    linked to `common`, named `pg_` + its path relative to `playground/` without the extension,
    with `/` replaced by `_` (`playground/math/primes.cpp` → `pg_math_primes`).
- `common/` lists its sources explicitly.
- Code moves into `common/` only once it is needed in at least two places.

## Consequences

- A new single-file program is one file; a new project is a folder with a `CMakeLists.txt`.
- `playground/` is named for its use (trying things out) and its shape (one file, one program);
  subfolders only organize. A helper shared by several playground files has to be a header, since
  every `.cpp` is a separate program.
- `CONFIGURE_DEPENDS` makes the build re-run CMake when files are added or removed
  (a small check on every build).
- The `pg_` prefix avoids target-name clashes with projects (`pg_hello` and `hello` coexist);
  including the path avoids clashes between subfolders (`pg_math_sort`, `pg_strings_sort`).
  Target names must still be unique across all projects.
- Build systems don't delete outputs of removed targets; stale executables stay in the build
  folder until it is cleaned.
