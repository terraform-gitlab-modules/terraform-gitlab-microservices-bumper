variable "base_url" {
  description = "This is the target GitLab base API endpoint"
  type        = string
  default     = "http://localhost:8000/api/v4"
}

variable "token" {
  description = "The OAuth2 Token, Project, Group, Personal Access Token or CI Job Token used to connect to GitLab"
  type        = string
  default     = "ACCTEST1234567890123"
}

