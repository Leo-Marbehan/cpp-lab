# 0013. Check staged changes with git hooks written in CMake

- **Status:** Accepted
- **Date:** 2026-10-01

## Context

The repository is public. Unformatted code, personal paths (`<drive>:\Users\<name>\…`), the machine name, or
names of projects that don't exist yet must not reach a commit. The check workflows catch
formatting but take more than a minute and run after the fact. Git hooks run at commit time but
aren't cloned: they must live in a tracked folder enabled per clone (`core.hooksPath`). Git for
Windows runs hooks with its bundled `sh`.

## Decision

- `.githooks/pre-commit` and `.githooks/commit-msg`: two-line `sh` stubs calling
  `cmake -P cmake/pre_commit.cmake` (logic in CMake, per ADR 0008).
- `pre-commit` checks only the **staged** changes:
  - clang-format on staged `.cpp`/`.hpp` files, using the staged version (`git show :file`), so
    partially staged files are checked correctly;
  - added lines and file names: no `<drive>:\Users\…` or `/<drive>/users/…` path, no machine name
    (`COMPUTERNAME`), no word from `.git/info/forbidden-words`.
- `commit-msg` checks the message against the same word list.
- `.git/info/forbidden-words` is local (inside `.git/`, never committed or pushed): one word or
  phrase per line, `#` comments, case-insensitive.
- Enabled per clone with `Enable-CppLabGitHooks` (`git config core.hooksPath .githooks`).
- clang-tidy and tests are not run in the hooks (more than a minute); the check workflows and CI
  cover them.

## Consequences

- A commit takes well under a second more.
- `git commit --no-verify` skips the hooks when a finding is intended (e.g. documenting a path
  pattern on purpose).
- Each new clone must run `Enable-CppLabGitHooks` once (`docs/setup.md`), and recreate its word
  list if wanted.
- Reported lines show `\` as `/` (backslashes are normalized for the checks).
