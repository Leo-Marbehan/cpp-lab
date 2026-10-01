# VSCode cheat sheet

Default Windows shortcuts with the **command ID** behind each one. Shortcuts can be changed; the
command ID stays the same. To find or rebind a command: **Ctrl+K Ctrl+S**
(`workbench.action.openGlobalKeybindings`) and search for its ID. Every command can also be run
from the Command Palette: **Ctrl+Shift+P** (`workbench.action.showCommands`).

Extensions used: CMake Tools (`ms-vscode.cmake-tools`), clangd
(`llvm-vs-code-extensions.vscode-clangd`), C/C++ (`ms-vscode.cpptools`, debugger only). VSCode
offers to install them when the folder is opened (`.vscode/extensions.json`).

## Build, run, debug (CMake Tools)

The status bar shows the active configure preset, build target and launch target; clicking one
changes it.

| Action                                   | Shortcut           | Command ID                    |
| ---------------------------------------- | ------------------ | ----------------------------- |
| Select configure preset (`msvc-debug`, …) |                   | `cmake.selectConfigurePreset` |
| Configure                                |                    | `cmake.configure`             |
| Delete cache and reconfigure             |                    | `cmake.cleanConfigure`        |
| Build (default target: everything)       | **F7**             | `cmake.build`                 |
| Build one target                         | **Shift+F7**       | `cmake.buildWithTarget`       |
| Set the default build target             |                    | `cmake.setDefaultTarget`      |
| Clean rebuild                            |                    | `cmake.cleanRebuild`          |
| Set the launch/debug target (`pg_hello`, …) |                 | `cmake.selectLaunchTarget`    |
| Run the launch target, no debugger       | **Ctrl+Shift+F5**  | `cmake.launchTarget`          |
| Debug the launch target                  | **Shift+F5**       | `cmake.debugTarget`           |
| Debug with `.vscode/launch.json`         | **F5**             | `workbench.action.debug.start` |
| Run with `.vscode/launch.json`, no debugger | **Ctrl+F5**     | `workbench.action.debug.run`  |

`.vscode/launch.json` launches the target selected in CMake Tools, from the repository root.
Build output and errors: **Output** panel, channel *CMake/Build*.

## Editing (clangd)

| Action                                   | Shortcut           | Command ID                         |
| ---------------------------------------- | ------------------ | ---------------------------------- |
| Format document (also done on save)      | **Shift+Alt+F**    | `editor.action.formatDocument`     |
| Switch between header and source         | **Alt+O**          | `clangd.switchheadersource`        |
| Go to definition                         | **F12**            | `editor.action.revealDefinition`   |
| Peek definition                          | **Alt+F12**        | `editor.action.peekDefinition`     |
| Find all references                      | **Shift+F12**      | `editor.action.goToReferences`     |
| Rename symbol (everywhere)               | **F2**             | `editor.action.rename`             |
| Quick fix (e.g. apply a clang-tidy fix)  | **Ctrl+.**         | `editor.action.quickFix`           |
| Show the Problems panel                  | **Ctrl+Shift+M**   | `workbench.actions.view.problems`  |
| Go to the next problem                   | **F8**             | `editor.action.marker.nextInFiles` |
| Show the type hierarchy                  | **Shift+Alt+T**    | `clangd.typeHierarchy`             |
| Toggle inlay hints (parameter names, deduced types) |         | `clangd.inlayHints.toggle`         |

Format on save uses `.clang-format`. clang-tidy findings appear as you type (squiggles and the
Problems panel), with the check name; see `docs/conventions.md` for how to silence one.

## Tests

| Action                                   | Shortcut           | Command ID                    |
| ---------------------------------------- | ------------------ | ----------------------------- |
| Open the Testing panel (flask icon)      |                    | `workbench.view.testing.focus` |
| Run all tests                            | **Ctrl+; A**       | `testing.runAll`              |
| Run the test at the cursor               | **Ctrl+; C**       | `testing.runAtCursor`         |
| Re-run the last run                      | **Ctrl+; L**       | `testing.reRunLastRun`        |
| Run all tests through CTest              |                    | `cmake.ctest`                 |

Every `TEST_CASE` is listed separately, plus `format_check` (fails on unformatted files).

## When something is wrong

| Symptom                                  | Fix                                                        |
| ---------------------------------------- | ---------------------------------------------------------- |
| clangd shows errors that the build doesn't | `clangd.restart`; check that `compile_commands.json` exists at the root (created by a configure) |
| Still wrong                              | From a terminal: `clangd --check=<file>` shows how clangd reads the file |
| Includes not found after adding files    | `cmake.configure`                                          |
| Strange build state                      | `cmake.cleanConfigure`, or delete `build/<preset>/`        |
| A new file isn't a target yet            | Build once (**F7**): new files are picked up automatically |
