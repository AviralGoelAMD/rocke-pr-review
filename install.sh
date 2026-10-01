#!/usr/bin/env bash
# Link the rocke-pr-review skill into the skills folder of each named agent tool.
# Usage: ./install.sh <tool> [<tool> ...]   tools: claude codex cursor omp
# Never overwrites: an existing folder or a link to somewhere else is reported and skipped.
set -u

usage() { echo "usage: $0 <tool> [<tool> ...]   tools: claude codex cursor omp" >&2; }

skills_dir() {
  case "$1" in
    claude) echo "$HOME/.claude/skills" ;;
    codex)  echo "$HOME/.codex/skills" ;;
    cursor) echo "$HOME/.cursor/skills" ;;
    omp)    echo "$HOME/.omp/agent/skills" ;;
    *) return 1 ;;
  esac
}

[ $# -ge 1 ] || { usage; exit 2; }
for tool in "$@"; do
  skills_dir "$tool" >/dev/null || { echo "unknown tool: $tool" >&2; usage; exit 2; }
done

case " $* " in
  *" cursor "*)
    case " $* " in
      *" claude "* | *" codex "*)
        echo "warning: Cursor also reads ~/.claude/skills and ~/.codex/skills, so linking" \
          "cursor as well lists the skill more than once. Link cursor only if you use" \
          "neither claude nor codex." >&2 ;;
    esac ;;
esac

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
src="$repo/skills/rocke-pr-review"
status=0
for tool in "$@"; do
  dir="$(skills_dir "$tool")"
  link="$dir/rocke-pr-review"
  mkdir -p "$dir"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$src" ]; then
    echo "$tool: already linked"
  elif [ -e "$link" ] || [ -L "$link" ]; then
    echo "$tool: skipped, $link already exists and is not a link to $src" >&2
    status=1
  else
    ln -s "$src" "$link"
    echo "$tool: linked $link -> $src"
  fi
done
exit "$status"
