data "aws_instance" "myawsinstance" {
    filter {
      name = "tag:Name"
      values = ["${local.env}-ec2"]
    }
    depends_on = [ "aws_ec2.aws-ec2" ]
}