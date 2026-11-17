# Branch: `Alec` — Target + pipeline orchestration + triage/report

**Owner:** Alec

## Goal

Own the **infrastructure**: the local Juice Shop target, the pipeline
orchestration, and the triage/report output everyone's findings flow into.

## Tasks

1. Make `target/run_juiceshop.sh` rock-solid on a clean VM (docker pull, start,
   health-check, stop). Document any `sudo`/docker-group setup in the README.
2. Harden `pipeline/run_pipeline.py`: the local-only guard, per-scanner
   error handling, and the `--only` dev flag.
3. Improve `pipeline/triage.py` / `report.html`: de-duplication across tools,
   consistent CWE/OWASP mapping, and a clean report for the demo.

## Done criteria

- `./scripts/lab_up.sh` runs clean on a fresh VM and opens a readable report.
- Pipeline refuses any non-local target.
- Report shows all three classes with correct CWE/OWASP mapping and status.
