# Dashboard
module "provision_dashboard" {
  source     = "./modules/kubectl-apply"
  kubeconfig = local.kubeconfig_path

  apply = var.dashboard

  template = file(
    "${path.module}/cluster_configs/kubernetes-dashboard.tpl.yaml",
  )

  vars = {
    cni          = var.remove_aws_vpc_cni ? "" : "aws"
  }

  module_depends_on = [module.wait_for_eks.command]
}

module "provision_heapster" {
  source     = "./modules/kubectl-apply"
  kubeconfig = local.kubeconfig_path

  apply = var.dashboard

  template = file("${path.module}/cluster_configs/heapster.tpl.yaml")

  vars = {
    eks_endpoint = module.eks.cluster_endpoint
  }

  module_depends_on = [module.wait_for_eks.command]
}

module "provision_influxdb" {
  source     = "./modules/kubectl-apply"
  kubeconfig = local.kubeconfig_path

  apply = var.dashboard

  template = file("${path.module}/cluster_configs/influxdb.tpl.yaml")

  vars = {
  }

  module_depends_on = [module.wait_for_eks.command]
}

module "provision_heapster_rbac" {
  source     = "./modules/kubectl-apply"
  kubeconfig = local.kubeconfig_path

  apply = var.dashboard

  template = file("${path.module}/cluster_configs/heapster-rbac.tpl.yaml")

  vars = {
  }

  module_depends_on = [module.wait_for_eks.command]
}

module "provision_admin_service_account" {
  source     = "./modules/kubectl-apply"
  kubeconfig = local.kubeconfig_path

  apply = var.dashboard

  template = file(
    "${path.module}/cluster_configs/eks-admin-service-account.tpl.yaml",
  )

  vars = {
  }

  module_depends_on = [module.wait_for_eks.command]
}

data "external" "dashboard-token" {
  count = var.get_dashboard_token == "true" ? 1 : 0

  program = ["${path.module}/bin/get_dashboard_token.sh"]

  query = {
    kubeconfig       = local.kubeconfig_path
    wait_for_account = module.provision_admin_service_account.apply.id
  }
}
