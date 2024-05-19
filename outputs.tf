output "fetched_info_from_aws" {
  value = [for i in data.aws_instance.myawsinstance : i.public_ip]
}