variable "schemas" {
  description = "Schemas with dedicated ADLS storage containers and external locations."
  type        = list(string)

  validation {
    condition     = length(var.schemas) > 0
    error_message = "schemas must contain at least one entry."
  }

  validation {
    condition     = length(var.schemas) == length(distinct(var.schemas))
    error_message = "schemas must not contain duplicate entries."
  }

  validation {
    condition     = alltrue([for s in var.schemas : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", s))])
    error_message = "Each schema name must be lowercase alphanumeric with at least one underscore (e.g. bronze_jde)."
  }
}

variable "service_principals" {
  description = "Databricks service principals and their per-schema grants. Key = SP name, value = map of schema to privileges. USE_CATALOG is granted automatically. Display name is computed as sp_acco_dbx_{key}_{environment}."
  type        = map(map(list(string)))
  default     = {}

  validation {
    condition = alltrue([
      for sp_key, schemas in var.service_principals :
      alltrue([for schema, privs in schemas : length(privs) > 0])
    ])
    error_message = "Each schema entry must have at least one privilege."
  }
}

variable "managed_schemas" {
  description = "Schemas without dedicated storage — UC uses the catalog's default storage root."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.managed_schemas : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", s))])
    error_message = "Each managed schema name must be lowercase alphanumeric with at least one underscore (e.g. silver_common)."
  }
}
