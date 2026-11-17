# Branch: `Aerin` — Unrestricted file upload (fuxploider)

**Owner:** Aerin

## Goal

Own the **file upload** class: wire fuxploider to Juice Shop's actual upload
endpoint and make the triage parse the result.

## Tasks

1. Find Juice Shop's upload endpoint/field (complaint upload / profile image) and
   configure `scanners/run_fuxploider.sh` (`--url`, `--not-regex`, any required
   form fields). Set the `FUXPLOIDER` path convention in the README.
2. Confirm fuxploider reports which disallowed extensions are accepted.
3. Harden the fuxploider signals in `triage.py` and confirm the severity/CWE
   mapping (CWE-434).

## Done criteria

- Pipeline reports Unrestricted File Upload **DETECTED** (CWE-434) against Juice Shop.
- Short note in `docs/` on the upload weakness found and how it was detected.
