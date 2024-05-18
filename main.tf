resource "aws_vpc" "aws-vpc" {
    cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${local.env}-vpc"
  }
}

resource "aws_internet_gateway" "aws-igw" {
    vpc_id = aws_vpc.aws-vpc.id

    tags = {
        Name = "${local.env}-igw"
    }
}

resource "aws_internet_gateway_attachment" "aws-igw-attachment" {
    internet_gateway_id = aws_internet_gateway.aws-igw.id
    vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_subnet" "aws-subnet" {
    vpc_id = aws_vpc.aws-vpc.id
    cidr_block = var.subnet_cidr_block
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone
    tags = {
        Name = "${local.env}-subnet"
    }
}

resource "aws_route_table" "aws-route-table" {
    vpc_id = aws_vpc.aws-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws-igw.id
    }
    tags = {
        Name = "${local.env}-route-table"
    }
}

resource "aws_route_table_association" "aws-route-table-association" {
    subnet_id = aws_subnet.aws-subnet.id
    route_table_id = aws_route_table.aws-route-table.id
}

resource "aws_security_group" "aws-security-group" {
    vpc_id = aws_vpc.aws-vpc.id
    name = "${local.env}-security-group"
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
        Name = "${local.env}-security-group"
    }
}

resource "aws_network_acl" "aws-network-acl" {
    vpc_id = aws_vpc.aws-vpc.id
    subnet_ids = [aws_subnet.aws-subnet.id]
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
        Name = "${local.env}-network-acl"
    }
}

resource "aws_ec2" "aws-ec2" {
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.aws-subnet.id
    vpc_security_group_ids = [aws_security_group.aws-security-group.id]
    tags = {
        Name = "${local.env}-ec2"
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
        Name = "${local.env}-s3-bucket"
    }
}

resource "aws_s3_account_public_access_block" "aws-s3-pub-access" {

    bucket = aws_s3_bucket.aws-s3-bucket.bucket

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws-object-ownership" {
    bucket = aws_s3_bucket.aws-s3-bucket.bucket

    rule {
        object_ownership = "ObjectWriter"
    }
}