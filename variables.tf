variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "ami_filter" {
  description = "Filter AMIs"

  type = object({
    name  = string
    vtype = string
    owner = string
  })

  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
    vtype = "hvm"
  }
}

variable "environment" {
  description = "Environment specification"

  type = object ({
    name           = string
    network_prefix = string
    azs            = list(string)
    public_subnets = list(string)
  })
  
  default = {
    azs            = ["us-west-2a", "us-west-2b", "us-west-2c"]
    name           = "dev"
    network_prefix = "10.0"
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }
}

variable "asg_min_size" {
  description = "Minimal autoscaling group size"
  default     = 1
}

variable "asg_max_size" {
  description = "Maximal autoscaling group size"
  default     = 2
}