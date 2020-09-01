#Configure the Bitbucket Provider
provider "bitbucket" {
  username = var.username
  password = var.password
}

locals {
  yaml_vals              = yamldecode(file("config.yaml"))
  group_app_set          = tolist(toset([for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code]]))
  group_app_service_vals = [for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code, config_val.service_name]]
}

# resource "bitbucket_project" "group_proj" {
#   for_each   = toset([for config_val in local.yaml_vals : config_val.group_code])
#   owner      = var.username
#   name       = each.value
#   key        = "${upper(each.value)}PROJ"
#   is_private = true
# }

# resource "bitbucket_repository" "app_repo" {
#   count       = length(local.group_app_set)
#   owner       = var.username
#   name        = local.group_app_set[count.index][0]
#   project_key = "${upper(local.group_app_set[count.index][1])}PROJ"
#   is_private  = true

#   provisioner "file" {
#     source = "README.md"
#     #destination = "${local.group_app_set[count.index][0]}/${coalesce([for pod in local.group_app_service_vals : pod[2] if pod[0] == local.group_app_set[count.index][0] && pod[1] == local.group_app_set[count.index][1]])}"
#     destination = "README.md"
#   }
# }

resource "bitbucket_repository" "test_repo" {
  owner       = var.username
  name        = local.group_app_set[0][0]
  project_key = "${upper(local.group_app_set[0][1])}PROJ"
  is_private  = true

  provisioner "file" {
    source      = "README.md"
    destination = "${local.group_app_set[0][0]}/README.md"

    connection {
      type     = "winrm"
      https    = "true"
      user     = var.username
      password = var.password
      host     = "https://jtb91594@bitbucket.org/jtb91594/${local.group_app_set[0][0]}.git"
    }
  }
}