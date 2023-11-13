locals {
  buildspec_dir = var.buildspec_dir == null ? path.module : var.buildspec_dir

  buildspec              = var.project_build_spec ? null : "${local.buildspec_dir}/${var.data_store_type}-buildspec.yml"
  buildspec_verification = var.project_build_spec ? null : "${local.buildspec_dir}/${var.data_store_type}-buildspec-verification.yml"
}
