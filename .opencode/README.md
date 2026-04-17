# Repo OpenCode Agents

This repository contains repo-level OpenCode automation under `.opencode/`.

## Included

- `agents/davriel-rogue-shadowmage.md`
  Push-time privacy/secret scanning agent.
- `reports/`
  Temporary workspace output directory used by the GitHub Action.

## GitHub Workflow

The repo includes a workflow at:

- `.github/workflows/opencode-push-privacy-scan.yml`

It runs on every push and asks OpenCode to scan the pushed changes for:

- secrets
- personal details
- hardcoded tokens / auth headers
- accidental machine-specific/private identifiers

## Manual Setup Required

Add this GitHub Actions secret in the repository settings:

- `OPENAI_API_KEY`

The workflow uses:

- `anomalyco/opencode/github@latest`
- the repo-local primary agent `davriel-rogue-shadowmage`
- `openai/gpt-5`

## Local Pre-Push Protection

This repo also includes a local pre-push blocker:

- `.githooks/pre-push`
- `scripts/privacy_scan_local.sh`

Enable it once per clone with:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-push scripts/privacy_scan_local.sh
```

This local hook scans only the to-be-pushed diff and blocks the push before anything leaves your machine.

## Behavior

- The workflow writes findings to `.opencode/reports/privacy-scan.md` inside the runner workspace.
- If no findings exist, the agent writes exactly `NO_FINDINGS`.
- If findings exist, the workflow fails the run and shows only a minimal summary message.

This is intentional so detailed findings are not dumped into public workflow summaries.

The report file is intentionally ignored in git and should not be committed.
