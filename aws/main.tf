resource "aws_instance" "app" {
  ami             = data.aws_ami.linux.id
  instance_type   = var.instance_type
  key_name        = var.ami_key_pair_name
  vpc_security_group_ids = [aws_security_group.ingress-all.id]
  subnet_id = aws_subnet.app.id
  user_data = data.template_file.user_data.rendered

  tags = {
    Name = var.tags_name
  }
}

resource "aws_vpc" "app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.tags_name
  }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id
  vpc      = true
}

resource "aws_subnet" "app" {
  cidr_block = cidrsubnet(aws_vpc.app.cidr_block, 3, 1)
  vpc_id = aws_vpc.app.id
  availability_zone = var.subnet_availability_zone
}

resource "aws_security_group" "ingress-all" {
  name = "allow-all-sg"
  vpc_id = aws_vpc.app.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags = {
    Name = var.tags_name
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.app.id
    }
  tags = {
    Name = var.tags_name
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

output "app-ip" {
  value = aws_eip.app.public_ip
}

resource "aws_route53_record" "public" {
  zone_id = var.route53_public_zone_id
  name    = var.public_dns
  type    = "A"
  ttl     = "120"
  records = [aws_eip.app.public_ip]
}

resource "null_resource" "app" {
  triggers = {
    arn = aws_instance.app.arn
  }

  connection {
    type = "ssh"
    host = aws_eip.app.public_ip
    user = var.ec2_user
    agent = true
    timeout = "3m"
    private_key = file("~/.ssh/${var.ami_key_pair_name}.pem")
  }

  provisioner "file" {
    source      = "../.env.prod"
    destination = "/tmp/.env"
  }

  provisioner "file" {
    source      = "../config/dev.exs"
    destination = "/tmp/dev.exs"
  }
}
