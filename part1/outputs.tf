#----------
#CodeCommit
#----------
output "codecommit_url" {
  value = aws_codecommit_repository.code_repo.clone_url_http
}
output "codecommit_service_user_name" {
  value     = aws_iam_service_specific_credential.iam_codecommit_git_credentials.service_user_name
  sensitive = true
}
output "codecommit_service_password" {
  value     = aws_iam_service_specific_credential.iam_codecommit_git_credentials.service_password
  sensitive = true
}
#------------
#PART2 THINGS
#------------
output "codepipeline_name" {
  value = aws_codepipeline.codepipeline.name
}
output "ecr_arn" {
  value = aws_ecr_repository.ecr.arn
}
output "ecr_image_uri" {
  value = "${aws_ecr_repository.ecr.repository_url}:latest"
}
output "website_bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}
output "lambda_function_name" {
  value = local.LAMBDA_FUNCTION_NAME
}
output "account_id" {
  value = local.ACCOUNT_ID
}
output "region" {
  value = local.REGION
}
#------------
#Useful stuff
#------------
output "s3_website" {
  value = "http://${local.BUCKET_NAME}.s3-website.${local.REGION}.amazonaws.com"
}
