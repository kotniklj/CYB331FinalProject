# Branch: `Nick` — SQL injection (sqlmap) + before/after fix

**Owner:** Nick

## Goal

Own the **SQL injection** class end-to-end: get sqlmap reliably detecting the
Juice Shop login SQLi through the pipeline, harden the triage parsing for it, and
produce the **before/after** remediation demo the rubric wants.

## Tasks

1. Confirm `scanners/run_sqlmap.sh` flags the `email` param at
   `/rest/user/login` as injectable; tune `--level`/`--risk` if needed.
2. Harden the sqlmap signals in `triage.py` so a real hit is reliably parsed and
   a clean run reports "no finding" (no false positives).
3. **Before/after:** take a copy of the vulnerable login query, apply a
   parameterized-query fix, re-run the pipeline, and capture the finding
   clearing. Document both runs.

## Done criteria

- Pipeline reports SQL Injection **DETECTED** (CWE-89, A03) against stock Juice Shop.
- After the fix, the same run reports no SQLi finding.
- Short writeup of the fix in `docs/` for the report/slides.
