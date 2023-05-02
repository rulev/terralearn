# output "instance_ami" {
#   value = aws_instance.blog.ami
# }

# output "instance_arn" {
#   value = aws_instance.blog.arn
# }

# output "instance_public_ip" {
#   value = aws_instance.blog.public_ip
# }

output "alb_dns_name" {
  value = module.blog_alb.lb_dns_name
}
