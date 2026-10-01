#include <common/run_main.hpp>

#include <cstdio>

namespace common::detail {

void print_error(const char* message) noexcept {
  // std::fputs/std::fputc can't throw, unlike std::cerr. A failed write to stderr can't be reported anywhere, so the
  // results are ignored on purpose.
  static_cast<void>(std::fputs("error: ", stderr));
  static_cast<void>(std::fputs(message, stderr));
  static_cast<void>(std::fputc('\n', stderr));
}

} // namespace common::detail
