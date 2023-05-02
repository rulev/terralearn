data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_filter.vtype]
  }

  owners = [var.ami_filter.owner]
}

# data "aws_vpc" "default" {
#   default = true
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment.name}-vpc"
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = var.environment.azs
  public_subnets  = var.environment.public_subnets

  # enable_nat_gateway = true

  tags = {
    Environment = var.environment.name
  }
}

# resource "aws_instance" "blog" {
#   ami           = data.aws_ami.app_ami.id
#   instance_type = var.instance_type


#   vpc_security_group_ids = [module.blog_sg.security_group_id]
#   subnet_id              = module.vpc.public_subnets[0]

#   tags = {
#     Name = "blog"
#   }
# }

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.9.0"

  name = "${var.environment.name}-blog-asg"
  min_size = var.asg_min_size
  max_size = var.asg_max_size

  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = module.blog_alb.target_group_arns

  security_groups = [module.blog_sg.security_group_id]

  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Environment = var.environment.name
  }
}

module "blog_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.environment.name}-blog-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.blog_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "${var.environment.name}-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      # targets = {
      #   my_target = {
      #     target_id = aws_instance.blog.id
      #     port = 80
      #   }
      # }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.environment.name
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"
  name    = "${var.environment.name}-blog"

  vpc_id = module.vpc.vpc_id

  

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  tags = {
    Environment = var.environment.name
  }
}

# resource "aws_security_group" "blog" {
#   name        = "blog" 
#   description = "Allow http, https in. Allow everything out."

#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_security_group_rule" "blog_http_in" {
#   type        = "ingress"
#   from_port   = 80
#   to_port     = 80
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = aws_security_group.blog.id 
# }

# resource "aws_security_group_rule" "blog_https_in" {
#   type        = "ingress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = aws_security_group.blog.id 
# }

# resource "aws_security_group_rule" "blog_any_out" {
#   type        = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = aws_security_group.blog.id 
# }