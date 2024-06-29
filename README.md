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
    user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > /home/ec2-user/hello-world.sh
              chmod +x /home/ec2-user/hello-world.sh
              EOF

}
```
