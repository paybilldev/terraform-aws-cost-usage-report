# Provisions Glue Crawler and Catalog Database.
# Crawler will, when run, populate the Catalog Database with a table representing the CUR data in S3.

resource "aws_glue_crawler" "this" {
  name          = "cur-crawler"
  database_name = aws_glue_catalog_database.cur.name
  role          = aws_iam_role.crawler.name

  s3_target {
    path = "s3://${var.s3_bucket_name}/${var.s3_bucket_prefix}/${var.report_name}/${var.report_name}"
  }

  tags = var.tags

  depends_on = [aws_s3_bucket.cur]
}

resource "aws_glue_catalog_database" "cur" {
  name        = "${var.report_name}-db"
  description = "Contains CUR data based on contents from the S3 bucket '${var.s3_bucket_name}'"
}

# Crawler role
resource "aws_iam_role" "crawler" {
  name_prefix        = "cur-crawler"
  assume_role_policy = data.aws_iam_policy_document.crawler_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "crawler" {
  role   = aws_iam_role.crawler.name
  policy = data.aws_iam_policy_document.crawler.json
}

# Optionally pre-create log group for Glue Crawlers.
# Crawlers share Log Group for whatever reason I do not know.
#
# Anyway, Crawlers will automatically create this Log Group
# with infinite retention, which is not desirable.
# This gives module consumers the option of letting this module create it/manage it.
#
# Accept default encryption. Crawler logs are not sensitive.
# #tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "crawler" {
  count = var.glue_crawler_create_log_group ? 1 : 0

  name              = local.glue_log_group_default_name
  retention_in_days = var.glue_crawler_log_group_retention_days
}