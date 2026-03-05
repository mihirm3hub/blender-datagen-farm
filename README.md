# blenderline-cloud-renderfarm

A reproducible “push-button” synthetic data renderfarm for **Blender + BlenderLine**:
- Portable **job bundle** (images.json + assets/)
- Provision **N cloud machines** (default: AWS) with Terraform
- Bootstrap Blender + BlenderLine via cloud-init
- Each node renders a **unique shard** and uploads to **MinIO (S3-compatible)**

## What you get
- **Local workflow**: validate job bundle + run a shard on one machine.
- **Cloud workflow**: GitHub Actions → Terraform → N nodes → render → upload to MinIO.

This repo is designed so you can edit in VSCode and run from GitHub with minimal glue.

---

## Repo layout

```
job/
  images.json                 # your BlenderLine config (portable relative paths)
  assets/                     # your assets (scenes, hdrs, items, backgrounds, ...)

scripts/
  shard_config.py             # create per-shard configs (seed, dataset name, split sizes)
  validate_job.py             # verify required files exist for images.json
  run_local_windows.ps1       # run locally on Windows (your current setup)
  run_local_linux.sh          # run locally on Linux (optional)

infra/terraform/
  main.tf                     # AWS infra (N render nodes)
  variables.tf
  outputs.tf
  cloud-init.yaml.tftpl       # bootstraps Blender + BlenderLine + mc; runs shard

.github/workflows/
  render.yml                  # “Run renderfarm” workflow
```

---

## 1) Put your job bundle here

Copy your working config and assets into:

```
job/images.json
job/assets/
```

Your `images.json` must reference assets via **relative** paths like `assets/scenes/scene-001.blend`.

---

## 2) Configure MinIO

You need a MinIO server reachable from the render nodes.

Create a bucket, e.g.:
- `synthetic-datasets`

Recommended prefixes:
- input job zip: `jobs/example_beer_job.zip`
- outputs: `runs/<RUN_ID>/shards/shard-XX/...`

> This repo uses `mc` (MinIO client) for downloads/uploads.

---

## 3) Quick local validation

### Windows (your current environment)
1) Ensure BlenderLine works locally (you already did this).
2) From repo root:

```powershell
python scripts\validate_job.py --job .\job\images.json
```

If validation passes, run a local shard (writes to `./data_local/...`):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_local_windows.ps1 -BlenderlineExe "<PATH_TO_blenderline.exe>" -BlenderDir "<PATH_TO_BLENDER_DIR>" -ShardId 1 -RunId "local_test"
```

---

## 4) Cloud run (AWS default)

### Prereqs
- AWS account, VPC/subnet where instances will launch
- A security group allowing outbound internet (for Blender download)
- GitHub repo secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
- Optional: `AWS_SESSION_TOKEN` if using temporary creds

### Configure workflow inputs
Go to **Actions → Run workflow** and set:
- `run_id`
- `num_nodes`
- `minio_endpoint` (e.g. `http://10.0.0.10:9000` or public endpoint)
- `minio_access_key`, `minio_secret_key`
- `minio_bucket`
- `minio_job_object` (e.g. `jobs/example_beer_job.zip`)
- `minio_output_prefix` (e.g. `runs`)
- `aws_subnet_id`, `aws_security_group_id`, `aws_key_name`

### What happens
Each node:
1) downloads Blender
2) installs BlenderLine into Blender's bundled Python
3) downloads the job zip from MinIO to `/opt/job`
4) generates a shard-specific config
5) renders to local disk
6) uploads results back to MinIO under `runs/<run_id>/shards/shard-XX/`

---

## Notes / gotchas
- Your current config has CUDA enabled (`render_use_cuda=true`). If you use CPU nodes, set it false or pick GPU instances.
- Ensure your MinIO endpoint is reachable from the VPC/subnet.
- Large assets should not be committed to Git unless you use Git LFS; recommended: upload job zip to MinIO once.

---

## License
MIT for the repo scaffolding. Your job assets remain yours.
