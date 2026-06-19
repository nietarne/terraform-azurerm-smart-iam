# Smart IAM
Role assignments using `azurerm` are not really reader friendly, all the
principal ID's can get mixed up pretty quickly. This module prevents that.

Define roles for **Security Groups** and **Service Principals** easily using
their names instead of the ID's.

## Configuration

This module takes in a list of objects. The objects have the following
properties:

- `role_name`: name of the role
- `scope`: resource_id of the Azure resource to apply this role to
- `principal`: object with a type and name

`principal` object:

- `type`: either `security_group` or `service_principal`
- `name`: the display name of the security group or service principal

> The principal type can also be configured like "Security Group", the strings
> get converted to lowercase and spaces get replaced with `_`

### Configure in `.tf`
```terraform
module "smart_iam" {
  source = "git::https://codeberg.org/nietarne/terraform-azure-smart-iam"
  # if you want to pin a version / commit: add "?rev={tag or commit sha-1}"

  role_assignments = [
    {
      role_name = "Role name"
      scope     = "Resource ID"
      principal = {
        type = "Service Principal | Security Group"
        name = "name of SP / SG"
      }
    }
  ]
}
```

### Configure in `.tfvars`
Add the following variable into your terraform configuration:
```terraform
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
      contains(["Security Group", "Service Principal"], ra.principal.type)
    ])
    error_message = "principal.type must be 'Security Group' or 'Service Principal'."
  }
}
```

or if you want to keep it simple:

```terraform
variable "role_assignments" {
  description = "List of role assignments"
  default     = []
}
```

Add the module:
```terraform
module "smart_iam" {
  source = "git::https://codeberg.org/nietarne/terraform-azure-smart-iam"
  # if you want to pin a version / commit: add "?rev={tag or commit sha-1}"

  role_assignments = var.role_assignments
}
```
