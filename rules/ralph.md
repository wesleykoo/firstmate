# Rules: Ralph loop / issue-driven delivery (opt-in)

## Workflow

For new multi-session work, use the issue-driven loop:

> **The Ralph loop is CONSUMED from the harness, not vendored here.** fwddcf is a
> consumer of `~/Development/ralph-harness` (clone of `wesleykoo/ralph-harness`,
> pinned to a release tag). Run any conductor through the project shim — it exports
> the consumer env (`HARNESS_HOME`, `RALPH_PROJECT_DIR`, `PYTHONPATH`) for you:
>
> ```bash
> ./ralph.sh afk-tmux.sh 1          # drain issues/ — one loop iteration
> ./ralph.sh afk-tmux-accept.sh N   # PRD acceptance convergence (once acceptance_tests/ exist)
> ```
>
> The backlog lives in `issues/` (schema = `issues/_contract.yaml`, the generic copy
> from the harness). There is **no in-tree `ralph-tmux/` or `acceptance/`** — those
> resolve from the harness clone. fwddcf ships no domain detector / promoted-check
> registry yet, so `RALPH_GAP_DETECTOR` / `RALPH_PROMOTED_REGISTRY` stay unset (the
> engine defaults to an empty registry).

`grill-me` → `write-a-prd` → `prd-to-issues` (work-package slices) + `prd-to-acceptance` (acceptance `@check` tests) → Ralph loop (`./ralph.sh afk-tmux.sh 1` for one iteration, `./ralph.sh afk-tmux.sh N` for unattended). See `$HARNESS_HOME/ralph-tmux/prompt.md` for selection rules and `.claude/skills/tdd/SKILL.md` for the per-iteration workflow. (`prd-to-acceptance` also takes a `scratchpad/spad-*`/`research/rsch_*` doc as a mini-PRD, and has a `--single` mode for one-spotted-defect regression guards — it is the sole acceptance author; the former `adhoc-acceptance` and `mini-prd-to-issues-acceptance` skills folded into it.)

For PRD acceptance convergence (drain → re-evaluate against `acceptance_tests/` until GREEN), use `./ralph.sh afk-tmux-accept.sh N` — alternates `afk-tmux.sh` (drain `issues/`, the real backlog by default — both halves default to `issues/` now; `RALPH_SMOKE=1` selects the disposable `issues-tmux` mock for the hello-world drill) and `accept-tmux.sh` (run the suite; a RED `@check` files its own self-describing critique INLINE via `acceptance.pytest_adapter`, marker-native — no manifest/story_filer) up to N rounds. A gated read-only investigator (Read + the check's declared CLIs only — not an LLM call) appends an advisory `## Investigation` section on a repeat failure (ADR-0022 D7); the old tmux `RALPH_ENRICH` pass is gone. `accept-tmux.sh` also runs standalone between manual AFK rounds (point it at a suite with `RALPH_ACCEPTANCE_SUITE=acceptance_tests/delivery/<slug>`). Scope a subset two ways (separate identities, ADR-0022 D9): `RALPH_CHECK_IDS=us3-foo,us8-bar` scopes the eval by stable string check id (the drain then narrows naturally to the critiques those checks file), forwarded as `run_acceptance.py --check-ids` → `pytest -m check -k <ids>`; `RALPH_STORY_IDS=N,M` scopes the drain only, restricting to issues whose frontmatter `user_stories:` intersects the set. Typical use: convergence-loop only the checks you just added via `prd-to-acceptance --single` plus their matching critique-issues.

**Two acceptance gates — do NOT conflate them.** Everything above (`afk-tmux-accept.sh` / `accept-tmux.sh` / the `acceptance-run` skill) is **product-acceptance**: *"do the suite's `@check`s pass?"* → GREEN / PRD-DONE. There is a **separate** *test-quality* gate, **teeth-evaluation**: *"do the `@check`s actually have teeth — would they go RED if the thing they verify broke?"* Run it with `./ralph.sh eval-acceptance-loop.sh <slug> [N]` (the teeth analogue of `afk-tmux-accept.sh`: alternates drain ⇄ an on-demand LLM evaluator per check against a 5-question rubric — can-it-fail / claim↔assert / real-artifact / right-outcome / independent-oracle — filing WEAK critiques until **eval-green**; exit `0` eval-green, `1` tripwire/architectural-review, `3` budget-exhausted-not-green, `4` drain-failed). The evaluator is the harness's `evaluate-acceptance` skill (agent `agt-acceptance-evaluator`, script `evaluate_one.py`), **live-read from the clone** — the loop needs nothing copied into the consumer (the interactive `/evaluate-acceptance` skill is NOT surfaced here; use the loop). **When the user says "evaluate acceptance" / "does the suite have teeth", they mean THIS loop — not the product-acceptance run.** Standalone single eval pass: `RALPH_ACCEPTANCE_SUITE=acceptance_tests/delivery/<slug> ./ralph.sh eval-acceptance-loop.sh <slug> 1`.

## Commit cadence (Ralph loop)

- Ralph loop: per `$HARNESS_HOME/ralph-tmux/prompt.md` (always commit, even on red — the loop runs on a feature branch where iterations are journaled in git log)

## Delivery work files

- `prds/{wip,queued,done,blocked}/` — PRD lifecycle home (NOT `issues/` — that's for issues). `write-a-prd` drafts to `prds/wip/<slug>.md` (`ready: false`); promote when complete to `prds/queued/NNN-<slug>.md` (`ready: true`, optional `depends_on:`) — that's the gate that admits a PRD to `prd-to-issues`/`prd-to-acceptance` and the PRD chain. Always use a descriptive slug; never a bare `prd.md` (generic names collide on iCloud and don't scale to multiple in-flight PRDs). A queued PRD without `ready: true` is a WIP draft and is skipped by the chain (`acceptance.chain.prd_is_ready`, fail-closed), so a half-authored PRD is never looped. See `prds/README.md`.
- `issues/NNN-*.md` — vertical-slice issue files (Ralph loop input)
- `issues/done/NNN-*.md` — closed issue history
- `prds/done/NNN-*.md` — shipped PRDs (the chain archives `queued→done` at TRANSITION; or `git mv` manually once all child issues are closed). `parent_prd:` refs in closed-issue frontmatter point at the PRD's path and go stale on the move — acceptable (the issues are archival by then).
- `issues/_contract.yaml` — single source of truth for issue frontmatter schema. Adding/removing issue frontmatter fields is a YAML edit here; `$HARNESS_HOME/ralph-tmux/validate_issues.py` reads from it directly, so writers (`scaffold_critique_issue.py`, `triage_e2e_report.py`, `bootstrap.sh` heredoc) and the validator stay in lockstep. See the "HOW TO CHANGE THIS CONTRACT" header at the top of the file for the six change-type recipes (additive types 1-3 are free; restrictive types 4-6 need a migration).