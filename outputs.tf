output "tags" {
  description = "Map of created tags"
  value       = gitlab_project_tag.this
}

output "branches" {
  description = "Map of created branches"
  value       = gitlab_branch.this
}

output "tag_protections" {
  description = "Map of created protections of tags"
  value       = gitlab_tag_protection.this
}

output "branch_protections" {
  description = "Map of created protections of branches"
  value       = gitlab_branch_protection.this
}
