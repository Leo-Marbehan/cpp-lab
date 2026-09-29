option(CPP_LAB_ENABLE_ASAN "Build with AddressSanitizer (MSVC only)" OFF)

if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    add_compile_options(/permissive- /utf-8 /Zc:__cplusplus /Zc:preprocessor)
endif()

if(CPP_LAB_ENABLE_ASAN)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message(FATAL_ERROR "CPP_LAB_ENABLE_ASAN is only set up for MSVC")
    endif()

    add_compile_options(/fsanitize=address)
    # Both are documented as incompatible with /fsanitize=address.
    string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE "/INCREMENTAL" "/INCREMENTAL:NO" CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")

    # The ASan runtime DLL is only on PATH inside the developer environment.
    cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH compiler_dir)
    file(COPY "${compiler_dir}/clang_rt.asan_dynamic-x86_64.dll" DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endif()

function(cpp_lab_set_warnings target)
    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options(${target} PRIVATE /W4)
    else()
        target_compile_options(${target} PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
            -Wconversion
            -Wsign-conversion
            -Wold-style-cast
            -Wnon-virtual-dtor
            -Woverloaded-virtual
            -Wimplicit-fallthrough
        )
    endif()
endfunction()
