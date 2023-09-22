provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public2"
  }
}
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "private2"
  }
}
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw1"
  }
}

resource "aws_route_table" "publicroute1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "publicroute1"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicroute1.id
}

resource "aws_route_table" "publicroute2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "publicroute2"
  }
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicroute2.id
}

resource "aws_eip" "eip1" {

  tags = {
    name = "eip1"
  }
}
resource "aws_nat_gateway" "natgateway1" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.eip1.id

  tags = {
    name = "natgateway1"
  }
}

resource "aws_route_table" "privaterout1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway1.id
  }

  tags = {
    Name = "privaterout1"
  }
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.privaterout1.id
}
resource "aws_route_table" "privaterout2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway1.id
  }

  tags = {
    Name = "privaterout2"
  }
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.privaterout2.id
}
resource "aws_key_pair" "rsa" {
  key_name   = "id"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCRoynF9loJrXTWuCPM7tiPfFFJ9aJCRq22dgrkIlwQolJNpDi/ij5F00iDPOGisGRit9xc5G521WvFgToeSSPgQq9h8XNCPbKsv7q5CSfTGx91btG084tQ5CiVpn2eULTSBu1ElGO0kpaEEMPQEpMERocu2X/xTcmlLIJ3pArYp2fzwN+0MjZMyf3BExLY5wGNuZhNxDrCWf7OQhRMn5mzzSbV3VDTS01DZNiOC5GvATymoSdiLNdsaov1UqQyZOsNiMwyELP5G+yGEOqcdzW2pwfMNComin5epPlp/TEEmlv0oL4IS0juyPOjti0N/xzeesUEESVP/nbPW+gLEqAwGvzd2iW6tPJuS0pD+ZBRoFv+9d6SNzzDcKswim2lR5A47W/a7vlmAOGylSHSgJfS/d2OCHnAo0QoxoXWQIOWclcguR8sbXLIGBhOMQVRZj8oyrEQrQYBBsrqkjvTTF/b0I2dNuU+zuO92x+LOX0jrpFvGAIqYQ8YoEHZXmu8cIk= rohit@rohit"
}

resource "aws_security_group" "security-grupe" {
  name        = "example-security-group"
  description = "Example security group for SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rules (inbound traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere (not recommended for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere (not recommended for production)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS access from anywhere (not recommended for production)
  }

  # Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere (not recommended for production)
  }
  tags = {
    Name = "security-grupe"
  }
}

resource "aws_instance" "public1" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public1.id
  key_name                    = aws_key_pair.rsa.key_name
  security_groups             = aws_security_group.security-grupe[*].id
  associate_public_ip_address = true

  tags = {
    Name = "publec1"
  }
}

resource "aws_instance" "private1" {
  ami             = "ami-053b0d53c279acc90"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private1.id
  key_name        = aws_key_pair.rsa.key_name
  security_groups = aws_security_group.security-grupe[*].id

  tags = {
    Name = "private1"
  }
}
resource "aws_instance" "private2" {
  ami             = "ami-053b0d53c279acc90"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private2.id
  key_name        = aws_key_pair.rsa.key_name
  security_groups = aws_security_group.security-grupe[*].id

  tags = {
    Name = "private2"
  }
}

resource "aws_lb_target_group" "rohit" {
  for_each    = var.alb_names
  name        = each.value
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id # Specify your VPC ID
  target_type = "instance"



  health_check {
    path                = "/index.html" # Customize the health check path
    interval            = 30            # Health check interval in seconds
    timeout             = 5             # Health check timeout in seconds
    healthy_threshold   = 3             # Number of consecutive successful health checks
    unhealthy_threshold = 2             # Number of consecutive failed health checks

  }
}
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.rohit["test"].arn
  target_id        = aws_instance.private1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "example1" {
  target_group_arn = aws_lb_target_group.rohit["test"].arn
  target_id        = aws_instance.private2.id
  port             = 80
}


resource "aws_lb" "example" {
  for_each                   = var.alb_names
  name                       = each.value
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.private1.id, aws_subnet.private2.id] # Specify your subnets
  enable_deletion_protection = false
  #  lb_target_group_id = aws_lb_target_group.rohit.id
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  security_groups                  = aws_security_group.security-grupe[*].id

  tags = {
    Environment = "Production"
    Role        = "Sample-Application"
  }
}

# Attach the target group to the ALB
resource "aws_lb_listener" "my_listener" {
  for_each          = var.alb_names
  load_balancer_arn = aws_lb.example[each.value].arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_lb_target_group.rohit[each.value].id
    type             = "forward"
  }

  depends_on = [aws_lb_target_group.rohit] # Ensure the target group is created before attaching
}
