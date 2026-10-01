cmake_minimum_required(VERSION 3.28)

project(cpp-lab LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/compiler_flags.cmake")

enable_testing()
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/doctest.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/format.cmake")
add_subdirectory(testing)

add_subdirectory(common)

file(GLOB project_cmakelists CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/projects/*/CMakeLists.txt")
foreach(project_cmakelist IN LISTS project_cmakelists)
    cmake_path(GET project_cmakelist PARENT_PATH project_dir)
    add_subdirectory("${project_dir}")
endforeach()

set(playground_dir "${CMAKE_CURRENT_SOURCE_DIR}/playground")
file(GLOB_RECURSE playground_sources CONFIGURE_DEPENDS "${playground_dir}/*.cpp")
foreach(playground_source IN LISTS playground_sources)
    cmake_path(RELATIVE_PATH playground_source BASE_DIRECTORY "${playground_dir}" OUTPUT_VARIABLE relative_source)
    cmake_path(REMOVE_EXTENSION relative_source LAST_ONLY OUTPUT_VARIABLE relative_name)
    string(REPLACE "/" "_" playground_target "pg_${relative_name}")
    add_executable(${playground_target} "${playground_source}")
    target_link_libraries(${playground_target} PRIVATE common)
    cpp_lab_set_warnings(${playground_target})
endforeach()
