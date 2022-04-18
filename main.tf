locals {
  options = ["tags", "branches"]

  config_messages = {
    for option in local.options : option => flatten([
      for tag in data.gitlab_project_tags.this.tags : [
        lookup(yamldecode(tag.message != "" ? replace(tag.message, "$TAG_NAME", tag.name) : "${option}: {name: '', projects: []}"), option, { name = "", projects = [] })
      ]
    ])
  }

  objects = {
    for option in local.options : option => flatten([
      for config_message in local.config_messages[option] : [
        for branch, projects in config_message["projects"] : [
          for project in flatten(projects) : [
            {
              name      = config_message["name"]
              project   = project
              ref       = branch
              message   = lookup(config_message, "message", var.message)
              protected = lookup(config_message, "protected", var.protected)
            }
          ]
        ]
      ]
    ])
  }
}

data "gitlab_project_tags" "this" {
  project = var.project_id
}

resource "gitlab_project_tag" "this" {
  for_each = { for tag in local.objects["tags"] : "${tag.project}:${tag.name}" => tag }

  name    = each.value.name
  ref     = each.value.ref
  project = each.value.project
  message = each.value.message

  depends_on = [
    gitlab_branch.this
  ]
}

resource "gitlab_tag_protection" "this" {
  for_each = {
    for tag in local.objects["tags"] : "${tag.project}:${tag.name}" => tag
    if tag.protected["enabled"] == true
  }

  project             = each.value.project
  tag                 = gitlab_project_tag.this[each.key].name
  create_access_level = each.value.protected["create_access_level"]

  depends_on = [
    gitlab_branch.this
  ]
}

resource "gitlab_branch" "this" {
  for_each = { for branch in local.objects["branches"] : "${branch.project}:${branch.name}" => branch }

  name    = each.value.name
  ref     = each.value.ref
  project = each.value.project
}

resource "gitlab_branch_protection" "this" {
  for_each = {
    for branch in local.objects["branches"] : "${branch.project}:${branch.name}" => branch
    if branch.protected["enabled"] == true
  }

  project                = each.value.project
  branch                 = gitlab_branch.this[each.key].name
  merge_access_level     = each.value.protected["create_access_level"]
  push_access_level      = each.value.protected["create_access_level"]
  unprotect_access_level = each.value.protected["create_access_level"]
}
