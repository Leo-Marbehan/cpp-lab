find_program(CPP_LAB_CLANG_FORMAT clang-format REQUIRED)

file(GLOB_RECURSE cpp_lab_format_sources CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/common/*.cpp" "${CMAKE_SOURCE_DIR}/common/*.hpp"
    "${CMAKE_SOURCE_DIR}/testing/*.cpp" "${CMAKE_SOURCE_DIR}/testing/*.hpp"
    "${CMAKE_SOURCE_DIR}/projects/*.cpp" "${CMAKE_SOURCE_DIR}/projects/*.hpp"
    "${CMAKE_SOURCE_DIR}/playground/*.cpp" "${CMAKE_SOURCE_DIR}/playground/*.hpp"
)

add_custom_target(format
    COMMAND "${CPP_LAB_CLANG_FORMAT}" -i ${cpp_lab_format_sources}
    COMMENT "Formatting C++ sources"
    VERBATIM
)

add_custom_target(format-check
    COMMAND "${CPP_LAB_CLANG_FORMAT}" --dry-run --Werror ${cpp_lab_format_sources}
    COMMENT "Checking C++ formatting"
    VERBATIM
)

add_test(NAME format_check COMMAND "${CPP_LAB_CLANG_FORMAT}" --dry-run --Werror ${cpp_lab_format_sources})
