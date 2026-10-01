# GitHub setup

How the GitHub repository is configured: public, issues open, a single maintainer. Everything
that can be a file lives in the repository; the remaining settings are applied with
`Set-CppLabGitHubSettings` (GitHub CLI) or by hand, following the tables below.

## In the repository

| File | Purpose |
| ---- | ------- |
| `.github/workflows/ci.yml` | CI: `check` with clang and with MSVC, on every push to `main`, every pull request (any target branch), and manual runs (owner only) |
| `.github/rulesets/main.json` | Default-branch ruleset (below), applied by `Set-CppLabGitHubSettings` or imported by hand |
| `.github/dependabot.yml` | Weekly update pull requests for the GitHub Actions used by CI |
| `.github/ISSUE_TEMPLATE/` | Issue forms (bug report, question/suggestion); blank issues disabled |
| `.github/pull_request_template.md` | Checklist for the maintainer's own pull requests |
| `CONTRIBUTING.md`, `SECURITY.md` | Issues welcome, pull requests not accepted; private vulnerability reporting |

CI runs on `windows-latest` and installs the pinned CMake, Ninja and LLVM itself
(`Install-CppLabPortableToolchain`, SHA-256 verified), so formatting and lint results match a
local machine. MSVC comes from the runner's Visual Studio, whose version may differ from the
local one.

## First publication

1. Create an empty public repository on GitHub (no README, license or `.gitignore`: they exist
   here), or with the CLI: `gh repo create <name> --public --source . --remote origin`.
2. Push: `git push -u origin main`. CI starts.
3. Apply the settings: `Set-CppLabGitHubSettings -WhatIf`, then `Set-CppLabGitHubSettings`
   (needs `gh auth login`). Or follow the tables below by hand.
4. Check the first CI run (**Actions** tab) and the settings (**Settings** tab).

The ruleset requires the CI checks `check (clang)` and `check (msvc)`. They must have run at
least once to be selectable in the web UI; the JSON file references them by name, so it can be
applied before.

## Settings

All under the repository's **Settings** tab.

| Setting | Value | Where (web UI) | `Set-CppLabGitHubSettings` |
| ------- | ----- | -------------- | -------------------------- |
| Issues | On | General → Features | `gh repo edit --enable-issues` |
| Wiki, Projects, Discussions | Off | General → Features | `--enable-wiki=false`, `--enable-projects=false`, `--enable-discussions=false` |
| Merge commits | Off (the ruleset requires linear history) | General → Pull Requests | `--enable-merge-commit=false` |
| Squash merging, rebase merging | On | General → Pull Requests | `--enable-squash-merge`, `--enable-rebase-merge` |
| Automatically delete head branches | On | General → Pull Requests | `--delete-branch-on-merge` |
| Auto-merge | Off | General → Pull Requests | `--enable-auto-merge=false` |
| Description, topics | `cpp`, `cpp20`, `cmake`, `clang-tidy` | Repository home → About (gear icon) | `--description`, `--add-topic` |
| Default branch ruleset | `.github/rulesets/main.json` | Rules → Rulesets → New ruleset → **Import a ruleset** | `gh api repos/<repo>/rulesets` (POST, or PUT to update) |
| Workflow permissions | Read repository contents; Actions can't approve pull requests | Actions → General → Workflow permissions | `gh api … actions/permissions/workflow` |
| Approval for fork pull request workflows | Require approval for all external contributors | Actions → General → Fork pull request workflows | `gh api … actions/permissions/fork-pr-contributor-approval` |
| Private vulnerability reporting | On | Advanced Security (or Code security) | `gh api … private-vulnerability-reporting` |
| Dependabot alerts, security updates | On | Advanced Security | `gh api … vulnerability-alerts`, `… automated-security-fixes` |
| Secret scanning, push protection | On (free for public repositories) | Advanced Security | `--enable-secret-scanning`, `--enable-secret-scanning-push-protection` |

Settings menus move around on GitHub; if a path above doesn't match, search the setting's name
on the Settings page. If a `gh api` call fails (an endpoint changed), `Set-CppLabGitHubSettings`
warns and continues: set that item by hand.

## The ruleset

Applies to the default branch:

| Rule | Effect |
| ---- | ------ |
| Restrict deletions | The branch can't be deleted |
| Block force pushes | History can't be rewritten |
| Require linear history | No merge commits |
| Require status checks | `check (clang)` and `check (msvc)` must pass before merging a pull request |
| Bypass: repository admin, always | The maintainer can still push directly to `main` |

Pushing directly is allowed for convenience; CI still runs on every push, and a pull request to
oneself gives a full check before merging when wanted.

## Outside contributions

- Anyone can open issues (templates) and fork the repository; nobody else can push.
- Pull requests from others are closed (`CONTRIBUTING.md`). Their CI runs only after approval
  (setting above) and with a read-only token.
- GitHub may offer a setting restricting who can open pull requests (General → Pull Requests);
  check it when setting up. Temporary restrictions: Moderation options → **Interaction limits**.
- Manual CI runs (`workflow_dispatch`) need write access, and the workflow also checks that the
  person running it is the owner.
