# ==============================================================================
# RDS Parameter Group
# ==============================================================================

resource "aws_db_parameter_group" "rds" {
  count = var.create_parameter_group ? 1 : 0

  name        = local.parameter_group_name
  family      = var.parameter_group_family != null ? var.parameter_group_family : local.resolved_pg_family
  description = "Parameter group for ${local.db_identifier}"

  # Dynamic parameter blocks
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.common_tags, {
    Name    = local.parameter_group_name
    Purpose = "RDS Parameter Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Option Group (MySQL/MariaDB only)
# ==============================================================================

resource "aws_db_option_group" "rds" {
  count = var.create_option_group && contains(["mysql", "mariadb"], var.engine) ? 1 : 0

  name                     = "${local.name_prefix}-rds-og"
  option_group_description = "Option group for ${local.db_identifier}"
  engine_name              = var.engine
  major_engine_version     = split(".", var.engine_version)[0]

  dynamic "option" {
    for_each = var.option_group_options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-rds-og"
    Purpose = "RDS Option Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}