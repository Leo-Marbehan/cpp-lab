// NOLINTNEXTLINE(readability-identifier-naming): the name is fixed by doctest.
#define DOCTEST_CONFIG_IMPLEMENT
#include <common/run_main.hpp>

#include <doctest/doctest.h>

#ifdef _WIN32
#include <crtdbg.h>
// NOLINTNEXTLINE(modernize-deprecated-headers): _set_abort_behavior is a Microsoft extension declared in <stdlib.h>.
#include <stdlib.h>
#endif

int main(int argc, char** argv) {
#ifdef _WIN32
  // The debug CRT reports assertions and heap errors in a modal dialog, which blocks
  // unattended runs (ctest, CI). Print them to stderr instead, and let abort() exit silently.
  _CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_WARN, _CRTDBG_FILE_STDERR);
  _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDERR);
  _CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDERR);
  _set_abort_behavior(0, _WRITE_ABORT_MSG | _CALL_REPORTFAULT);
#endif
  return common::run_main([argc, argv] { return doctest::Context(argc, argv).run(); });
}
