#include <common/run_main.hpp>

#include <doctest/doctest.h>

#include <cstdlib>
#include <stdexcept>

namespace {

struct NotAStdException {};

} // namespace

TEST_CASE("run_main: a void body succeeds") {
  bool ran = false;
  CHECK(common::run_main([&ran] { ran = true; }) == EXIT_SUCCESS);
  CHECK(ran);
}

TEST_CASE("run_main: an int body's exit code is returned") {
  constexpr int exit_code = 42;
  CHECK(common::run_main([] { return exit_code; }) == exit_code);
}

TEST_CASE("run_main: a std::exception becomes EXIT_FAILURE") {
  CHECK(common::run_main([] { throw std::runtime_error("expected by the test"); }) == EXIT_FAILURE);
}

TEST_CASE("run_main: an exception not derived from std::exception becomes EXIT_FAILURE") {
  CHECK(common::run_main([] { throw NotAStdException{}; }) == EXIT_FAILURE);
}
