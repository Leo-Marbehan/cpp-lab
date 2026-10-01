include(FetchContent)

FetchContent_Declare(doctest
    URL https://github.com/doctest/doctest/archive/refs/tags/v2.5.3.tar.gz
    URL_HASH SHA256=174ebc4e769928959614789c5b4e9c3d0a0f81a62bb608756b127bfebfb21331
    SYSTEM
)
set(DOCTEST_WITH_MAIN_IN_STATIC_LIB OFF)
FetchContent_MakeAvailable(doctest)

include("${doctest_SOURCE_DIR}/scripts/cmake/doctest.cmake")

function(cpp_lab_add_tests target)
    add_executable(${target} ${ARGN})
    target_link_libraries(${target} PRIVATE cpp_lab_test_main)
    cpp_lab_set_warnings(${target})
    doctest_discover_tests(${target})
endfunction()
