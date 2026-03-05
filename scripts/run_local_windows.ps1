param(
  [Parameter(Mandatory=$true)][string]$BlenderlineExe,
  [Parameter(Mandatory=$true)][string]$BlenderDir,
  [Parameter(Mandatory=$true)][int]$ShardId,
  [Parameter(Mandatory=$true)][string]$RunId,
  [string]$JobDir = ".\job",
  [string]$OutRoot = ".\data_local"
)

$ErrorActionPreference = "Stop"

$JobDir = (Resolve-Path $JobDir).Path
New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null
$OutRoot = (Resolve-Path $OutRoot).Path

$cfgBase = Join-Path $JobDir "images.json"
if (-not (Test-Path $cfgBase)) { throw "Missing $cfgBase" }

# Create shard config
python scripts\shard_config.py --base $cfgBase --outdir $JobDir --num-shards 1 --run-id $RunId
$cfgShard = Join-Path $JobDir "images_shard_01.json"
$target = Join-Path $OutRoot "$RunId\shard-$('{0:d2}' -f $ShardId)"
New-Item -ItemType Directory -Force -Path $target | Out-Null

& $BlenderlineExe generate --config $cfgShard --target $target --blender $BlenderDir
if ($LASTEXITCODE -ne 0) { throw "blenderline generate failed" }

Write-Host "Done. Output: $target"
