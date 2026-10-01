# rocke-pr-review

An agent skill that reviews a rocKE PR (ROCm/rocm-libraries, `hip-kernel-provider/rocke`)
against the team checklist. It grades every checklist item with evidence, one reviewer per
section, and prints the result for you. It never posts to GitHub.

Works with Claude Code, Codex, Cursor and omp (any tool that reads `SKILL.md` skill folders).

## Install

```bash
git clone git@github.com:AviralGoelAMD/rocke-pr-review.git ~/rocke-pr-review
cd ~/rocke-pr-review
./install.sh claude          # or any of: claude codex cursor omp
```

`install.sh` links `skills/rocke-pr-review` into each named tool's skills folder:

| Tool | Folder |
|---|---|
| `claude` | `~/.claude/skills/` |
| `codex` | `~/.codex/skills/` |
| `cursor` | `~/.cursor/skills/` |
| `omp` | `~/.omp/agent/skills/` |

Cursor also reads `~/.claude/skills` and `~/.codex/skills`. If you link `claude` or `codex`,
do not also link `cursor`, or Cursor lists the skill twice.

The installer never overwrites. If a `rocke-pr-review` folder or a different link is already
there, it says so and skips it; move it aside and re-run.

## Run

In your agent, ask for example:

- "Review PR 12712 against the rocke checklist."
- "Run the rocke checklist on my branch before I push."

You get one table per checklist section (`graded X/Y` at the end of each), then the findings
sorted by severity and an overall PASS/FAIL.

## Update

```bash
cd ~/rocke-pr-review && git pull
```

The skill folders are links, so every tool sees the new checklist immediately.

## Uninstall

Delete the links, e.g. `rm ~/.claude/skills/rocke-pr-review`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The checklist is
[`skills/rocke-pr-review/checklist.md`](skills/rocke-pr-review/checklist.md).
