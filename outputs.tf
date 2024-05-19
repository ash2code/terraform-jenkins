output "fetched_info_from_aws" {
    value = data.aws_instance.myawsinstance[count.index].public_ip
}