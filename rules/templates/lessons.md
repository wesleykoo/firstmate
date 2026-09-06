# Lessons — earned rules from recurring corrections

Singleton. Review at session start. Append a rule the first time a mistake recurs;
write the rule so the same mistake can't happen again.

<!--
Entry format:

## <Imperative rule title — the lesson itself, stated as a rule> (YYYY-MM-DD)

**Context:** (or **Mistake:** / **Mistake (near-miss):**) What happened,
concretely — the command run, the file touched, the wrong assumption. Enough
specifics that a future session recognizes the same situation.

**Root cause (verified):** Optional — when the surface mistake and the
underlying cause differ, name the underlying cause.

**Rule:**
- Imperative, generalized bullets that prevent recurrence — written so the same
  mistake CAN'T happen again, not a description of what went wrong.
- Where applicable, include the proof that the rule bites: the mutation or
  experiment ("Proven: X turned the check RED while the old guard stayed GREEN").
- Point at the canonical doc/file when one exists ("See AGENTS.md ...",
  "See issues/done/NNN-*.md").

Conventions:
- A recurrence of an existing lesson is appended to THAT entry as a
  "**Recurred at <site> (YYYY-MM-DD).**" bullet carrying the refinement — not a
  new entry. Recurrence is the signal the rule needs sharpening.
- A rule later found wrong gets a "**CORRECTION — <what/why> (date).**" bullet
  on the same entry; never silently delete the earlier claim.
-->
