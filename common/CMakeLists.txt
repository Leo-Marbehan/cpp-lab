add_library(common
    src/math.cpp
)

target_include_directories(common PUBLIC include)
cpp_lab_set_warnings(common)

cpp_lab_add_tests(common_tests tests/test_math.cpp)
target_link_libraries(common_tests PRIVATE common)
