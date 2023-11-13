locals {
  buildspec              = var.project_build_spec ? null : "${path.module}/${var.data_store_type}-buildspec.yml"
  buildspec_verification = var.project_build_spec ? null : "${path.module}/${var.data_store_type}-buildspec-verification.yml"
}
