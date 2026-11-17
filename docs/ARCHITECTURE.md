# Architecture

```
  ┌──────────────┐   HTTP    ┌──────────────────────┐
  │ scanners/    │──────────▶│ Local Juice Shop      │
  │ sqlmap       │           │ (docker, localhost:3000)
  │ dalfox       │◀──────────│  intentionally vuln.  │
  │ fuxploider   │  findings └──────────────────────┘
  └──────┬───────┘
         │ raw output -> results/*.txt
         ▼
  ┌──────────────┐
  │ triage.py    │  parse -> dedupe -> map CWE/OWASP -> rank
  └──────┬───────┘
         │ findings.json
         ▼
  ┌──────────────┐
  │ report.html  │  scoreboard: class / tool / CWE / severity / status
  └──────────────┘
```

## Components

| Stage | File | Responsibility |
|-------|------|----------------|
| Target | `target/run_juiceshop.sh` | Start/stop the local Juice Shop container |
| Scan — SQLi | `scanners/run_sqlmap.sh` | sqlmap against the login `email` param |
| Scan — XSS | `scanners/run_dalfox.sh` | Dalfox against the search `q` param |
| Scan — Upload | `scanners/run_fuxploider.sh` | fuxploider against the upload endpoint |
| Orchestrate | `pipeline/run_pipeline.py` | Runs scanners; **local-only** guard |
| Triage | `pipeline/triage.py` | Findings, CWE/OWASP mapping, ranking, report |
| One-command | `scripts/lab_up.sh` | Target → scan → triage → open report |

## Vulnerability-class mapping

| Class | Tool | Endpoint | CWE | OWASP | Severity |
|-------|------|----------|-----|-------|----------|
| SQL Injection | sqlmap | `/rest/user/login` (email) | CWE-89 | A03 Injection | High |
| Cross-Site Scripting | Dalfox | `/rest/products/search` (q) | CWE-79 | A03 Injection | Medium |
| Unrestricted File Upload | fuxploider | `/file-upload` | CWE-434 | A04 Insecure Design | High |

## Isolation

All testing targets a self-run Juice Shop container on `localhost`. The pipeline
refuses any non-local/non-private target. No shared or public instance is ever
touched.

## Known limitations (be honest in the report)

- Triage uses simple string signals in each tool's output; false negatives are
  possible if a tool changes its wording. Each member hardens their own class.
- Dalfox may not catch Juice Shop's DOM-based XSS from the search endpoint alone;
  the endpoint list needs tuning (Liam).
- fuxploider needs the real upload form/field for Juice Shop wired in (Aerin).
