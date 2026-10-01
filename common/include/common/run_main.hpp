#pragma once

#include <concepts>
#include <cstdlib>
#include <exception>
#include <functional>
#include <type_traits>
#include <utility>

namespace common {

namespace detail {

// Writes "error: <message>" to stderr. Never throws.
void print_error(const char* message) noexcept;

} // namespace detail

// Runs a program body and turns any exception into a message on stderr and EXIT_FAILURE.
// The body returns an exit code (int) or nothing (void, meaning EXIT_SUCCESS).
//
//   int main() {
//     return common::run_main([] { ... });
//   }
template <std::invocable Program>
  requires std::same_as<std::invoke_result_t<Program>, int> || std::same_as<std::invoke_result_t<Program>, void>
[[nodiscard]] int run_main(Program&& program) noexcept {
  try {
    if constexpr (std::is_void_v<std::invoke_result_t<Program>>) {
      std::invoke(std::forward<Program>(program));
      return EXIT_SUCCESS;
    } else {
      return std::invoke(std::forward<Program>(program));
    }
  } catch (const std::exception& e) {
    detail::print_error(e.what());
  } catch (...) {
    detail::print_error("unknown exception");
  }
  return EXIT_FAILURE;
}

} // namespace common
