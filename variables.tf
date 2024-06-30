variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "additional_user_data" {
  description = "Text of the user data script"
  type        = string
  default     = ""
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

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

variable "iam_role_name" {
  description = "Name of the IAM role to create"
  type        = string
  default     = "ssm_instance_role"
}

variable "trust_relationships" {
  description = "IAM trust relationships for the instance role"
  type = list(object({
    Effect = string
    Action = list(string)
    Principal = object({
      Service = list(string)
    })
  }))
}

variable "iam_policies" {
  description = "IAM policies to attach to the instance role"
  type = list(object({
    name   = string
    policy = string
  }))
}
