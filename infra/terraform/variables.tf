variable "aws_region" { type = string }

variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "key_name" { type = string }

variable "num_nodes" { type = number  default = 5 }

# Instance type:
# - GPU (recommended for render_use_cuda=true): g5.xlarge / g4dn.xlarge (AWS)
# - CPU testing: c6i.xlarge etc.
variable "instance_type" { type = string default = "g5.xlarge" }

# Ubuntu 22.04 LTS x86_64
variable "ami_id" { type = string }

# MinIO
variable "minio_endpoint" { type = string } # e.g. http://10.0.0.10:9000
variable "minio_access_key" { type = string }
variable "minio_secret_key" { type = string }
variable "minio_bucket" { type = string default = "synthetic-datasets" }

# MinIO object key for input job zip, e.g. jobs/example_beer_job.zip
variable "minio_job_object" { type = string }

# Output prefix in bucket, e.g. runs
variable "minio_output_prefix" { type = string default = "runs" }

# Run parameters
variable "run_id" { type = string }
variable "train_size" { type = number default = 100 }
variable "valid_size" { type = number default = 20 }

# Blender version to install (Linux)
variable "blender_version" { type = string default = "4.2.1" }

# Optional: turn off CUDA in config if using CPU nodes
variable "force_cpu" { type = bool default = false }
