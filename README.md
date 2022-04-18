<a href="https://terraform.io">
    <img src="https://github.com/gitlabhq/terraform-provider-gitlab/blob/main/.github/terraform_logo.svg" alt="Terraform logo" title="Terraform" align="right" height="50" />
</a>

# Gitlab microservices bumper

[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/terraform-gitlab-modules/terraform-gitlab-microservices-bumper?label=release)](https://github.com/terraform-gitlab-modules/terraform-gitlab-microservices-bumper/releases) [![license](https://img.shields.io/github/license/terraform-gitlab-modules/terraform-gitlab-microservices-bumper.svg)]()


Terraform module for creating Gitlab [branches](https://docs.gitlab.com/ee/api/branches.html) and [tags](https://docs.gitlab.com/ee/api/tags.html) from tag messages of the target Gitlab project. This module allows you to declaratively manage tags and branches of all microservices (repositories) which are in GitLab.


## Usage
https://user-images.githubusercontent.com/84093529/163398006-62bc631a-89db-4588-a312-8863bd87dbea.mp4

## Example

### Tag name

Recommend use [SemVer](https://semver.org/) tags name for future releases (for example `1.0.0`).

### Tag message
```yaml
# Now support only branches and tags. You can use tags and branches field separately from each other.
# Also, in the Yaml config, you can use $TAG_NAME variable. This variable equal tag name.
branches:
  # name is required field.
  name: release-$TAG_NAME
  # protected is an optional field and may miss.
  protected: &protected
    enabled: true
    create_access_level: developer
  # message is an optional field and may miss.
  message: Test
  # projects is required field. Format elements in projects is <branch name (ref) or commit SHA>: [<list of projects>].
  # NOTE: I really recommend you use commit SHA because if you recreate tag with this message all objects will be created from last commit of target branch.
  projects:
    main: &main [ 2, 3 ]
    b1c70966181b79a5adb3b593a9455f3c6515eedb: &master [ 4 ]
tags:
  name: $TAG_NAME
  protected: *protected
  projects:
    # Supported conversion from [[1,2], [3,4]] to [1,2,3,4].
    release-$TAG_NAME: [*main, *master]
```

### Terraform code

```terraform
terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 3.13.0"
    }
  }
}

provider "gitlab" {
  token    = "ACCTEST1234567890123"
  base_url = "http://localhost:8000/api/v4"
  insecure = false
}

module "gitlab_microservices_bumper" {
  source     = "terraform-gitlab-modules/microservices-bumper/gitlab"
  version    = "2.0.0"

  project_id = "999"
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | ~> 3.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | ~> 3.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gitlab_branch.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/branch) | resource |
| [gitlab_branch_protection.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/branch_protection) | resource |
| [gitlab_project_tag.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_tag) | resource |
| [gitlab_tag_protection.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/tag_protection) | resource |
| [gitlab_project_tags.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_message"></a> [message](#input\_message) | Default message of tags or branches | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to manage Gitlab tags and branches | `string` | n/a | yes |
| <a name="input_protected"></a> [protected](#input\_protected) | Default protection of tags or branches | <pre>object({<br>    enabled             = bool<br>    create_access_level = string<br>  })</pre> | <pre>{<br>  "create_access_level": "",<br>  "enabled": false<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_protections"></a> [branch\_protections](#output\_branch\_protections) | Map of created protections of branches |
| <a name="output_branches"></a> [branches](#output\_branches) | Map of created branches |
| <a name="output_tag_protections"></a> [tag\_protections](#output\_tag\_protections) | Map of created protections of tags |
| <a name="output_tags"></a> [tags](#output\_tags) | Map of created tags |
<!-- END_TF_DOCS -->
