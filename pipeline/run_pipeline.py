#!/usr/bin/env python3
"""
run_pipeline.py — scan -> triage for local OWASP Juice Shop (Track B).

Runs the three scanners (sqlmap, Dalfox, fuxploider) against a LOCAL Juice Shop
instance, saves their raw output under results/, then runs the triage step to
produce a ranked findings report.

HARD GUARD: the target must be a local instance (localhost / 127.0.0.1 or an
RFC1918 address). The assignment forbids scanning any shared or public Juice
Shop, and this script refuses to run against anything else.

Usage:
    python3 pipeline/run_pipeline.py                      # http://localhost:3000
    python3 pipeline/run_pipeline.py --base http://localhost:3000
    python3 pipeline/run_pipeline.py --only sqlmap        # run one scanner
"""
import argparse
import ipaddress
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent.parent
SCANNERS = ROOT / "scanners"


def assert_local(base: str):
    host = urlparse(base).hostname or ""
    if host in ("localhost",):
        return
    try:
        ip = ipaddress.ip_address(host)
    except ValueError:
        raise SystemExit(f"refusing: target host '{host}' is not local. "
                         "Only your own local Juice Shop (localhost/127.0.0.1 or a "
                         "private address) may be scanned.")
    if not (ip.is_loopback or ip.is_private):
        raise SystemExit(f"refusing: {host} is not a local/private address.")


def run(script: str, *args) -> int:
    path = SCANNERS / script
    print(f"\n{'='*60}\n>>> {script} {' '.join(args)}\n{'='*60}")
    return subprocess.run(["bash", str(path), *args]).returncode


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="http://localhost:3000", help="local Juice Shop base URL")
    ap.add_argument("--upload", default=None, help="override fuxploider upload URL")
    ap.add_argument("--only", choices=["sqlmap", "dalfox", "fuxploider"],
                    help="run just one scanner")
    args = ap.parse_args()

    assert_local(args.base)
    (ROOT / "results").mkdir(exist_ok=True)

    steps = [("run_sqlmap.sh", args.base),
             ("run_dalfox.sh", args.base),
             ("run_fuxploider.sh", args.upload or f"{args.base}/file-upload")]
    if args.only:
        steps = [s for s in steps if s[0].startswith(f"run_{args.only}")]

    for script, arg in steps:
        rc = run(script, arg)
        if rc == 2:
            print(f"[pipeline] {script} skipped — tool not installed (see README).")

    print(f"\n{'='*60}\n>>> triage\n{'='*60}")
    subprocess.run([sys.executable, str(ROOT / "pipeline" / "triage.py")])
    print("\n[pipeline] done — see results/report.html and results/findings.json")


if __name__ == "__main__":
    main()
