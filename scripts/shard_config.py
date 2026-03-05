#!/usr/bin/env python3
"""
Create per-shard BlenderLine configs by modifying:
- dataset.name (adds shard suffix)
- dataset.splits sizes (optional overrides)
- dataset.seed (optional; if BlenderLine ignores this, at least dataset name stays unique)

Usage:
  python scripts/shard_config.py --base job/images.json --outdir job/shards --num-shards 5 --run-id run_20260305 --train 100 --valid 20
"""
from __future__ import annotations
import argparse, json
from pathlib import Path

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, help="Path to base images.json")
    ap.add_argument("--outdir", required=True, help="Directory to write shard configs")
    ap.add_argument("--num-shards", type=int, required=True)
    ap.add_argument("--run-id", required=True)
    ap.add_argument("--train", type=int, default=None)
    ap.add_argument("--valid", type=int, default=None)
    ap.add_argument("--seed-base", type=int, default=1000)
    args = ap.parse_args()

    base_path = Path(args.base)
    cfg = json.loads(base_path.read_text(encoding="utf-8"))

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    for i in range(1, args.num_shards + 1):
        shard = json.loads(json.dumps(cfg))  # deep copy
        # Dataset name unique per shard
        shard_name = f"{cfg.get('dataset', {}).get('name', 'dataset')}_{args.run_id}_shard_{i:02d}"
        shard.setdefault("dataset", {})["name"] = shard_name

        # Optional seed (may or may not be used by blenderline; safe to include)
        shard["dataset"]["seed"] = args.seed_base + i

        # Optional split overrides
        if args.train is not None or args.valid is not None:
            splits = shard["dataset"].get("splits", [])
            for sp in splits:
                if sp.get("name") == "train" and args.train is not None:
                    sp["size"] = int(args.train)
                if sp.get("name") == "valid" and args.valid is not None:
                    sp["size"] = int(args.valid)
            shard["dataset"]["splits"] = splits

        out_path = outdir / f"images_shard_{i:02d}.json"
        out_path.write_text(json.dumps(shard, indent=2), encoding="utf-8")
        print(f"Wrote {out_path}")

if __name__ == "__main__":
    main()
