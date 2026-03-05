provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "render_node" {
  count = var.num_nodes

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    shard_id            = count.index + 1
    num_nodes           = var.num_nodes
    run_id              = var.run_id
    train_size          = var.train_size
    valid_size          = var.valid_size
    blender_version     = var.blender_version
    minio_endpoint      = var.minio_endpoint
    minio_access_key    = var.minio_access_key
    minio_secret_key    = var.minio_secret_key
    minio_bucket        = var.minio_bucket
    minio_job_object    = var.minio_job_object
    minio_output_prefix = var.minio_output_prefix
    force_cpu           = var.force_cpu
  })

  tags = {
    Name = "blenderline-render-${var.run_id}-${count.index + 1}"
  }
}
