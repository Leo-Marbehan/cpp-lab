# Checks run by the git hooks in .githooks/ (enabled with: git config core.hooksPath .githooks).
#
#   cmake -P cmake/pre_commit.cmake                        staged changes (pre-commit)
#   cmake -DMESSAGE_FILE=<file> -P cmake/pre_commit.cmake  commit message (commit-msg)
#
# Staged changes: C++ files formatted, no personal paths, no machine name, no word from the local list
# .git/info/forbidden-words (one word or phrase per line, '#' comments; never committed). Commit message: that list.
# Skip once with: git commit --no-verify

cmake_minimum_required(VERSION 3.28)

find_program(GIT git REQUIRED)

function(git_output out)
    execute_process(COMMAND "${GIT}" ${ARGN} OUTPUT_VARIABLE output RESULT_VARIABLE result OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "git ${ARGN} failed")
    endif()
    set(${out} "${output}" PARENT_SCOPE)
endfunction()

# Splits text into a CMake list of lines. ';', '[' and ']' would break list splitting, and a trailing '\' would escape
# the separator: they are replaced (backslashes by '/', which the path check also accepts).
function(split_lines out text)
    string(REPLACE ";" "<semicolon>" text "${text}")
    string(REPLACE "[" "<lbracket>" text "${text}")
    string(REPLACE "]" "<rbracket>" text "${text}")
    string(REPLACE "\\" "/" text "${text}")
    string(REPLACE "\r\n" "\n" text "${text}")
    string(REPLACE "\n" ";" lines "${text}")
    set(${out} "${lines}" PARENT_SCOPE)
endfunction()

git_output(forbidden_words_file rev-parse --git-path info/forbidden-words)
set(forbidden_words "")
if(EXISTS "${forbidden_words_file}")
    file(STRINGS "${forbidden_words_file}" word_lines)
    foreach(word IN LISTS word_lines)
        string(STRIP "${word}" word)
        if(word AND NOT word MATCHES "^#")
            string(TOLOWER "${word}" word)
            list(APPEND forbidden_words "${word}")
        endif()
    endforeach()
endif()

set(problems "")

# Appends to `problems` every forbidden word or personal detail found in `lines`.
function(check_lines lines where)
    string(TOLOWER "$ENV{COMPUTERNAME}" machine)
    foreach(line IN LISTS lines)
        string(TOLOWER "${line}" lower)
        if(lower MATCHES "[a-z]:/+users/+" OR lower MATCHES "^/[a-z]/users/|[^a-z]/[a-z]/users/")
            list(APPEND problems "${where}: personal path: ${line}")
        endif()
        if(machine AND lower MATCHES "${machine}")
            list(APPEND problems "${where}: machine name '${machine}': ${line}")
        endif()
        foreach(word IN LISTS forbidden_words)
            string(FIND "${lower}" "${word}" position)
            if(NOT position EQUAL -1)
                list(APPEND problems "${where}: forbidden word '${word}': ${line}")
            endif()
        endforeach()
    endforeach()
    set(problems "${problems}" PARENT_SCOPE)
endfunction()

if(DEFINED MESSAGE_FILE)
    file(READ "${MESSAGE_FILE}" message_text)
    split_lines(message_lines "${message_text}")
    list(FILTER message_lines EXCLUDE REGEX "^#")
    check_lines("${message_lines}" "commit message")
else()
    git_output(staged diff --cached --name-only --diff-filter=ACMR)
    split_lines(staged_files "${staged}")

    find_program(CLANG_FORMAT clang-format PATHS "$ENV{ProgramFiles}/LLVM/bin" REQUIRED)
    foreach(file IN LISTS staged_files)
        check_lines("${file}" "file name")
        if(file MATCHES "\\.(cpp|hpp)$")
            # Formats the staged version, not the working tree, so partially staged files are checked correctly.
            execute_process(
                COMMAND "${GIT}" show ":${file}"
                COMMAND "${CLANG_FORMAT}" --dry-run --Werror "--assume-filename=${file}"
                RESULTS_VARIABLE results
                OUTPUT_QUIET ERROR_QUIET
            )
            list(GET results 1 format_result)
            if(NOT format_result EQUAL 0)
                list(APPEND problems "${file}: not formatted (format on save, or: cmake --build --preset <p> --target format)")
            endif()
        endif()
    endforeach()

    git_output(diff_text diff --cached -U0 --diff-filter=ACMR --no-color)
    split_lines(diff_lines "${diff_text}")
    set(current_file "")
    set(added_lines "")
    foreach(line IN LISTS diff_lines)
        if(line MATCHES "^\\+\\+\\+ b/(.*)$")
            set(current_file "${CMAKE_MATCH_1}")
        elseif(line MATCHES "^\\+(.*)$")
            check_lines("${CMAKE_MATCH_1}" "${current_file}")
        endif()
    endforeach()
endif()

if(problems)
    list(LENGTH problems count)
    list(JOIN problems "\n  " report)
    string(REPLACE "<semicolon>" ";" report "${report}")
    string(REPLACE "<lbracket>" "[" report "${report}")
    string(REPLACE "<rbracket>" "]" report "${report}")
    message(FATAL_ERROR "Commit blocked, ${count} problem(s):\n  ${report}\n(Skip once with: git commit --no-verify)")
endif()
