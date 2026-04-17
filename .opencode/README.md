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

## Behavior

- The workflow writes findings to `.opencode/reports/privacy-scan.md` inside the runner workspace.
- If no findings exist, the agent writes exactly `NO_FINDINGS`.
- If findings exist, the workflow publishes the report to the job summary and fails the run.

The report file is intentionally ignored in git and should not be committed.
