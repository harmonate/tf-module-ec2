# EC2 Instance with SSM Access

This module creates an EC2 instance with the specified instance type, looks up an appropriate Amazon Linux AMI, and allows a connection through AWS Systems Manager (SSM). The module takes a subnet and a map of ingress ports as inputs.

## Inputs

- `instance_type`: The EC2 instance type (default: `t2.micro`).
- `subnet_id`: The ID of the subnet where the instance will be launched.
- `region`: The AWS region to deploy to.
- `ingress_ports`: Map of ingress ports and their protocols. Default includes HTTP (port 80) and HTTPS (port 443).

## Outputs

- `instance_id`: The ID of the EC2 instance.
- `instance_public_ip`: The public IP of the EC2 instance.

## Example Usage

```hcl
module "ec2_with_ssm" {
  source        = "git::https://github.com/harmonate/tf-module-ec2.git?ref=main"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"
  vpc_id        = "vpc-012345678"
  ingress_ports = {
    ssh = {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  additional_user_data = templatefile("${path.module}/scripts/project_template.tftpl", {
    variable_name        = aws_resource.name
  })

  iam_role_name = "my_custom_role"
  trust_relationships = local.trust_relationships
  iam_policies = local.iam_policies

}

# Define trust relationships
locals {
  trust_relationships = [
    {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals = {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    },
    {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:root"]
      }
    }
  ]
}

# Define IAM policies
locals {
  iam_policies = [
    {
      name = "SSMManagedInstanceCore"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "ssm:DescribeAssociation",
              "ssm:GetDeployablePatchSnapshotForInstance",
              "ssm:GetDocument",
              "ssm:DescribeDocument",
              "ssm:GetManifest",
              "ssm:GetParameter",
              "ssm:GetParameters",
              "ssm:ListAssociations",
              "ssm:ListInstanceAssociations",
              "ssm:PutInventory",
              "ssm:PutComplianceItems",
              "ssm:PutConfigurePackageResult",
              "ssm:UpdateAssociationStatus",
              "ssm:UpdateInstanceAssociationStatus",
              "ssm:UpdateInstanceInformation"
            ]
            Resource = "*"
          }
        ]
      })
    },
    {
      name = "custom_s3_access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::my-bucket/*"
          }
        ]
      })
    }
  ]
}
```
