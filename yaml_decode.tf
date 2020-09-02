provider "bitbucket" {
  username = var.username
  password = var.password
}

locals {
  yaml_vals              = yamldecode(file("config.yaml"))
  group_app_set          = tolist(toset([for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code]]))
  group_app_service_vals = [for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code, config_val.service_name]]
}

resource "bitbucket_project" "group_proj" {
  for_each   = toset([for config_val in local.yaml_vals : config_val.group_code])
  owner      = var.username
  name       = each.value
  key        = "${upper(each.value)}PROJ"
  is_private = true
}

resource "bitbucket_repository" "app_repo" {
  count       = length(local.group_app_set)
  owner       = var.username
  name        = local.group_app_set[count.index][0]
  project_key = "${upper(local.group_app_set[count.index][1])}PROJ"
  is_private  = true
  depends_on = [bitbucket_project.group_proj]
}