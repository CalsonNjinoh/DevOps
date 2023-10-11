region          = "ca-central-1"
name            = "Sandbox"
cidr            = "10.20.0.0/16"
azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
public_subnets  = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
private_subnets = ["10.20.13.0/24", "10.20.14.0/24", "10.20.15.0/24"]
key_path        = "~/.ssh/id_rsa.pub"

tags = {
  "Environment" = "sandbox"
  "Type"        = "sandbox"
}
