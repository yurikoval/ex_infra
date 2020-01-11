data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "image-id"
    values = [var.default_ami]
  }

  owners = [var.ami_owner_id]
}
