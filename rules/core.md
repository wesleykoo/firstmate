# Rules: Core principles & task discipline

## Domain delegation

Domain-specific "always delegate task X to agent Y" routing rules live in each
agent's own config layer, not here (Claude Code: `CLAUDE.md` +
`.claude/agents/agt-*.md`). When a task matches a domain agent's description,
delegate to it instead of doing the work inline.

## Commit cadence (all session types)

- Cowork / HITL sessions: atomic commits at logical work-unit boundaries, tests passing. At minimum, commit before session end.
- Don't end any session with uncommitted work.
- Ralph loop sessions: see `rules/ralph.md` for the loop's own cadence.

## In-task principles

Inside any task — single-shot or one Ralph iteration — apply these principles:

### 1. Plan Node Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decision)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution

### 3. Self-Improvement Loop

- After ANY correction from the user: update `{project folder}/tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everthing I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug/error Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing test - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root cuases. No temporary fixes. Senior developer standards
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
