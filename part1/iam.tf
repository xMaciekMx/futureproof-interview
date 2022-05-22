#CodeCommit
resource "aws_iam_user" "codecommit_poweruser" {
  name = "codecommit_poweruser"
}
resource "aws_iam_policy_attachment" "attach_codecommit_poweruser" {
  name       = "attach_codecommit_poweruser"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
  users      = [aws_iam_user.codecommit_poweruser.name]
}
resource "aws_iam_service_specific_credential" "iam_codecommit_git_credentials" {
  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.codecommit_poweruser.name
}

## CodeBuild
resource "aws_iam_role" "code_build_service_role" {
  name               = "code_build_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "code_build_policy" {
  role   = aws_iam_role.code_build_service_role.id
  policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "codecommit:GitPull",
          "ecr:UploadLayerPart",
          "s3:GetBucketAcl",
          "logs:CreateLogGroup",
          "ecr:PutImage",
          "s3:PutObject",
          "s3:GetObject",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "codebuild:UpdateReport",
          "ecr:CompleteLayerUpload",
          "codebuild:BatchPutCodeCoverages",
          "ecr:InitiateLayerUpload",
          "s3:GetBucketLocation",
          "codebuild:BatchPutTestCases",
          "ecr:BatchCheckLayerAvailability",
          "s3:GetObjectVersion",
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "lambda:GetFunctionUrlConfig"
        ],
        "Resource" : [
          "${aws_ecr_repository.ecr.arn}",
          "arn:aws:logs:${local.REGION}:${local.ACCOUNT_ID}:log-group:*",
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*",
          "arn:aws:codebuild:${local.REGION}:${local.ACCOUNT_ID}:report-group/interview-*",
          "${aws_codecommit_repository.code_repo.arn}",
          "arn:aws:lambda:${local.REGION}:${local.ACCOUNT_ID}:function:${local.LAMBDA_FUNCTION_NAME}"
        ]
      },
      {
        "Sid" : "2",
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      }
    ]

  })
}
#CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  name = "codepipeline_role"
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  role   = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "codecommit:GetApprovalRuleTemplate",
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "codecommit:GetTree",
          "codecommit:GetBlob",
          "codecommit:GetReferences",
          "codecommit:DescribeMergeConflicts",
          "codecommit:GetPullRequestApprovalStates",
          "codebuild:BatchGetBuilds",
          "codecommit:BatchDescribeMergeConflicts",
          "codecommit:GetCommentsForComparedCommit",
          "codecommit:GetCommentReactions",
          "codecommit:GetCommit",
          "codecommit:GetComment",
          "codecommit:GetCommitHistory",
          "codecommit:GetCommitsFromMergeBase",
          "codecommit:BatchGetCommits",
          "codecommit:DescribePullRequestEvents",
          "codecommit:GetPullRequest",
          "s3:PutObjectAcl",
          "codecommit:UploadArchive",
          "codecommit:GetPullRequestOverrideState",
          "codecommit:GetRepositoryTriggers",
          "codecommit:BatchGetRepositories",
          "codecommit:GitPull",
          "codecommit:GetCommentsForPullRequest",
          "s3:GetBucketVersioning",
          "codecommit:CancelUploadArchive",
          "codecommit:GetObjectIdentifier",
          "codecommit:GetFolder",
          "codecommit:BatchGetPullRequests",
          "codecommit:GetFile",
          "s3:PutObject",
          "s3:GetObject",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:EvaluatePullRequestApprovalRules",
          "codecommit:GetDifferences",
          "codecommit:GetRepository",
          "codecommit:GetBranch",
          "codecommit:GetMergeConflicts",
          "codecommit:GetMergeCommit",
          "codebuild:StartBuild",
          "codecommit:GetMergeOptions",
          "s3:GetObjectVersion"
        ],
        "Resource" : [
          "arn:aws:codebuild:${local.REGION}:${local.ACCOUNT_ID}:project/${aws_codebuild_project.codebuild_proj.name}",
          "arn:aws:codecommit:${local.REGION}:${local.ACCOUNT_ID}:${aws_codecommit_repository.code_repo.repository_name}",
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      }
    ]
  })
}
