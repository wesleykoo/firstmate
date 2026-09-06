# Deferred — cross-initiative "do X when Y" parking lot

Read at session start. When a deferred entry ships through the loop, mirror it as
`issues/NNN-deferred-*.md` and delete the entry here in the closing commit.

<!--
Entry format:

## <Initiative / topic> (surfaced YYYY-MM-DD, origin — e.g. "issue 006 review")

- **<The finding or deferred item, bolded as a one-line claim.>** Context: what
  was found, why it is real but out of scope now, and what sidesteps it today.
  Point at the file/lines involved and any constraints the eventual fix must
  respect (oracles that must not shift, fixtures that must stay byte-identical).
  **Fix when / Build when / Revisit trigger:** the explicit Y condition that
  promotes this entry into an issue.

Conventions:
- Every entry MUST carry an explicit trigger condition ("fix when next touching
  ingest", "build when manual input-gathering becomes the bottleneck") — an
  entry without a Y is a wish, not a deferral.
- Roadmap-style sections may track status inline: ✅ SHIPPED (with the
  prds/done or issues/done link), ⚠️ PARTIALLY SHIPPED (name what remains),
  ⏸️ CLOSED/descoped (record the decision, who made it, and its revisit
  trigger).
- Resolve in place: a shipped item is mirrored as issues/NNN-deferred-*.md then
  deleted here; a descoped item is marked ⏸️ with the decision — so the file
  stays an accurate parking lot, not a graveyard.
-->
