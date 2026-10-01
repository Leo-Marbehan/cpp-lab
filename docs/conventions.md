# C++ conventions

## Formatting and linting

- Formatting is automatic: `.clang-format` (LLVM-based, 2-space indent, 120 columns), applied on
  save in VSCode, or with `cmake --build --preset <p> --target format`. Don't format by hand.
- `.clang-tidy` checks bugs, modern C++, performance, readability and the naming rules below.
  Findings show in the editor; `cmake --workflow --preset lint` / `check` fail on any of them.
- `ctest` includes a `format_check` test: unformatted files fail the test run.

### Suppressing a finding

Fix the code when possible. When a finding is wrong for a specific case, suppress it as
narrowly as possible, **naming the check and giving the reason**:

```cpp
// NOLINTNEXTLINE(readability-identifier-naming): the name is fixed by doctest.
#define DOCTEST_CONFIG_IMPLEMENT
```

| Scope                 | Form                                                                        |
| --------------------- | --------------------------------------------------------------------------- |
| One line              | `// NOLINT(check-name): reason` at the end of the line                      |
| The next line         | `// NOLINTNEXTLINE(check-name): reason` on the line above                   |
| A block               | `// NOLINTBEGIN(check-name): reason` … `// NOLINTEND(check-name)`           |
| A folder              | `.clang-tidy` in the folder: `InheritParentConfig: true` + `Checks: '-check-name'`, with a comment |
| Formatting of a block | `// clang-format off` … `// clang-format on` (e.g. a hand-aligned table)    |
| MSVC warning          | `#pragma warning(suppress: NNNN)` on the line above                         |
| clang warning         | `#pragma clang diagnostic push` / `ignored "-Wname"` / `pop`                |

Never a bare `// NOLINT` without a check name.

## Files

- `.hpp` for C++ headers, `.cpp` for sources. `.h` only for headers that must also compile as C.
- `snake_case` file names: `csv_reader.hpp`, `csv_reader.cpp`.
- A header and its source share the name; one main class or topic per header.
- `#pragma once` in every header.
- Include what you use: include the header of every standard or library symbol the file uses,
  even if another include already brings it in (`misc-include-cleaner`).
- Tests: `tests/test_<topic>.cpp`.

## Includes

- `<...>` for `common`, third-party and standard headers; `"..."` for files of the same project.
- Order, one blank line between groups:
  1. the header matching this `.cpp`
  2. same project
  3. `common`
  4. third-party (e.g. `<doctest/doctest.h>`)
  5. standard library
- Never `using namespace std;`, and no `using namespace` at all in headers.

## Naming

Like the standard library (`std::numbers::pi`, `std::errc::invalid_argument`), except that
types are `PascalCase`.

| Kind                                 | Style                  | Example                     |
| ------------------------------------ | ---------------------- | --------------------------- |
| Types, concepts, type aliases        | `PascalCase`           | `CsvReader`, `RowView`      |
| Functions, variables, parameters     | `snake_case`           | `read_rows`, `row_count`    |
| Constants (`constexpr`, `const`)     | `snake_case`           | `max_rows`                  |
| Enumerators                          | `snake_case`           | `Color::dark_red`           |
| Namespaces                           | `snake_case`           | `common`, `my_project`      |
| Private data members                 | `snake_case_`          | `rows_`                     |
| Macros (avoid)                       | `CPP_LAB_UPPER_CASE`   | `CPP_LAB_ASSERT`            |

## Namespaces

- Shared code in `common`, one namespace per project, named after its folder in `projects/`.
- Close with a comment: `} // namespace common`.
- Internal helpers: an anonymous namespace in the `.cpp`, or `namespace detail` in a header.

## Habits

- RAII everywhere; no raw `new`/`delete`. `std::unique_ptr` by default.
- Read-only parameters: `std::string_view`, `std::span`, or `const&` for other non-trivial types.
- `const` by default; `[[nodiscard]]` on functions whose result must not be ignored.
- `enum class`, not plain `enum`.
- No magic numbers, tests included: name them (`constexpr int limit = 50;`). Lists of test
  values go in a `constexpr std::array`, checked in a loop with `CAPTURE(value)`.
- Project `main` functions don't let exceptions escape. Wrap the body in `common::run_main`
  (`<common/run_main.hpp>`): any exception is printed as `error: <message>` on stderr and
  becomes `EXIT_FAILURE`. The body returns an exit code or nothing (`EXIT_SUCCESS`).

  ```cpp
  int main() {
    return common::run_main([] {
      // ...
    });
  }
  ```

  Playground programs may use it but don't have to (`playground/.clang-tidy`).
- Fixed-width integers (`std::int64_t`) when the range matters.
- Prefer standard algorithms and ranges over hand-written loops when they are clearer.
- Randomness: seed explicitly, make the seed configurable and print it, so any run can be
  reproduced.
