resource "oci_logging_log_group" "redis_log_group" {

  compartment_id = var.compartment_ocid
  display_name = "Redis Log Group"
}

resource "oci_logging_log" "redis_log" {

  display_name = "Redis Logs"

  is_enabled         = true
  log_group_id       = oci_logging_log_group.redis_log_group.id
  log_type           = "CUSTOM"
  retention_duration = "30"
}

resource "oci_logging_unified_agent_configuration" "redis_log_agent_config" {

  compartment_id = var.compartment_ocid

  description  = "Log Agent configuration for Redis nodes"
  display_name = "redis-log-agent-config"

  group_association {
    group_list = [
      oci_identity_dynamic_group.redis_dynamic_group.id
    ]
  }

  is_enabled = true

  service_configuration {

    configuration_type = "LOGGING"

    destination {
      log_object_id = oci_logging_log.redis_log.id
    }

    sources {

      name = "redis_server"

      parser {

        parser_type = "REGEXP"        
        expression  = "^(?<pid>\\d+):(?<role>[XCSM]) (?<time>[^\\]]*) (?<level>[\\.\\-\\*\\#]) (?<message>.+)$"
        time_format = "%d %B %Y %H:%M:%S.%L"
      }

      paths = [
        "/tmp/redis-server.log"
      ]

      source_type = "LOG_TAIL"
    }
  }
}