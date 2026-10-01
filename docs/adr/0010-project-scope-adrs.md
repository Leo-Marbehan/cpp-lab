# 0010. Allow project-scope ADRs

- **Status:** Accepted (extends [0001](0001-record-decisions-in-adrs.md))
- **Date:** 2026-10-01

## Context

ADR 0001 puts decisions in `docs/adr/`. Projects in `projects/` will make decisions that only
matter inside them (algorithm variants, data representation, how results are validated). Mixing
those with repository-wide decisions about tooling and structure would make both harder to find.

## Decision

- Decisions that only concern one project go in `projects/<name>/docs/adr/NNNN-title.md`,
  numbered per project from 0001.
- Same format and rules as ADR 0001, using the repository template `docs/adr/0000-template.md`
  (not copied into projects).
- The folder is created with the project's first decision; the generator doesn't create it.
- Boundary: a decision about one project's code, design or algorithms is a project ADR. A
  decision about the build, tooling, `common/`, the conventions, or several projects is a
  repository ADR. Rule of thumb: if the ADR would mean nothing once the project is deleted, it is
  a project ADR.

## Consequences

- Each project carries its own decision history; deleting a project deletes its decisions.
- Two numbering sequences coexist: `docs/adr/0003` and `projects/x/docs/adr/0003` are unrelated.
  Links between levels use relative paths.
- ADR 0001 stays valid; this ADR only adds the project level.
