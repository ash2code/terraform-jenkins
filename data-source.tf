data "aws_instance" "myawsinstance" {
    filter {
      name = "tag:Name"
      values = ["${local.resource_name}-ec2"]
    }
    depends_on = [ "aws_ec2.aws-ec2" ]
}