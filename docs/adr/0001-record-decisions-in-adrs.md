# 0001. Record decisions in ADRs

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

Much of this repository is written with AI agents, which tend to put decisions, reasons and
history ("previously this used …") into code comments. That makes the code noisy, and the
comments go stale as the code changes. The reasons are still worth keeping somewhere.

Considered: one document per feature (drifts as the feature evolves), commit messages only
(hard to find later), Architecture Decision Records (Michael Nygard's format).

## Decision

- Decisions with lasting impact go in `docs/adr/NNNN-title.md`, one decision per file, numbered
  in order, using `0000-template.md` (Status, Date, Context, Decision, Consequences).
- ADRs are not rewritten. A changed decision gets a new ADR; the old one's status becomes
  `Superseded by NNNN`.
- Code comments only explain why the *current* code is non-obvious. The reason for a change goes
  in the commit message. Old code lives in git history.

## Consequences

- Code stays free of narration; `AGENTS.md` states the rule for agents.
- Every tooling, build or dependency change needs a short ADR.
- An ADR describes the situation at its date; the current state is the code plus the latest
  non-superseded ADRs.
