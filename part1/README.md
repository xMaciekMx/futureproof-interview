# Part1 Terraform
This module creates following resources:
## CICD:
- CodeCommit - code repository
- ElasticContainerRegistry - image repository (with lifecycle policy)
- CodePipeline - pipeline
- CodeBuild - project
## Other:
- S3 Bucket for website
- S3 Bucket for codepipeline
## IAM:
- codebuild serive-role
- codebuild policy
- codepipeline policy
- codecommit user
- codecommit poweruser policy attachment to created user
- codecommit git credentials

