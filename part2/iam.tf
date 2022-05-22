resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:region:${var.ACCOUNT_ID}:*"
      },
      {
        "Sid" : "lambdaPolicy",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:${var.REGION}:${var.ACCOUNT_ID}:log-group:/aws/lambda/${var.LAMBDA_FUNCTION_NAME}:*",
          "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/index.html"
        ]
      }
    ]
  })
}
resource "aws_iam_role" "lambda_role" {
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.REGION}:${var.ACCOUNT_ID}:rule/${aws_cloudwatch_event_rule.cloudbridge_scheduled_lambda_rule.name}"
#  qualifier     = aws_lambda_alias.test_alias.name
}