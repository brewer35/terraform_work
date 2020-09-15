provider "bitbucket" {
  username = var.username
  password = var.password
}

locals {
  yaml_vals              = yamldecode(file(var.file_path))
  group_app_set          = tolist(toset([for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code]]))
  group_app_service_vals = [for config_val in local.yaml_vals : [config_val.app_code, config_val.group_code, config_val.service_name]]
  app_code_tags          = [for config_val in local.yaml_vals : [config_val.tags, config_val.app_code] if contains(keys(config_val), "tags")]
  num_defined_tags       = length(flatten([for dict_val in [for tag_dict in local.app_code_tags : tag_dict[0]] : keys(dict_val)]))
  defined_tags_keys      = chunklist(flatten([for val in local.app_code_tags : setproduct(toset(keys(val[0])), toset([val[1]]))]), 2)
  defined_tags_vals      = flatten([for val in local.app_code_tags : values(val[0])])
}

resource "bitbucket_project" "group_proj" {
  for_each   = toset([for config_val in local.yaml_vals : config_val.group_code])
  owner      = var.username
  name       = each.value
  key        = "${upper(each.value)}PROJ"
  is_private = true
}

resource "bitbucket_repository" "app_repo" {
  count             = length(local.group_app_set)
  owner             = var.username
  name              = local.group_app_set[count.index][0]
  project_key       = "${upper(local.group_app_set[count.index][1])}PROJ"
  pipelines_enabled = true
  is_private        = true
  depends_on        = [bitbucket_project.group_proj]
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = templatefile("templates/readme.tpl", { service_name = coalesce([for val in local.group_app_service_vals : val[2] if val[0] == local.group_app_set[count.index][0]]...),
      username = var.username,
      password = var.password,
      slug     = local.group_app_set[count.index][0],
    count_val = count.index })
  }
}

resource "bitbucket_repository_variable" "group_code_tag" {
  count      = length(bitbucket_repository.app_repo)
  depends_on = [bitbucket_repository.app_repo]
  key        = "group_code"
  value      = local.group_app_set[count.index][1]
  secured    = false
  repository = bitbucket_repository.app_repo[count.index].id
}

resource "bitbucket_repository_variable" "app_code_tag" {
  count      = length(bitbucket_repository.app_repo)
  depends_on = [bitbucket_repository.app_repo]
  key        = "app_code"
  value      = bitbucket_repository.app_repo[count.index].name
  secured    = false
  repository = bitbucket_repository.app_repo[count.index].id
}

resource "bitbucket_repository_variable" "service_name_tag" {
  count      = length(bitbucket_repository.app_repo)
  depends_on = [bitbucket_repository.app_repo]
  key        = "service_name"
  value      = coalesce([for val in local.group_app_service_vals : val[2] if val[0] == local.group_app_set[count.index][0]]...)
  secured    = false
  repository = bitbucket_repository.app_repo[count.index].id
}

resource "bitbucket_repository_variable" "defined_tags" {
  count      = local.num_defined_tags
  depends_on = [bitbucket_repository.app_repo]
  key        = local.defined_tags_keys[count.index][0]
  value      = local.defined_tags_vals[count.index]
  secured    = false
  repository = "${var.username}/${local.defined_tags_keys[count.index][1]}"
}