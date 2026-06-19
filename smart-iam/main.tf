variable "scope" {
  description = "The scope to assign the role to"
  type        = string
}

variable "role_definition_name" {
  description = "The name of the role"
  type        = string
}

variable "principal" {
  description = "Map of the principal config. Contains a name and type"
  type = object({
    type = string
    name = string
  })
}
variable "description" {
  description = "Description to give the role assignment. Defaults to 'Assigned through Terraform'"
  type        = string
  default     = "Assigned through Terraform"
  nullable    = false
}

locals {
  type = lower(replace(var.principal.type, " ", "_"))
}

# Security Group
data "azuread_group" "sg" {
  count        = local.type == "security_group" ? 1 : 0
  display_name = var.principal.name
}

resource "azurerm_role_assignment" "sg_assignment" {
  count                = local.type == "security_group" ? 1 : 0
  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = data.azuread_group.sg[0].object_id
  description          = var.description
}

# Service Principal
data "azuread_service_principal" "sp" {
  count        = local.type == "service_principal" ? 1 : 0
  display_name = var.principal.name
}

resource "azurerm_role_assignment" "sp_assignment" {
  count                = local.type == "service_principal" ? 1 : 0
  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = data.azuread_service_principal.sp[0].object_id
  description          = var.description
}
