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

It runs on every push and scans the pushed changes for:

- secrets
- personal details
- hardcoded tokens / auth headers
- accidental machine-specific/private identifiers

Note:

- the OpenCode GitHub Action does not support the raw `push` event directly
- so the push workflow uses the repo-local shell scanner from `scripts/privacy_scan_local.sh`
- the Davriel agent remains in `.opencode/agents/` for future OpenCode-supported GitHub triggers or repo-local usage

## Manual Setup Required

No GitHub Actions secret is required for the push workflow.

If you later add an OpenCode-supported GitHub workflow (for example `workflow_dispatch`, `schedule`, PR review comments, or issue comments), you can reuse:

- the repo-local primary agent `davriel-rogue-shadowmage`
- `openai/gpt-5`
- an `OPENAI_API_KEY` repository secret

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

- The push workflow runs `scripts/privacy_scan_local.sh` against the pushed diff in CI.
- If suspicious content is detected, the workflow fails.
- The workflow summary stays intentionally minimal.

This is intentional so detailed findings are not dumped into public workflow summaries.

The report file is intentionally ignored in git and should not be committed.
