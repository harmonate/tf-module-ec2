variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be launched"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "ingress_ports" {
  description = "Map of ingress ports and their protocols"
  type = map(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
  }))
  default = {
    http = {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
