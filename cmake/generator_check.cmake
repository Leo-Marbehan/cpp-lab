# Generates a throwaway project from the templates and builds it like a real one (warnings, clang-tidy, tests,
# formatting), so templates that drift from the conventions fail the check workflows.

set(generated_projects_dir "${CMAKE_BINARY_DIR}/generated/projects")
file(REMOVE_RECURSE "${generated_projects_dir}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -DNAME=generator_example -DGENERATOR_SELF_TEST=ON "-DPROJECTS_DIR=${generated_projects_dir}"
            -P "${CMAKE_SOURCE_DIR}/cmake/new_project.cmake"
    OUTPUT_QUIET
    COMMAND_ERROR_IS_FATAL ANY
)

file(GLOB_RECURSE generator_templates "${CMAKE_SOURCE_DIR}/templates/*")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/cmake/new_project.cmake" ${generator_templates}
)

add_subdirectory("${generated_projects_dir}/generator_example" "${CMAKE_BINARY_DIR}/generated/build/generator_example")

file(GLOB_RECURSE generated_sources "${generated_projects_dir}/*.cpp" "${generated_projects_dir}/*.hpp")
add_test(NAME format_check_generated COMMAND "${CPP_LAB_CLANG_FORMAT}" --dry-run --Werror ${generated_sources})
