variable "aws_region" { type = string }

variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "key_name" { type = string }

# Ubuntu 22.04 LTS x86_64 AMI ID for your region
variable "ami_id" { type = string }

variable "num_nodes" { type = number  default = 1 }

# CPU test instance type suggestion: c6i.xlarge (adjust as needed)
variable "instance_type" { type = string default = "c6i.xlarge" }

# Run parameters
variable "run_id" { type = string }
variable "train_size" { type = number default = 2 }
variable "valid_size" { type = number default = 2 }

# Blender version to install (Linux)
variable "blender_version" { type = string default = "4.2.1" }

# If true, sets scene.render_use_cuda=false in the shard config (use for CPU nodes)
variable "force_cpu" { type = bool default = true }

# S3 (storage for input job zip + outputs)
variable "s3_bucket" { type = string }
variable "s3_job_key" { type = string }          # e.g. jobs/example_beer_job.zip
variable "s3_output_prefix" { type = string default = "runs" }
