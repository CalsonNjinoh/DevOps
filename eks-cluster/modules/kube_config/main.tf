locals {
  configmap_roles = [{
    rolearn  = aws_iam_role.eks-node-role.arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups = [
      "system:bootstrappers",
      "system:nodes",
    ]
    }
  ]

  configmap_users = [for user in var.aws_auth_users : {
    groups = [
      "system:masters",
    ]
    userarn  = user
    username = split("/", user)[1]
  }]

  auth_data = {
    mapRoles = yamlencode(local.configmap_roles)
    mapUsers = yamlencode(local.configmap_users)
  }

}

resource "kubernetes_config_map" "aws-auth-configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.auth_data

  depends_on = [
    aws_iam_role.eks-node-role
  ]
}
