#!/usr/bin/env python3
"""
Validates that all asset paths referenced in images.json exist relative to its directory.

Usage:
  python scripts/validate_job.py --job job/images.json
"""
from __future__ import annotations
import argparse, json
from pathlib import Path

def iter_paths(cfg: dict):
    # Scene
    if "scene" in cfg and isinstance(cfg["scene"], dict) and "path" in cfg["scene"]:
        yield cfg["scene"]["path"]

    # HDRs
    for e in cfg.get("hdrs", {}).get("entries", []) or []:
        p = e.get("path")
        if p: yield p

    # Backgrounds
    for e in cfg.get("backgrounds", {}).get("entries", []) or []:
        p = e.get("path")
        if p: yield p

    # Items
    for e in cfg.get("items", {}).get("entries", []) or []:
        p = e.get("path")
        if p: yield p

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True, help="Path to images.json")
    args = ap.parse_args()

    job_path = Path(args.job)
    base_dir = job_path.parent

    cfg = json.loads(job_path.read_text(encoding="utf-8"))
    missing = []
    for rel in iter_paths(cfg):
        fp = (base_dir / rel).resolve()
        if not fp.exists():
            missing.append((rel, str(fp)))

    if missing:
        print("Missing assets:")
        for rel, fp in missing:
            print(f"  - {rel}  ->  {fp}")
        raise SystemExit(2)

    print("OK: All referenced asset paths exist.")

if __name__ == "__main__":
    main()
