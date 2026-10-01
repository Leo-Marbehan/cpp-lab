# 0003. Build with CMake, Ninja and CMake presets

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

The build has to work the same from the command line and from VSCode, with two compilers and
several configurations, without long command lines to remember.

## Decision

- CMake (`cmake_minimum_required(VERSION 3.28)`), Ninja generator, C++20 without compiler
  extensions, `CMAKE_EXPORT_COMPILE_COMMANDS` on.
- `CMakePresets.json` (presets format version 8) defines every configuration. Hidden building
  blocks (`base`, `msvc`, `clang`, `debug`, `release`) are combined with `inherits`; each visible
  configure preset has a build and a test preset of the same name.
- Build folders: `build/<preset>/`.
- `architecture`/`toolset` with `strategy: external`, so VSCode CMake Tools sets up the Visual
  Studio developer environment.

## Consequences

- `cmake --preset X`, `cmake --build --preset X`, `ctest --preset X` for every configuration.
- On the command line, the MSVC presets only work inside the developer environment
  (`strategy: external` is ignored by CMake itself). The clang presets work from any shell.
- One build folder per preset: switching configuration never requires a reconfigure, and
  deleting a folder resets that configuration.
- C++20 + CMake ≥ 3.28 enables module dependency scanning, which adds build steps even though
  modules aren't used.
