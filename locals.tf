locals {
  # This is defined by AWS.
  glue_log_group_default_name = "/aws-glue/crawlers"
}

locals {
  lambda_function_name = "${var.report_name}-crawler-trigger"
}

