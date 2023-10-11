resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.name} TF SSH Key"
  public_key = file(var.key_path)
}

