#!/usr/bin/env bash
# Behavior test for install.sh. Runs against a throwaway $HOME; never touches the real one.
set -u
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
src="$repo/skills/rocke-pr-review"
fails=0
check() { # check <description> <command...>
  local what="$1"; shift
  if "$@"; then echo "ok   - $what"; else echo "FAIL - $what"; fails=$((fails + 1)); fi
}
fresh_home() { HOME="$(mktemp -d)"; export HOME; }
run() { "$repo/install.sh" "$@" >"$HOME/out" 2>"$HOME/err"; echo $? >"$HOME/rc"; }
rc_is() { [ "$(cat "$HOME/rc")" = "$1" ]; }
links_to_src() { [ -L "$1" ] && [ "$(readlink "$1")" = "$src" ]; }

# 1. Fresh install links each named tool and creates missing parent folders.
fresh_home
run claude omp
check "fresh install exits 0" rc_is 0
check "claude linked" links_to_src "$HOME/.claude/skills/rocke-pr-review"
check "omp linked (parent created)" links_to_src "$HOME/.omp/agent/skills/rocke-pr-review"
check "codex not linked" test ! -e "$HOME/.codex/skills/rocke-pr-review"

# 2. Re-running changes nothing and still succeeds.
run claude omp
check "re-run exits 0" rc_is 0
check "re-run reports already linked" grep -q "claude: already linked" "$HOME/out"
check "claude still linked" links_to_src "$HOME/.claude/skills/rocke-pr-review"

# 3. An existing real folder is never overwritten; other tools still get linked.
fresh_home
mkdir -p "$HOME/.codex/skills/rocke-pr-review"
touch "$HOME/.codex/skills/rocke-pr-review/keep-me"
run codex claude
check "conflict exits 1" rc_is 1
check "existing folder untouched" test -f "$HOME/.codex/skills/rocke-pr-review/keep-me"
check "existing folder not replaced by a link" test ! -L "$HOME/.codex/skills/rocke-pr-review"
check "conflict is reported" grep -q "codex: skipped" "$HOME/err"
check "other tool still linked" links_to_src "$HOME/.claude/skills/rocke-pr-review"

# 4. A link pointing somewhere else is also left alone.
fresh_home
mkdir -p "$HOME/.claude/skills"
ln -s /tmp "$HOME/.claude/skills/rocke-pr-review"
run claude
check "foreign link exits 1" rc_is 1
check "foreign link untouched" test "$(readlink "$HOME/.claude/skills/rocke-pr-review")" = /tmp

# 5. An unknown tool name fails before anything is created.
fresh_home
run claude bogus
check "unknown tool exits 2" rc_is 2
check "unknown tool named in error" grep -q "unknown tool: bogus" "$HOME/err"
check "nothing created for valid tool either" test ! -e "$HOME/.claude/skills/rocke-pr-review"

# 6. No arguments prints usage and fails.
fresh_home
run
check "no args exits 2" rc_is 2
check "no args prints usage" grep -q "usage:" "$HOME/err"

# 7. Cursor together with claude or codex warns about duplicate listing.
fresh_home
run cursor claude
check "cursor+claude exits 0" rc_is 0
check "cursor+claude warns" grep -q "more than once" "$HOME/err"
fresh_home
run cursor
check "cursor alone does not warn" test ! -s "$HOME/err"

echo
if [ "$fails" -eq 0 ]; then echo "all passed"; else echo "$fails failed"; fi
[ "$fails" -eq 0 ]
