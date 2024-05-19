resource "aws_vpc" "aws-vpc" {
    cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${local.resource_name}-vpc"
  }
}

resource "aws_internet_gateway" "aws-igw" {
    vpc_id = aws_vpc.aws-vpc.id

    tags = {
        Name = "${local.resource_name}-igw"
    }
}

# resource "aws_internet_gateway_attachment" "aws-igw-attachment" {
#     internet_gateway_id = aws_internet_gateway.aws-igw.id
#     vpc_id = aws_vpc.aws-vpc.id
# }

resource "aws_subnet" "aws-subnet" {
    vpc_id = aws_vpc.aws-vpc.id
    count = var.environment == "dev" ? 3:1
    cidr_block = element(var.public_subnet_cidr_list,count.index)
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone
    tags = {
        Name = "${local.resource_name}-subnet-${count.index + 1}"
    }
}

resource "aws_route_table" "aws-route-table" {
    vpc_id = aws_vpc.aws-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws-igw.id
    }
    tags = {
        Name = "${local.resource_name}-route-table"
    }
}

resource "aws_route_table_association" "aws-route-table-association" {
    count = var.environment == "dev" ? 3:1
    subnet_id = aws_subnet.aws-subnet[count.index].id
    route_table_id = aws_route_table.aws-route-table.id
}

resource "aws_security_group" "aws-security-group" {
    vpc_id = aws_vpc.aws-vpc.id
    name = "${local.resource_name}-security-group"
    description = "Allow SSH inbound traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.allowed_ssh_cidr_blocks
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.egress_cidr_blocks
    }
    tags = {
        Name = "${local.resource_name}-security-group"
    }
}

resource "aws_network_acl" "aws-network-acl" {
    vpc_id = aws_vpc.aws-vpc.id
    count = var.environment == "dev" ? 3:1
    subnet_ids = [aws_subnet.aws-subnet[count.index].id]
    ingress {
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    egress {
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    tags = {
        Name = "${local.resource_name}-network-acl"
    }
}

resource "aws_instance" "aws-ec2" {
    count = var.environment == "dev" ? 3:1
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.aws-subnet[count.index].id
    vpc_security_group_ids = [aws_security_group.aws-security-group.id]
    tags = {
        Name = "${local.resource_name}-ec2-${count.index + 1}"
        env = upper(var.environment)
    }
    user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              echo "<h1>Hello World</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
}


resource "aws_s3_bucket" "aws-s3-bucket" { 
    bucket = var.bucket_name
    
    tags = {
        Name = "${local.resource_name}-s3-bucket"
    }
}
