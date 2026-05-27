# story-writer

A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill for writing quality user stories / issues.

Most "write me a story" interactions jump straight to acceptance criteria for whatever the user happened to say first. This skill resists that — it probes intent, sweeps for prior art, and only drafts once the problem is sharp. For larger work it produces a parent story with independently-implementable children.

## What it does

1. **Detects where stories land** per-project (GitHub Issues, markdown files, or a `pm.yaml`) and remembers the choice in the project's `CLAUDE.md`.
2. **Probes intent** at a configurable depth (light / medium / heavy, stored in memory per repo).
3. **Investigates prior art** — existing issues, ADRs, recent commits, and project infrastructure — so drafts reference reusable pieces instead of implying greenfield work.
4. **Optionally consults Gemini** via the `ask-gemini` skill when a problem is genuinely ambiguous.
5. **Splits oversized stories** into a parent + independently-implementable children, with a nod toward `agent-mail` orchestration when relevant.
6. **Drafts and files** the story in the detected target, then stops. Implementation is a separate decision.

Only the **Problem / motivation** section is required in every story. Everything else (acceptance criteria, non-goals, risks, touches) is recommended but dropped when it wouldn't add value.

See [`SKILL.md`](SKILL.md) for the full workflow.

## Install

```bash
git clone https://github.com/akostibas/story-writer-skill.git
cd story-writer-skill
bin/install
```

`bin/install` symlinks the repo into `~/.claude/skills/story-writer/`. It's idempotent and won't clobber an existing non-symlink without `--force`. Restart Claude Code after installing.

## Optional companion skills

The skill detects whether each of these is available and degrades gracefully:

- [`ask-gemini`](https://github.com/akostibas/ask-gemini-skill) — second-opinion consults on thorny problems.
- [`agent-mail`](https://github.com/akostibas/agent-mail-skill) — cross-session messaging for orchestrating parallel agents on a parent story's children.

## Usage

Invoke directly:

```
/story-writer we should let users export their data as CSV
```

Or just describe what you want and let the skill engage when it matches.

## License

MIT
