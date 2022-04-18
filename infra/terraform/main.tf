resource "gitlab_project" "main" {
  count = 2

  name           = "test-${count.index}"
  description    = "New projects with main default branch"
  default_branch = "main"
}

resource "gitlab_project" "master" {
  count = 1

  name           = "test-${sum([count.index, length(gitlab_project.main)])}"
  description    = "New projects with master default branch"
  default_branch = "master"
}

locals {
  main_projects_str   = "[${join(",", gitlab_project.main[*].id)}]"
  master_projects_str = "[${join(",", gitlab_project.master[*].id)}]"
  tags = {
    "1.0.0" : "",
    "1.0.1" : "tags: {name: $TAG_NAME, projects: {main: ${local.main_projects_str}, master: ${local.master_projects_str}}}",
    "1.0.2" : "{branches: {name: release-$TAG_NAME, protected: {enabled: true, create_access_level: developer}, projects: {main: &main ${local.main_projects_str}, master: &master ${local.master_projects_str}}}, tags: {name: $TAG_NAME, projects: {release-$TAG_NAME: [*main, *master]}}}",
  }
}

resource "gitlab_project_tag" "this" {
  for_each = local.tags

  name    = each.key
  ref     = "master"
  project = "999"
  message = each.value
}
