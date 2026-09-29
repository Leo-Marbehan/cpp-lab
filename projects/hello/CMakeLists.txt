add_executable(hello main.cpp)
target_link_libraries(hello PRIVATE common)
cpp_lab_set_warnings(hello)
