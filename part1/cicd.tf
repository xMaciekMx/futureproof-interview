#ECR
resource "aws_ecr_repository" "ecr" {
  name                 = local.ECR_NAME
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }
}
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle" {
  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Expire third image",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "imageCountMoreThan",
          "countNumber" : 3
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
  repository = aws_ecr_repository.ecr.name
}
#CodeCommit
resource "aws_codecommit_repository" "code_repo" {
  repository_name = local.CODECOMMIT_REPO_NAME
}
#CodeBuild
resource "aws_codebuild_project" "codebuild_proj" {
  name           = local.CODEBUILD_PROJ_NAME
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role.code_build_service_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = local.ECR_NAME
    }
    environment_variable {
      name  = "IMAGE_REPO_URL"
      value = aws_ecr_repository.ecr.repository_url
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.ACCOUNT_ID
    }
    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = local.LAMBDA_FUNCTION_NAME
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.REGION
    }
  }


  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.code_repo.clone_url_http
    git_clone_depth = 1
  }
}
#CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "interview_code_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "Source-${aws_codecommit_repository.code_repo.repository_name}"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.code_repo.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build-App"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_proj.name
      }
    }
  }
}