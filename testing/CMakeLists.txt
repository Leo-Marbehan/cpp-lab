add_library(cpp_lab_test_main main.cpp)
target_link_libraries(cpp_lab_test_main PUBLIC doctest::doctest)
cpp_lab_set_warnings(cpp_lab_test_main)
