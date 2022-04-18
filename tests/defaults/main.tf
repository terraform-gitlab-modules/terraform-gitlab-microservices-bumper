module "gitlab_microservices_bumper" {
  source = "../../"

  project_id = "999"
}

data "gitlab_projects" "test_projects" {
  search = "test"
}

locals {
  test_values = { "tags" : ["1.0.1", "1.0.2"], "branches" : ["release-1.0.2"], "tags_protected" : ["1.0.2"], "branches_protected" : ["release-1.0.2"] }
  test_object = { for option, tags_names in local.test_values :
    option => sort(flatten([
      for tag_name in tags_names : [
        for project_id in data.gitlab_projects.test_projects.projects[*].id :
        "${project_id}:${tag_name}"
      ]
    ]))
  }
}

resource "test_assertions" "tags_ids" {
  component = "tags"

  equal "main_ids" {
    description = "Check tags IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.tags))
    want        = local.test_object["tags"]
  }

  equal "protection_ids" {
    description = "Check tags protection IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.tag_protections))
    want        = local.test_object["tags_protected"]
  }
}

resource "test_assertions" "branches_ids" {
  component = "branches"

  equal "main_ids" {
    description = "Check branches IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.branches))
    want        = local.test_object["branches"]
  }

  equal "protection_ids" {
    description = "Check branches protection IDs"
    got         = sort(keys(module.gitlab_microservices_bumper.branch_protections))
    want        = local.test_object["branches_protected"]
  }
}
