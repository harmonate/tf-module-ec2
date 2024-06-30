data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ssm_role" {
  provider = aws.default
  name     = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.trust_relationships
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  provider = aws.default
  name     = "${var.iam_role_name}_profile"
  role     = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy" "custom_policies" {
  count  = length(var.iam_policies)
  name   = var.iam_policies[count.index].name
  role   = aws_iam_role.ssm_role.id
  policy = var.iam_policies[count.index].policy
}

resource "aws_instance" "ec2_instance" {
  provider               = aws.default
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ssm_sg.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "SSM-Managed-Instance"
  }

  user_data = templatefile("${path.module}/scripts/user_data.tftpl", {
    additional_user_data = var.additional_user_data
  })

  # Enable SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  lifecycle {
    ignore_changes = [ami, tags, volume_tags]
  }
}

resource "aws_security_group" "ssm_sg" {
  provider    = aws.default
  name        = "ssm_sg"
  description = "Allow SSM access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
