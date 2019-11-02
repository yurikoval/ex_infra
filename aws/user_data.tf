data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars = {
    ec2_user = "${var.ec2_user}"
    git_repo = "${var.git_repo}"
  }
}
