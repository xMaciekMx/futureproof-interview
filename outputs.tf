#output "codepipeline_arn" {
#  value =  module.part1.codepipeline_arn
#}
#output "ecr_arn" {
#  value = module.part1.ecr_arn
#}
output "codecommit_url" {
  value = module.part1.codecommit_url
}
output "codecommit_service_user_name" {
  value     = module.part1.codecommit_service_user_name
  sensitive = true
}
output "codecommit_service_password" {
  value     = module.part1.codecommit_service_password
  sensitive = true
}
output "s3website" {
  value = module.part1.s3_website
}