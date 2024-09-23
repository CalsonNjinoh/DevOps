#######################################################
# Default Security Group
#######################################################

resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id

  ingress = []
  egress  = []
}

#######################################################
# Redis
#######################################################

resource "aws_security_group" "redis" {
  name        = "Redis"
  description = "Allow access to redis"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Redis"
  }, var.tags)
}

resource "aws_security_group_rule" "redis-vpc" {
  type              = "ingress"
  from_port         = 6168
  to_port           = 6168
  protocol          = "tcp"
  security_group_id = aws_security_group.redis.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "redis-backups" {
  type              = "ingress"
  from_port         = 6169
  to_port           = 6169
  protocol          = "tcp"
  security_group_id = aws_security_group.redis.id
  cidr_blocks       = ["${var.backup_private_ip}/32"]
}

resource "aws_security_group_rule" "redis-vpn" {
  type                     = "ingress"
  from_port                = 6169
  to_port                  = 6169
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.vpn.id

}

#######################################################
# MQTT
#######################################################

resource "aws_security_group" "mqtt" {
  name        = "MQTT"
  description = "Allow access to MQTT"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "MQTT"
  }, var.tags)
}

resource "aws_security_group_rule" "mqtt-vpc" {
  type              = "ingress"
  from_port         = 2616
  to_port           = 2616
  protocol          = "tcp"
  security_group_id = aws_security_group.mqtt.id
  cidr_blocks       = [var.vpc_cidr]
}
resource "aws_security_group_rule" "mqtt-vpn" {
  type                     = "ingress"
  from_port                = 1616
  to_port                  = 1616
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mqtt.id
  source_security_group_id = aws_security_group.vpn.id
}

#######################################################
# Elephants
#######################################################

resource "aws_security_group" "elephants" {
  name        = "Elephants"
  description = "Allow access to elephants"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Elephants"
  }, var.tags)
}

resource "aws_security_group_rule" "elephants-in" {
  type              = "ingress"
  from_port         = 43616
  to_port           = 43616
  protocol          = "tcp"
  security_group_id = aws_security_group.elephants.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "elephants-out" {
  type              = "egress"
  from_port         = 43616
  to_port           = 43616
  protocol          = "tcp"
  security_group_id = aws_security_group.elephants.id
  cidr_blocks       = [var.vpc_cidr]
}

#######################################################
# NGINX
#######################################################

resource "aws_security_group" "nginx" {
  name        = "Nginx"
  description = "Allow access to Nginx"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Nginx"
  }, var.tags)
}

resource "aws_security_group_rule" "nginx-alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nginx.id
  source_security_group_id = aws_security_group.alb.id
}

#######################################################
# Registration Server
#######################################################

resource "aws_security_group" "registration_server" {
  name        = "Registration Server"
  description = "Allow access to Registration Server"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Registration Server"
  }, var.tags)
}

resource "aws_security_group_rule" "registration_server_alb" {
  type                     = "ingress"
  from_port                = 56433
  to_port                  = 56433
  protocol                 = "tcp"
  security_group_id        = aws_security_group.registration_server.id
  source_security_group_id = aws_security_group.alb.id
}

#######################################################
# SSH
#######################################################

resource "aws_security_group" "ssh" {
  name        = "SSH"
  description = "Allow access to SSH"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "SSH"
  }, var.tags)
}

resource "aws_security_group_rule" "ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ssh.id
  source_security_group_id = aws_security_group.vpn.id
}

#######################################################
# API
#######################################################

resource "aws_security_group" "api" {
  name        = "API"
  description = "Allow access to API"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 6168
    to_port     = 6168
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 2616
    to_port     = 2616
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 43616
    to_port     = 43616
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge({
    Name = "API"
  }, var.tags)
}

resource "aws_security_group_rule" "api-alb" {
  type                     = "ingress"
  from_port                = 21899
  to_port                  = 21899
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.alb.id
}

#######################################################
# ALB
#######################################################

resource "aws_security_group" "alb" {
  name        = "ALB"
  description = "Allow access to ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "ALB"
  }, var.tags)
}

resource "aws_security_group_rule" "alb-api" {
  type                     = "egress"
  from_port                = 21899
  to_port                  = 21899
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.api.id
}

resource "aws_security_group_rule" "alb-registration" {
  type                     = "egress"
  from_port                = 56433
  to_port                  = 56433
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.registration_server.id
}

resource "aws_security_group_rule" "alb-files" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.nginx.id
}


#######################################################
# Backups
#######################################################

resource "aws_security_group" "backups" {
  name        = "Backups"
  description = "Allow access to Backups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 6169
    to_port     = 6169
    protocol    = "tcp"
    cidr_blocks = ["${var.redis_private_ip}/32"]
  }

  tags = merge({
    Name = "Backups"
  }, var.tags)
}

#######################################################
# VPN
#######################################################

resource "aws_security_group" "vpn" {
  name        = "VPN"
  description = "Allow access to VPN"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "vpn-redis" {
  type                     = "egress"
  from_port                = 6169
  to_port                  = 6169
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpn.id
  source_security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "vpn-ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "vpn-mqtt" {
  type                     = "egress"
  from_port                = 1616
  to_port                  = 1616
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpn.id
  source_security_group_id = aws_security_group.mqtt.id
}

resource "aws_security_group_rule" "vpn-postgres" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.vpn.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "vpn-opensearch" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpn.id
  source_security_group_id = aws_security_group.opensearch.id
}

#######################################################
# OpenSearch
#######################################################

resource "aws_security_group" "opensearch" {
  name        = "OpenSearch"
  description = "Allow access to OpenSearch"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "OpenSearch"
  }, var.tags)
}

resource "aws_security_group_rule" "opensearch-vpn-ingress-opensearch-port" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "opensearch-vpn-ingress-https-port" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "opensearch-vpn-ingress-http-port" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "opensearch-vpc-ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.opensearch.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "opensearch-egress" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  security_group_id = aws_security_group.opensearch.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#######################################################
# Mongo Out
#######################################################

resource "aws_security_group" "backend-services" {
  name        = "Backend Services"
  description = "Allow access to backend services"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Backend Services"
  }, var.tags)
}

resource "aws_security_group_rule" "backend-services-mongo" {
  type              = "egress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "backend-services-mqtt" {
  type              = "egress"
  from_port         = 2616
  to_port           = 2616
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "backend-services-redis" {
  type              = "egress"
  from_port         = 6168
  to_port           = 6168
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "backend-services-elephants" {
  type              = "egress"
  from_port         = 43616
  to_port           = 43616
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "backend-services-rds" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "backend-services-redis-backups" {
  type              = "egress"
  from_port         = 6169
  to_port           = 6169
  protocol          = "tcp"
  security_group_id = aws_security_group.backend-services.id
  cidr_blocks       = [var.vpc_cidr]
}


#######################################################
# Lambda VPC Security Group
#######################################################

resource "aws_security_group" "lambda_sg" {
  count       = var.create_lambda_sg ? 1 : 0
  name        = "Lambda VPC"
  description = "Allow access to Lambda function"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "Lambda VPC"
  }, var.tags)
}

resource "aws_security_group_rule" "lambda_sg_ingress_http" {
  count             = var.create_lambda_sg ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_sg_ingress_https" {
  count             = var.create_lambda_sg ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_sg_egress" {
  count             = var.create_lambda_sg ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lambda_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}
