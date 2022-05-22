resource "aws_lambda_function" "test_lambda" {
  function_name = var.LAMBDA_FUNCTION_NAME
  role          = aws_iam_role.lambda_role.arn
  package_type = "Image"
  image_uri = var.ECR_IMAGE_URI
  timeout = 6
  environment {
    variables = {
      BUCKET_NAME = var.WEBSITE_BUCKET_NAME
    }
  }
}
resource "aws_cloudwatch_event_target" "lambda_target" {
  arn  = aws_lambda_function.test_lambda.arn
  rule = aws_cloudwatch_event_rule.cloudbridge_scheduled_lambda_rule.id
}
resource "aws_cloudwatch_event_rule" "cloudbridge_scheduled_lambda_rule" {
    schedule_expression = "rate(1 hour)"
}
resource "null_resource" "rerun_codebuild" {
  provisioner "local-exec" {
    command = "aws codepipeline start-pipeline-execution --name ${var.CODEPIPELINE_NAME}"
  }
  depends_on = [aws_lambda_function.test_lambda]
}
resource "null_resource" "invoke_lambda" {
  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${var.LAMBDA_FUNCTION_NAME} --invocation-type Event lambda_invocation_response.json"
  }
  depends_on = [aws_lambda_function.test_lambda]
}