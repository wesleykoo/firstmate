# Rules: Files & artifacts (loop-independent taxonomy)

## Files & artifacts

**Cross-project deliverables** (reusable agent assets):
Reusable subagent and skill definitions live in agent-specific config directories — see your agent's per-agent guide for exact paths:

- Claude Code → `CLAUDE.md` (uses `.claude/agents/agt-*`, `.claude/skills/<name>/SKILL.md`)
- Cursor → `.cursor/rules/*.mdc`
- Codex → reusable skills live in `.agents/skills/<name>/SKILL.md`;

**Project operating rules** (stable contracts in force):

- `tasks/adr/NNNN-*.md` — decision records; supersede instead of edit
- `tasks/lessons.md` (singleton) — earned rules from recurring corrections. Entry format: `## <imperative rule title> (YYYY-MM-DD)` + **Context/Mistake** → optional **Root cause** → **Rule** bullets (with the mutation/experiment proof that the rule bites, where applicable). A recurrence appends a **Recurred at …** bullet to the existing entry; a wrong rule gets a **CORRECTION** bullet — never silently deleted. See `rules/templates/lessons.md`.
- `tasks/deferred.md` (singleton) — cross-initiative "do X when Y" parking lot. **Read at session start.** Entries group by initiative; every entry carries an explicit trigger (**Fix when / Build when / Revisit trigger:**) — an entry without a Y is a wish, not a deferral. Roadmap sections may track status inline (✅ shipped / ⚠️ partial / ⏸️ descoped). When an entry ships through the loop, mirror as `issues/NNN-deferred-*.md`; delete the deferred entry in the closing commit. See `rules/templates/deferred.md`.

Both singletons are seeded at project init from `rules/templates/` — if either is missing, create it from its template rather than inventing a new structure.

**Knowledge in flight** (unstable, exploring):

- `research/rsch_*.md` — investigation notes
- `scratchpad/spad-*.md` — fast/dirty working notes

**In-session tracking:**

- `TaskCreate` tool — in-session ephemeral tracking (no file)

Paused mid-work? Append a `## Pause Notes` section (date + state + blocker + resume criteria) to the relevant file before context-switching.
