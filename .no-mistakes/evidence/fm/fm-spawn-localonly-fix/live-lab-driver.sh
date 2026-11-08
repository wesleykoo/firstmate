#!/usr/bin/env bash
# live.sh <repo-root> <scenario> : drive real fm-spawn.sh in a disposable lab
set -u
REPO=$1 SCEN=$2
LAB=$(cd "$(mktemp -d "${TMPDIR:-/tmp}/fm-lab.XXXXXX")" && pwd -P)
"$REPO/bin/fm-lab-home.sh" create "$LAB" >/dev/null
mkdir -p "$LAB/tmux" "$LAB/pool"
export TREEHOUSE_ROOT="$LAB/pool"
ID="lv$(date +%s)$RANDOM"
P="$LAB/proj/notes"; mkdir -p "$LAB/proj"
gc() { git -C "$P" -c user.name=Lab -c user.email=lab@example.invalid "$@"; }
DEF=main; [ "$SCEN" = trunk ] && DEF=trunk; git init -q -b "$DEF" "$P"; echo base > "$P/README.md"; gc add README.md; gc commit -qm A
A=$(git -C "$P" rev-parse HEAD)
# prewarm one pool slot at A, then return it (stale slot)
SLOT=$(cd "$P" && treehouse get --lease --lease-holder prewarm 2>/dev/null)
(cd "$P" && treehouse return --force "$SLOT") >/dev/null 2>&1
echo "prewarmed slot=$SLOT at A=$A"
# advance main to B
echo "current local work" > "$P/advanced.txt"; gc add advanced.txt; gc commit -qm B
B=$(git -C "$P" rev-parse HEAD)
EXTRA=()
case "$SCEN" in
  feature-checkout) gc checkout -qb feature/wip; echo f > "$P/feature-only.txt"; gc add feature-only.txt; gc commit -qm F ;;
  base-branch) gc checkout -qb feature/base; echo fb > "$P/base-only.txt"; gc add base-only.txt; gc commit -qm FB; FB=$(git -C "$P" rev-parse HEAD); gc checkout -q "$DEF" ;;
  missing-base) ;;
  dirty) echo "precious" > "$SLOT/uncommitted.txt" ;;
esac
mkdir -p "$LAB/data/$ID"
cat > "$LAB/data/$ID/brief.md" <<B
# Task
## Captain's intent
live lab check for origin-less spawn base refresh

## Firstmate spec
Do nothing.
B
case "$SCEN" in base-branch) printf '\n# Setup\nYou are in a disposable git worktree of notes, at a detached HEAD on a clean copy of its base branch.\nBase branch: feature/base\n' >> "$LAB/data/$ID/brief.md"; EXTRA=(--base-branch feature/base);;
  missing-base) printf '\n# Setup\nYou are in a disposable git worktree of notes, at a detached HEAD on a clean copy of its base branch.\nBase branch: feature/absent\n' >> "$LAB/data/$ID/brief.md"; EXTRA=(--base-branch feature/absent);; esac
echo "origin remotes in project: [$(git -C "$P" remote)]"
T="env TMUX_TMPDIR=$LAB/tmux tmux -L fm-lab"
$T -f /dev/null new-session -d -s primary -x 200 -y 50 -c "$REPO" -e FM_HOME="$LAB" -e TREEHOUSE_ROOT="$LAB/pool"
OUT="$LAB/spawn.out"
$T send-keys -t primary "env -u NO_MISTAKES_GATE -u FM_GATE_REFUSE_BYPASS -u FM_ROOT_OVERRIDE -u FM_STATE_OVERRIDE -u FM_DATA_OVERRIDE -u FM_CONFIG_OVERRIDE -u FM_PROJECTS_OVERRIDE FM_HOME=$LAB FM_SPAWN_NO_GUARD=1 bin/fm-spawn.sh $ID $P --scout ${EXTRA[*]} --harness 'sleep 3600' > $OUT 2>&1; echo EXIT=\$? >> $OUT" Enter
for i in $(seq 1 120); do grep -q '^EXIT=' "$OUT" 2>/dev/null && break; sleep 1; done
echo "--- fm-spawn.sh output (scenario=$SCEN) ---"; cat "$OUT"
WT=$(grep -s '^worktree=' "$LAB/state/$ID.meta" | cut -d= -f2-)
echo "--- result ---"
echo "A(stale)=$A B(main tip)=$B ${FB:+feature/base=$FB}"
echo "meta worktree=${WT:-<none>}"
[ -n "$WT" ] && echo "worker HEAD=$(git -C "$WT" rev-parse HEAD)  files: $(ls "$WT" | tr '\n' ' ')"
echo "slot HEAD=$(git -C "$SLOT" rev-parse HEAD 2>/dev/null) slot files: $(ls "$SLOT" 2>/dev/null | tr '\n' ' ')"
[ -e "$LAB/state/$ID.meta" ] && { echo "--- meta ---"; grep -E '^(worktree|base_branch|kind|mode)=' "$LAB/state/$ID.meta"; }
echo "main still at B: $( [ "$(git -C "$P" rev-parse refs/heads/$DEF)" = "$B" ] && echo yes || echo NO)"
$T capture-pane -p -t primary | grep -v '^$' | tail -5 > /dev/null
$T kill-server 2>/dev/null
(cd "$P" && for w in $(git worktree list --porcelain | awk '/^worktree /{print $2}'); do [ "$w" = "$P" ] || treehouse return --force "$w" >/dev/null 2>&1; done)
rm -rf "/tmp/fm-$ID"; chmod -R u+w "$LAB"; rm -rf "$LAB"
echo "lab removed: $( [ -e "$LAB" ] && echo no || echo yes)"
