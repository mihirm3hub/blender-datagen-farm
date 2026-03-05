resource "aws_instance" "render_node" {
  count = var.num_nodes

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.render_profile.name

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    shard_id         = count.index + 1
    run_id           = var.run_id
    train_size       = var.train_size
    valid_size       = var.valid_size
    blender_version  = var.blender_version
    s3_bucket        = var.s3_bucket
    s3_job_key       = var.s3_job_key
    s3_output_prefix = var.s3_output_prefix
    aws_region       = var.aws_region
    force_cpu        = var.force_cpu
  })

  tags = {
    Name = "blenderline-render-${var.run_id}-${count.index + 1}"
  }
}
