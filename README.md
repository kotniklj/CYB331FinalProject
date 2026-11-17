# CYB331 Final Project — Secure Development Pipeline (Track B)

A non-agentic **scan → triage → report** pipeline for three vulnerability
classes — **SQL injection, XSS, and file upload** — against a **local** OWASP
Juice Shop instance, using the designated tools **sqlmap, Dalfox, and
fuxploider**.

> ⚠️ **Local target only.** Everything runs against your own Juice Shop
> container (`localhost:3000`). The assignment forbids scanning any shared or
> public instance, and `run_pipeline.py` refuses any non-local target.

This is the **midpoint pipeline** (pre-agent): run the scanners, collect and
triage findings, show a before/after when a fix is applied. The optional agentic
layer (Track A) can be added later on top of this same pipeline.

## Layout

```
target/     run_juiceshop.sh   start/stop the local Juice Shop container
scanners/   run_sqlmap.sh      SQLi scan (login email param)
            run_dalfox.sh      XSS scan (product search param)
            run_fuxploider.sh  file-upload scan
pipeline/   run_pipeline.py    orchestrates the scanners (local-only guard)
            triage.py          parse -> dedupe -> rank -> report
report/     (reserved for richer reporting)
scripts/    lab_up.sh          one command: start target, scan, open report
docs/       ARCHITECTURE.md, PIPELINE_WEDNESDAY.md
branch_plans/ one file per member (Nick, Alec, Liam, Aerin)
results/     (generated) raw tool output + findings.json + report.html
```

## Prerequisites (in the VM)

```bash
# Docker (to run Juice Shop)
docker --version

# The three scanners
sqlmap --version
dalfox version
# fuxploider is run from a clone:
#   git clone https://github.com/almandin/fuxploider
#   pip3 install -r fuxploider/requirements.txt
#   export FUXPLOIDER=$PWD/fuxploider/fuxploider.py
```

If any are missing, see each tool's install page. `run_pipeline.py` skips a
scanner that isn't installed (exit code 2) rather than failing the whole run.

## Run it

```bash
./scripts/lab_up.sh
```

That starts Juice Shop, runs all three scanners against it, triages the output,
and opens `results/report.html` — a table of each vulnerability class, the tool
that found it, the CWE / OWASP mapping, severity, and detection status.

Run a single scanner while developing:
```bash
python3 pipeline/run_pipeline.py --only sqlmap
```

## Before/after (the rubric's key demo)

1. Run the pipeline against Juice Shop as-is → it detects SQLi / XSS / upload.
2. Apply a defined fix (e.g. parameterize the login query) to a copy.
3. Re-run → the finding clears. Document what cleared and what didn't.

## Deliverables (per the guidelines)

Presentation + live demo, source + setup instructions (this README), a 5-min
recorded demo, and a contribution report. Keep it small and *running* — a
simple pipeline that works end-to-end beats an ambitious one that doesn't.
