#!/bin/sh
# PO-121 PO-124: work lives in <session folder>/.worktrees. This lists what is still there (worktrees, processes
# running inside them) so nothing is left behind: at session start, and when a Local Board card changes status.
# It only reports; removing is for the AI to do with the person's agreement.
root="${CLAUDE_PROJECT_DIR:-$PWD}"
wt="$root/.worktrees"

leftovers() {
  [ -d "$wt" ] || return 0
  now=$(date +%s)
  for d in "$wt"/*/; do
    [ -e "${d}.git" ] || continue
    d=${d%/}
    br=$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null)
    dirty=$(git -C "$d" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    mod=$(stat -f %m "$d" 2>/dev/null || stat -c %Y "$d" 2>/dev/null || echo "$now")
    echo "- worktree .worktrees/$(basename "$d") (branch ${br:-?}, uncommitted files $dirty, untouched $(( (now - mod) / 86400 )) days)"
  done
  command -v lsof >/dev/null 2>&1 || return 0
  real=$(cd "$wt" && pwd -P)
  lsof -a -d cwd -Fpn 2>/dev/null | awk -v w="$real/" '/^p/ { p = substr($0, 2) } /^n/ { n = substr($0, 2); if (index(n, w) == 1) print p " " n }' |
    while read -r pid dir; do
      echo "- process $pid ($(ps -o comm= -p "$pid" 2>/dev/null | sed 's#.*/##')) running in .worktrees/${dir#"$real"/}"
    done
}

json_escape() { awk 'BEGIN { ORS = "" } { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, " "); if (NR > 1) print "\\n"; print }'; }

case "$1" in
  start)
    items=$(leftovers)
    [ -n "$items" ] && printf '%s\n%s\n%s\n' "Spec Hub cleanup (PO-124): left over from earlier work in this folder:" "$items" "Tell the person, in their language, and ask before removing anything: git worktree remove for finished work, stop processes nobody uses."
    ;;
  card)
    input=$(cat)
    printf '%s' "$input" | grep -q '"status"' || exit 0
    items=$(leftovers)
    [ -n "$items" ] || exit 0
    text=$(printf '%s\n%s\n%s\n' "Cleanup receipt (PO-124) for this card's status change. Still open in .worktrees:" "$items" "If the work on this card is finished (PR merged or the person says done), remove its worktree (git worktree remove, then git worktree prune), stop its processes and containers, delete temporary files, and delete the local branch only if it is pushed and merged; never a remote branch. Check and delete are separate commands. Keep anything that belongs to other open work and say so. Report what you removed and what you kept." | json_escape)
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$text"
    ;;
esac
exit 0
