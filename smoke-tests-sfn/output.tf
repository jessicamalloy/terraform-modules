output "arn" {
    value = aws_sfn_state_machine.state_machine.arn
}

output "lambda_bucket" {
    value = aws_s3_bucket.lambdas_bucket.bucket
}

output "lambda_bucket_arn" {
    value = aws_s3_bucket.lambdas_bucket.arn
}

output "function_names" {
    value = aws_lambda_function.lambda_function[*].function_name
}
