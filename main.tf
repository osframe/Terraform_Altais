
resource "aws_vpc" "terra-vpc" {
  cidr_block       = "172.16.0.0/16"


  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "terraform-IGW"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.terra-vpc.id
  cidr_block = "172.16.1.0/24"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "public-subnet-terraform"
  }
}

resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.terra-vpc.main_route_table_id

  tags = {
    Name = "main-rt-public"
  }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_vpc.terra-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_vpc.terra-vpc.main_route_table_id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow all inbound http traffic "
  vpc_id = aws_vpc.terra-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web-server" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.ec2-key}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
  subnet_id = aws_subnet.public-subnet.id

user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd.x86_64
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
EOF
  tags = {
    Name = "web-server-terraform"
  }
}
