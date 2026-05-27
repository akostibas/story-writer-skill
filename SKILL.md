---
name: story-writer
description: Write quality user stories / issues. Probes intent before drafting, scopes large work into parent + parallel-implementable children, and grounds the story in existing project infrastructure. Use when the user asks to "write a story", "file an issue", "draft a ticket", or "scope this work".
---

# /story-writer

Turn a request like "we should add X" into a story that's actually ready to hand to an implementer (human or agent). The skill resists the temptation to start drafting before the problem is understood.

## Core principle

**A good story makes the problem legible and the success condition checkable.** Solution detail is secondary — if the problem is sharp, the solution often falls out. If the problem is fuzzy, no amount of acceptance-criteria polish will save it.

## Required section

Only one section is mandatory in every story:

- **Problem / motivation** — what hurts, who it hurts, and why now. No solution language.

Everything else (acceptance criteria, non-goals, risks, etc.) is recommended but not enforced. Match the rigor to the story's weight.

## Workflow

### 1. Detect output target

Stories land in different places per project. On first invocation in a repo:

1. Check the project's `CLAUDE.md` (and any nested `CLAUDE.md` files) for a `## Story Output` section or equivalent note.
2. If absent, look for signals: `docs/pm.yaml` (pm skill in use), `.github/` (GitHub Issues), `docs/stories/` or `docs/issues/` (markdown files).
3. If still ambiguous, **ask the user**:
   - GitHub Issues via `gh`
   - Markdown file in `docs/stories/` (or similar path they specify)
   - `docs/pm.yaml` entry (defer to the `pm` skill for the write)
4. **After the user answers, propose adding a short note to the project's `CLAUDE.md`** so future sessions skip this step. Example:
   ```markdown
   ## Story Output
   New stories are filed as GitHub Issues in <owner>/<repo>. Use the `story-writer` skill.
   ```

### 2. Detect probing depth

How aggressively to probe intent and investigate prior art is a per-project preference. Store it in **memory** (not CLAUDE.md — it's a working preference, not a project fact).

Memory slug: `story-writer-depth-<repo-name>`. Values: `light`, `medium`, `heavy`. Default: `medium`.

- **light** — 1–2 clarifying questions, then draft. Skip prior-art search and Gemini.
- **medium** (default) — confirm understanding with 2–3 questions, offer prior-art investigation and Gemini as opt-in.
- **heavy** — always investigate prior art, always offer Gemini, expect to iterate before drafting.

If the user expresses a preference mid-session ("be more thorough next time", "this is getting too long"), update the memory.

### 3. Probe intent

Before drafting, get clear on:

- **What problem is this solving?** Restate it back in your own words and check.
- **Who has the problem?** End user, operator, future maintainer, you?
- **What happens if we don't do it?** Helps distinguish must-do from nice-to-have.
- **Is the requested solution the right shape?** Gently challenge if there's a simpler or more orthogonal fix. Don't be annoying — one well-aimed alternative is fine, three is nagging.

Skip questions whose answers are obvious from the request.

### 4. Investigate (medium+ only)

Before drafting, do a quick sweep:

- **Existing issues**: `gh issue list --search "<keywords>" --state all --limit 20` to catch duplicates and prior attempts.
- **ADRs**: `ls docs/adr/ 2>/dev/null` and grep for related decisions. A story that contradicts an accepted ADR needs to acknowledge it.
- **Recent commits**: `git log --oneline -50 --grep="<keyword>"` for in-flight or recently-shipped related work.
- **Project infrastructure**: skim `README.md`, top-level config (`package.json`, `pyproject.toml`, `Makefile`, `bin/`), and any obvious utility directories. The story should name reusable pieces ("use the existing `X` helper") rather than implying greenfield work.

Report findings concisely before drafting — the user may redirect based on what surfaces.

### 5. Second opinion (optional, medium+)

If the problem is genuinely thorny or design-ambiguous, offer to consult `ask-gemini` (skip silently if the skill isn't available). Phrase as:

> "This has a few plausible shapes. Want me to bounce it off Gemini before we commit?"

Don't consult Gemini for routine stories — it's for "is this even the right framing" moments.

### 6. Scope check: one story or many?

After understanding the problem, decide:

- **One story** if it's a focused change with a single coherent acceptance criterion.
- **Parent + children** if any of these are true:
  - Can't list acceptance criteria in ≤7 bullets.
  - Touches >2 distinct subsystems / packages.
  - Has natural sequencing (X must land before Y).
  - Could be parallelized across multiple agents/people.

For parent + children:

1. Write the parent story with the **problem, done-when (epic-level), and a list of child stories**.
2. Each child is independently implementable: distinct `touches:` paths, own acceptance criteria, minimal coupling.
3. If `agent-mail` is available and the user wants parallel execution, mention that a leader agent can orchestrate via agent-mail — but don't launch anything from this skill. Briefing/dispatch is the `pm` skill's job (or the user's call).

### 7. Draft

Use this template. Drop sections that don't add value for the story at hand.

```markdown
# <Short imperative title>

## Problem
<2–4 sentences. What hurts, who it hurts, and why now. No solution.>

## Proposed approach  *(optional)*
<1 paragraph. What we think we'll do. Mark as proposed, not decided, unless the user has committed.>

## Acceptance criteria
- [ ] <Plain-language test case 1>
- [ ] <Plain-language test case 2>
...

## Non-goals
- <Explicitly out of scope>

## Touches
- <Files, packages, or subsystems the work will modify>

## Assumptions / risks / open questions
- <Things that are load-bearing but not certain>

## Related
- Issue #N, ADR-NNN, commit abc123 — <why relevant>
```

Parent stories add a `## Children` section listing child story titles (filled in with issue numbers after creation).

### 8. Write to target

Per step 1's detected target:

- **GitHub Issues**: `gh issue create --title ... --body ...` (HEREDOC for the body). Apply labels if the project uses them — check `gh label list`.
- **Markdown**: write to the agreed path with a date-prefixed or numbered filename.
- **pm.yaml**: hand off to the `pm` skill rather than writing directly.

For parent + children, file the parent first, then children referencing the parent's issue number / path.

### 9. Confirm and stop

Show the user the created links/paths. **Don't start implementing.** Story-writing is a planning act; implementation is a separate decision.

## Anti-patterns to avoid

- **Solution-first stories.** "Add a Redis cache" buries the problem ("requests to /foo are slow because we recompute X on every call"). Always lead with the problem.
- **Vague acceptance criteria.** "Works correctly" is not a test case. "Returns 200 with a JSON body containing `user_id` when called with a valid token" is.
- **Stories that assume the reader has been in your head.** If the next person to read this is a fresh agent or a teammate from a different team, will they have enough?
- **Padding small stories with ceremony.** A one-line bug fix doesn't need a non-goals section.
- **Treating "scope it as a parent" as a kindness.** Splitting work that doesn't actually decompose just creates coordination overhead. Only split when the children are genuinely independent.

## Skills this composes with

These are optional — the skill detects whether each is available and degrades gracefully. If the user wants any of them installed:

- **`ask-gemini`** — second-opinion consults during step 5.
  Repo: https://github.com/akostibas/ask-gemini-skill
- **`agent-mail`** — mentioned to the user when a parent story is suited to parallel agent execution.
  Repo: https://github.com/akostibas/agent-mail-skill
- **`pm`** — for projects that use a `docs/pm.yaml` editorial layer; defer writes there. This skill is currently repo-specific (Shannon-Assistant) rather than a standalone install.

## Files in this skill

- `SKILL.md` — this file.
- `bin/install` — symlinks the skill into `~/.claude/skills/story-writer`.
