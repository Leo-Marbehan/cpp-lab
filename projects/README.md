# Projects

Every folder here with a `CMakeLists.txt` is added to the build automatically.

Create a project from the templates in `templates/project/` (don't copy an existing one):

```powershell
cmake -DNAME=my_project -P cmake/new_project.cmake
```

The name must be `snake_case`. It becomes the folder, the namespace and the targets `my_project`
(executable), `my_project_lib` (library) and `my_project_tests` (tests). Configure, or build once,
to pick it up.
