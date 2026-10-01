# C++ conventions

Formatting details (indentation, braces, line length) will be enforced by `.clang-format`.
Until then, follow the existing code: 4-space indentation, opening braces on the same line.

## Files

- `.hpp` for C++ headers, `.cpp` for sources. `.h` only for headers that must also compile as C.
- `snake_case` file names: `csv_reader.hpp`, `csv_reader.cpp`.
- A header and its source share the name; one main class or topic per header.
- `#pragma once` in every header.
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
- Fixed-width integers (`std::int64_t`) when the range matters.
- Prefer standard algorithms and ranges over hand-written loops when they are clearer.
- Randomness: seed explicitly, make the seed configurable and print it, so any run can be
  reproduced.
