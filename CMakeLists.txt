cmake_minimum_required(VERSION 3.28)

project(cpp-lab LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(common)

file(GLOB project_cmakelists CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/projects/*/CMakeLists.txt")
foreach(project_cmakelist IN LISTS project_cmakelists)
    cmake_path(GET project_cmakelist PARENT_PATH project_dir)
    add_subdirectory("${project_dir}")
endforeach()

file(GLOB exercise_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/exercises/*.cpp")
foreach(exercise_source IN LISTS exercise_sources)
    cmake_path(GET exercise_source STEM exercise_name)
    add_executable(ex_${exercise_name} "${exercise_source}")
    target_link_libraries(ex_${exercise_name} PRIVATE common)
endforeach()
