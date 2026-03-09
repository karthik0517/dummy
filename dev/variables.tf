variable "schemas" {
  description = "Schemas with dedicated ADLS storage containers and external locations."
  type        = list(string)

  # At least one storage-backed schema is always required.
  validation {
    condition     = length(var.schemas) > 0
    error_message = "schemas must contain at least one entry."
  }

  # Reject duplicate entries — list(string) preserves duplicates so we can detect them.
  validation {
    condition     = length(var.schemas) == length(distinct(var.schemas))
    error_message = "schemas must not contain duplicate entries."
  }

  # Enforce lowercase_with_underscores naming convention (e.g. bronze_jde, silver_common).
  # Each segment must start with a letter; at least one underscore is required.
  validation {
    condition     = alltrue([for s in var.schemas : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", s))])
    error_message = "Each schema name must be lowercase alphanumeric with at least one underscore (e.g. bronze_jde)."
  }
}

variable "managed_schemas" {
  description = "Schemas without dedicated storage — UC uses the catalog's default storage root."
  type        = set(string)
  default     = []

  # Same naming convention as schemas — lowercase_with_underscores.
  validation {
    condition     = alltrue([for s in var.managed_schemas : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", s))])
    error_message = "Each managed schema name must be lowercase alphanumeric with at least one underscore (e.g. silver_common)."
  }
}

variable "volumes" {
  description = "Unity Catalog volumes. Key becomes the volume name after stripping the schema prefix."
  type = map(object({
    schema       = string
    type         = string
    storage_path = optional(string)
    comment      = optional(string)
  }))
  default = {}

  # Volume keys must be lowercase_with_underscores, same convention as schema names.
  validation {
    condition     = alltrue([for k, v in var.volumes : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", k))])
    error_message = "Volume keys must be lowercase alphanumeric with at least one underscore (e.g. copper_profitool_raw_files)."
  }

  # Each volume's schema must follow the naming convention.
  validation {
    condition     = alltrue([for v in var.volumes : can(regex("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)+$", v.schema))])
    error_message = "Volume schema must be lowercase alphanumeric with at least one underscore (e.g. copper_profitool)."
  }

  # Volume key must start with its schema name so the prefix-stripping logic works.
  validation {
    condition     = alltrue([for k, v in var.volumes : startswith(k, "${v.schema}_")])
    error_message = "Volume key must start with its schema name followed by an underscore (e.g. copper_profitool_raw_files for schema copper_profitool)."
  }

  # type must be MANAGED or EXTERNAL.
  validation {
    condition     = alltrue([for v in var.volumes : contains(["MANAGED", "EXTERNAL"], v.type)])
    error_message = "Volume type must be MANAGED or EXTERNAL."
  }

  # EXTERNAL volumes must specify a storage_path.
  validation {
    condition     = alltrue([for v in var.volumes : v.type == "MANAGED" || v.storage_path != null])
    error_message = "EXTERNAL volumes must include a storage_path (e.g. \"landing\")."
  }
}
