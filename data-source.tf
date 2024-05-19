data "aws_instance" "myawsinstance" {
  for_each = {for i in range(var.environment == "dev" ? 3 : 1) : i => "${local.resource_name}-ec2-${i + 1}"}
  filter {
    name = "tag:Name"
    values = [each.value]
  }
  depends_on = [aws_instance.aws-ec2]
}