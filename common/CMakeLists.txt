add_library(common
    src/math.cpp
)

target_include_directories(common PUBLIC include)
cpp_lab_set_warnings(common)
