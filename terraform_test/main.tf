# # Configure the Bitbucket Provider
# provider "bitbucket" {
#   username = var.username
#   password = var.password
# }

# # resource "bitbucket_project" "test_project0" {
# #   owner      = var.username
# #   name       = "foo"
# #   key        = "FOOPROJ"
# #   is_private = true
# # }

# resource "bitbucket_repository" "foo_foo_app1_repo" {
#   owner = "jtb91594"
#   name  = "foo_app1"
#   #project_key= "FOOPROJ"
#   project_key = "PROJ"
#   is_private  = true
# }

# resource "bitbucket_repository" "foo_foo_app2_repo" {
#   owner = "jtb91594"
#   name  = "foo_app2"
#   #project_key= "FOOPROJ"
#   project_key = "PROJ"
#   is_private  = true
# }

# # resource "bitbucket_project" "test_project1" {
# #   owner      = "jtb91594"
# #   name       = "bars"
# #   key        = "BARSPROJ"
# #   is_private = true
# # }

# resource "bitbucket_repository" "bars_bar_app0_repo" {
#   owner = "jtb91594"
#   name  = "bar_app0"
#   #project_key= "BARSPROJ"
#   project_key = "PROJ"
#   is_private  = true
# }

# resource "bitbucket_repository" "bars_bar_app1_repo" {
#   owner = "jtb91594"
#   name  = "bar_app1"
#   #project_key= "BARSPROJ"
#   project_key = "PROJ"
#   is_private  = true
# }

