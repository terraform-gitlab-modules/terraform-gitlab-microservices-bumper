variable "project_id" {
  description = "The project ID to manage Gitlab tags and branches"
  type        = string
}

variable "message" {
  description = "Default message of tags or branches"
  type        = string
  default     = ""
}

variable "protected" {
  description = "Default protection of tags or branches"
  type = object({
    enabled             = bool
    create_access_level = string
  })
  default = {
    enabled             = false
    create_access_level = ""
  }
}
