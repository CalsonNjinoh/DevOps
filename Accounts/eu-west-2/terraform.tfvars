region          = "us-east-2"
name            = "Production"
cidr            = "10.20.0.0/16"
azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnets  = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
private_subnets = ["10.20.13.0/24", "10.20.14.0/24", "10.20.15.0/24"]
key_path        = "~/.ssh/id_rsa.pub"

tags = {
  "Environment" = "Production"
  "Type"        = "Production"
}
