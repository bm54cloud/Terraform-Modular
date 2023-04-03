variable "variables_region" {
  description = "Region"
  type        = string
  default     = "us-east-2"
}

variable "variables_ami" {
  description = "AMI"
  type        = string
  default     = "ami-0533def491c57d991"
}

variable "variables_instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "variables_instance_name" {
  description = "Instance Name"
  type        = string
  default     = "Instance1"
}

variable "variables_key_name" {
  description = "EC2 Key Name"
  type        = string
  default     = "EC2-Ohio"
}

variable "variables_cidr" {
  description = "CIDR for All IPs"
  type        = string
  default     = "0.0.0.0/0"
}

variable "variables_tcp" {
  description = "TCP Protocol"
  type        = string
  default     = "tcp"
}

variable "variables_egress" {
  description = "Egress All"
  type        = string
  default     = "-1"
}

variable "variables_block_public_acls" {
  description = "Block all public ACLs"
  type        = bool
  default     = true
}

variable "variables_block_public_policy" {
  description = "Block all public ACLs"
  type        = bool
  default     = true
}

variable "variables_ignore_public_acls" {
  description = "Block all public ACLs"
  type        = bool
  default     = true
}

variable "variables_restrict_public_buckets" {
  description = "Block all public ACLs"
  type        = bool
  default     = true
}
