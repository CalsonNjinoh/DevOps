module "my_asg" {
  source                     = "../../Modules/Auto_scaling"
  create_alb_security_group  = true
  asg_name                   = "APIserver"
  min_size                   = 1
  max_size                   = 3
  desired_capacity           = 1
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.public_subnet_ids
  launch_template_name       = "api-launch-template"
  launch_template_description= "Launch template for api ASG"
  image_id                   = "ami-0ea18256de20ecdfc"
  instance_type              = "t2.micro"
  iam_role_name              = "amazonssm-managedinstance-iam-role"
  iam_role_description       = "IAM role for AmazonSSMManagedInstanceCore ASG"
  security_group_id          = module.security_group.security_group_id
  availability_zone          = "ca-central-1b"
  alb_subnets                = [module.network.public_subnet_ids[0] , module.network.public_subnet_ids[1]]
  alb_security_groups        = [module.my_asg.alb_security_group_id]
  ssl_certificate_arn        = "arn:aws:acm:ca-central-1:370308050188:certificate/ad60b22a-6858-4cbc-a618-b08cac3f5731"
}
