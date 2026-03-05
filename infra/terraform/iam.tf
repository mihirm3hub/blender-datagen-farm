data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "render_role" {
  name               = "blenderline-render-${var.run_id}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "render_s3_policy" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.s3_bucket}"]
  }

  statement {
    sid       = "ReadJobZip"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket}/${var.s3_job_key}"]
  }

  statement {
    sid = "WriteOutputs"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["arn:aws:s3:::${var.s3_bucket}/${var.s3_output_prefix}/${var.run_id}/*"]
  }
}

resource "aws_iam_role_policy" "render_role_inline" {
  name   = "blenderline-render-s3-${var.run_id}"
  role   = aws_iam_role.render_role.id
  policy = data.aws_iam_policy_document.render_s3_policy.json
}

resource "aws_iam_instance_profile" "render_profile" {
  name = "blenderline-render-profile-${var.run_id}"
  role = aws_iam_role.render_role.name
}
