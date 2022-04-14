module "gitlab_microservices_bumper" {
  source = "../../"

  project_id = "999"
}

data "gitlab_projects" "test_projects" {
  search = "test"
}

locals {
  test_object = {
    "two_tags" : sort(flatten([
      for tag_name in ["1.0.1", "v1.0.2"] : [
        for project_id in data.gitlab_projects.test_projects.projects[*].id :
        "${project_id}:${tag_name}"
      ]
    ])),
    "one_tag" : sort(flatten([
      for tag_name in ["v1.0.2"] : [
        for project_id in data.gitlab_projects.test_projects.projects[*].id :
        "${project_id}:${tag_name}"
      ]
    ])),
  }
}

resource "test_assertions" "tags_ids" {
  component = "tags"

  equal "main_ids" {
    description = "Check tags IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.tags))
    want        = local.test_object["two_tags"]
  }

  equal "protection_ids" {
    description = "Check tags protection IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.tag_protections))
    want        = local.test_object["one_tag"]
  }
}

resource "test_assertions" "branches_ids" {
  component = "branches"

  equal "main_ids" {
    description = "Check branches IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.branches))
    want        = local.test_object["one_tag"]
  }

  equal "protection_ids" {
    description = "Check branches protection IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.branch_protections))
    want        = local.test_object["one_tag"]
  }
}