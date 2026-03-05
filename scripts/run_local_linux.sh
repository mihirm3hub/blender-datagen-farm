#!/usr/bin/env bash
set -euo pipefail

# Example:
#   ./scripts/run_local_linux.sh /opt/blenderline/blenderline  /opt/blender-4.2.1-linux-x64  1 local_test ./job ./data_local
BLENDERLINE_EXE="${1:?blenderline exe path}"
BLENDER_DIR="${2:?blender install folder}"
SHARD_ID="${3:?shard id}"
RUN_ID="${4:?run id}"
JOB_DIR="${5:-./job}"
OUT_ROOT="${6:-./data_local}"

python3 scripts/validate_job.py --job "$JOB_DIR/images.json"
python3 scripts/shard_config.py --base "$JOB_DIR/images.json" --outdir "$JOB_DIR/shards" --num-shards 1 --run-id "$RUN_ID"

CFG="$JOB_DIR/shards/images_shard_01.json"
TARGET="$OUT_ROOT/$RUN_ID/shard-$(printf "%02d" "$SHARD_ID")"
mkdir -p "$TARGET"

"$BLENDERLINE_EXE" generate --config "$CFG" --target "$TARGET" --blender "$BLENDER_DIR"
echo "Done. Output: $TARGET"
