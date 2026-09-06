---
name: create-handoff
description: >
  Generate a handoff document that captures the current session's progress so a fresh agent, chat, or workflow can pick up exactly where you left off. Use this skill whenever the user says "handoff", "hand off", "create a handoff", "save progress for next session", "pass the baton", "context dump", "wrap up for handover", "save state", or any variation of wanting to preserve the current session's context for continuation later. Also trigger when the user says things like "I'm running out of context", "let's save where we are", "prepare for a fresh session", or "document what we've done so far". Even if the user just says "handoff" with no other context, use this skill.
---

# Create Handoff

You're creating a handoff document — a structured briefing that lets a completely fresh agent (with zero prior context) pick up this task and continue efficiently. Think of it as writing a memo to a colleague who's taking over your shift.

## Why this matters

The next agent will have no memory of this session. Every dead end you hit, every decision you made, every file you touched — if it's not in the handoff, it's lost. A good handoff saves the next session from repeating mistakes and gets it productive immediately.

## Step 1: Review the session

Go through the full conversation and identify:

- **The goal**: What was the user originally trying to accomplish?
- **Actions taken**: What did you actually do? (commands run, files created/edited, tools used)
- **Outcomes**: For each action, did it work or not? If not, why?
- **Current state**: Where do things stand right now?
- **Remaining work**: What's left to do?

Be honest about failures. The whole point is to prevent the next agent from walking into the same walls.

## Step 2: Generate the folder and filename

Use bash to get the current local time and create the handoff folder:

```bash
TIMESTAMP=$(date +"%y-%m-%d_%H:%M")
HANDOFF_NAME="HANDOFF_${TIMESTAMP}"
mkdir -p "handoff/${HANDOFF_NAME}"
```

All handoffs live under **`handoff/` at the project root**. The `mkdir -p` creates the top-level folder on first use (idempotent — safe to run even if it already exists) and the per-session subfolder in one call. Do NOT save handoffs to `output/` — that directory is reserved for pipeline artifacts (extractions, KB builds, etc.).

The main handoff document goes inside the per-session subfolder with the same name as the folder: `HANDOFF_{YY-MM-DD}_{HH:MM}.md`.

For example:
```
handoff/
└── HANDOFF_26-03-05_14:32/
    └── HANDOFF_26-03-05_14:32.md   ← the main handoff (always present)
```

## Step 3: Write the handoff document

Use the template below as a starting point. Adapt it to what's relevant — if a section doesn't apply (e.g., nothing failed), keep it brief rather than padding it out. The goal is clarity and usefulness, not length.

```markdown
# Handoff: [One-line description of the task]

**Date**: [YYYY-MM-DD HH:MM]
**Status**: [e.g., "In Progress — 3 of 5 steps complete" or "Blocked — waiting on API key"]

---

## Goal

[2-3 sentences max. What is the user trying to accomplish? Include enough context that someone unfamiliar with the project understands the objective.]

## What Was Tried

[Chronological list of significant actions. For each, note the outcome. Focus on actions that matter for continuation — skip trivial things like "read the file" unless the reading itself revealed something important.]

- **[Action]**: [Outcome — worked / failed / partial]. [Brief detail if needed.]
- **[Action]**: [Outcome]. [Detail.]

## What Worked

[Key successes and decisions worth preserving. These are things the next agent should keep, build on, or not undo.]

- [Success/decision and why it matters]

## What Didn't Work

[Dead ends and failures. For each, explain *why* it failed — this is the most valuable part. The next agent needs to know not just "X didn't work" but "X didn't work because Y, so don't try Z either."]

- **[What was tried]**: Failed because [reason]. [Implication for next steps.]

## Key Files & Locations

[Every file that was created, modified, or is relevant to continuing the work. Use absolute paths.]

| File | Role | Notes |
|------|------|-------|
| `/path/to/file` | [What it is] | [Any relevant detail] |

## Next Steps

[Concrete, actionable items. Write these as if you're assigning tasks — specific enough that the next agent can start immediately without asking clarifying questions.]

1. [Specific next action]
2. [Specific next action]

## Context & Notes

[Anything that doesn't fit above but would help the next agent: environment quirks, user preferences expressed during the session, decisions that need explanation, dependencies, gotchas.]
```

## Step 4: Create supplementary files (if warranted)

Look at the session and ask yourself: would the next agent benefit from any standalone reference material beyond the main handoff? This might include:

- **Diagnostic scripts** — if the session involved debugging and you can provide a ready-to-run checklist or script
- **Research summaries** — if the session involved evaluating options, a comparison table or deep-dive doc
- **Configuration snapshots** — if environment setup was complex, a captured config or setup guide
- **Code snippets** — if partially-written code was central to the work, save it as a separate file

Save any supplementary files into the same `handoff/HANDOFF_{YY-MM-DD}_{HH:MM}/` folder alongside the main handoff document. Use descriptive filenames (e.g., `DIAGNOSTIC_SCRIPT.md`, `STATE_MANAGEMENT_RESEARCH.md`, `ENV_SETUP.md`).

The main handoff doc's **Key Files & Locations** table should reference these bundled files so the next agent knows they exist and what they're for.

Don't force it — if the session was straightforward and one document covers everything, the folder will just contain the main handoff file and that's fine.

Example of a richer handoff folder:
```
HANDOFF_26-03-05_14:32/
├── HANDOFF_26-03-05_14:32.md           ← main handoff (always present)
├── DIAGNOSTIC_SCRIPT.md                 ← debugging checklist
└── REDIS_CACHE_INVESTIGATION.md         ← research notes on the cache issue
```

## Step 5: Save, commit, and share

**Save** all files into the per-session subfolder under `handoff/` (created in Step 2). Use the `Write` tool to create them.

**Commit** the handoff to git so it persists in history rather than living only on disk. The user has opted into auto-commit for handoffs via this skill — this is one of the few skill-authorized exceptions to the project's default "never commit without explicit instruction" rule.

Stage ONLY the new handoff folder, not other uncommitted changes in the working tree. A handoff is often written mid-session with unrelated work in flight, and sweeping everything would be surprising. The commit message subject derives from the handoff doc's title line (the first line `# Handoff: <description>`):

```bash
# Stage only the new handoff folder
git add "handoff/${HANDOFF_NAME}/"

# Derive the commit subject from the handoff title (strip leading "# ")
SUBJECT=$(head -1 "handoff/${HANDOFF_NAME}/${HANDOFF_NAME}.md" | sed 's/^# *//')

git commit -m "$(cat <<EOF
${SUBJECT}

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Skip the commit** when:
- Not in a git repo (check with `git rev-parse --show-toplevel` before staging)
- The user has explicitly disabled commits this session
- The handoff folder has no new files staged (`git diff --cached --quiet` returns 0)

**On commit failure** (pre-commit hook rejects, signing fails, etc.): report the error verbatim to the user and stop — do NOT try to auto-recover (don't `--no-verify`, don't amend, don't reset). The handoff files are still safely on disk; the user finishes the commit manually after diagnosing.

**Share** a link to the folder's main handoff file with the user, including the commit hash from the auto-commit step (or noting if commit was skipped/failed). Mention any supplementary files you included and what they're for.

## Tips for writing a great handoff

- **Be specific over general.** "The API returns 403" beats "there were auth issues."
- **Include error messages.** Copy the actual errors — they're gold for debugging.
- **Note environment details.** Python version, installed packages, OS quirks — anything the next agent might need.
- **Link, don't describe.** If there's a relevant URL, config file, or doc, link to it rather than summarizing.
- **Write for scanning.** The next agent will likely skim first, then deep-read relevant sections. Use clear headers and keep paragraphs short.
