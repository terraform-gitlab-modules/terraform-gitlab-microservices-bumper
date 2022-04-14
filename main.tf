locals {
  objects = {
    for option in ["tags", "branches"] : option => flatten([
      for tag in data.gitlab_project_tags.this.tags : [
        for branch, projects in lookup(yamldecode(tag.message != "" ? tag.message : "${option}: {projects: []}"), option, { projects = [] })["projects"] : [
          for project in projects : [
            {
              name      = "${lookup(lookup(yamldecode(tag.message), option, { prefix = var.prefix }), "prefix", var.prefix)}${tag.name}"
              project   = project
              ref       = branch
              message   = var.message
              protected = lookup(lookup(yamldecode(tag.message), option, { prefix = var.protected }), "protected", var.protected)
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
