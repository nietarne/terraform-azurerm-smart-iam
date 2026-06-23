variable "role_assignments" {
  description = "List of role assignments"
  default     = []

  type = list(object({
    scope       = string
    role_name   = string
    description = optional(string)
    principal = object({
      type = string
      name = string
    })
  }))

  validation {
    condition = alltrue([
      for ra in var.role_assignments :
      contains(
        ["security_group", "service_principal"],
        lower(replace(ra.principal.type, " ", "_"))
      )
    ])
    error_message = "principal.type must be 'Security Group' or 'Service Principal'."
  }
}

locals {
  role_assignments_map = {
    for ra in var.role_assignments :
    "${ra.scope}__${ra.role_name}__${ra.principal.name}" => ra
  }
}

module "smart_iam" {
  source = "./smart-iam"

  for_each = local.role_assignments_map

  role_definition_name = each.value.role_name
  scope                = each.value.scope
  principal            = each.value.principal
  description          = each.value.description
}
