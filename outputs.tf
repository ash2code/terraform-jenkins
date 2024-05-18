output "fetched_info_from_aws" {
    value = data.aws_instance.myawsinstance.public_ip
}