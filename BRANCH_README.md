# Branch: `Liam` — Cross-Site Scripting (Dalfox)

**Owner:** Liam

## Goal

Own the **XSS** class: get Dalfox to land a real hit on Juice Shop and make the
triage parse it cleanly.

## Tasks

1. Identify a scanner-reachable XSS in Juice Shop (start with reflected/search;
   note which challenges are DOM-based and out of Dalfox's reach).
2. Tune `scanners/run_dalfox.sh` — endpoint list, parameters, and
   `--format json` output — so a real finding is produced.
3. Harden the Dalfox signals in `triage.py` (parse `dalfox.json` where possible,
   not just the text log).

## Done criteria

- Pipeline reports Cross-Site Scripting **DETECTED** (CWE-79, A03) for at least
  one specific Juice Shop instance.
- Short note in `docs/` on which XSS challenges are caught vs missed and why.
