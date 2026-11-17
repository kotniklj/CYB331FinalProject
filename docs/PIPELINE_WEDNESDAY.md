# Midpoint check-in — what we show (by Nov 18)

The rubric's midpoint is "pipeline working manually, pre-agent/pre-automation."
We don't need the agentic layer — we need the scan→triage loop running against a
local Juice Shop.

## The one thing to demonstrate

> Start a local Juice Shop, run sqlmap / Dalfox / fuxploider against it, collect
> and triage the output into a ranked findings report, and show a before/after
> on at least one fix.

## 90-second demo

1. **Show the target** — `./target/run_juiceshop.sh`, Juice Shop up at
   `localhost:3000`, intentionally vulnerable, local only.
2. **Run the pipeline** — `./scripts/lab_up.sh` runs all three scanners and opens
   the report.
3. **Show the report** — the table: SQLi (sqlmap), XSS (Dalfox), file upload
   (fuxploider), each with CWE/OWASP mapping and DETECTED status.
4. **Before/after** — point at one fix (e.g. parameterized login query), re-run,
   show that finding clear.

## Minimum bar for Wednesday

sqlmap catching the login SQLi end-to-end through the pipeline proves the whole
loop. Dalfox and fuxploider landing a hit are the next steps (endpoint tuning on
their branches). Even 1/3 through the full scan→triage→report flow is a working
pipeline; aim for 2–3.

## Division of labor

See `../branch_plans/`:
- **Nick** — SQL injection (sqlmap) + the before/after fix demo.
- **Alec** — target + Docker + pipeline orchestration + triage/report.
- **Liam** — XSS (Dalfox) endpoint tuning.
- **Aerin** — file upload (fuxploider) endpoint wiring + severity ranking.

## Checklist

- [ ] Docker installed; `run_juiceshop.sh` brings up `localhost:3000`
- [ ] `sqlmap`, `dalfox`, `fuxploider` installed (or FUXPLOIDER env set)
- [ ] `./scripts/lab_up.sh` produces `results/report.html`
- [ ] At least sqlmap's SQLi shows DETECTED
- [ ] One before/after fix captured for the slides
