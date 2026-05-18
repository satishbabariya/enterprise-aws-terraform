resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "${var.org_name}-org-analyzer"
  type          = var.analyzer_type
  tags          = var.tags
}
