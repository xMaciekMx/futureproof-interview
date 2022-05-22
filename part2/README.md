# Part2 Terraform
This module creates the following resources:
## Application:
- Lambda function
- CloudWatch event rule
- CloudWatch event target
## Commands (executed locally):
- CodePipeline rerun - thanks to that, after deploying part2 infrastructure module, codebuild would successfully perform "POST_BUILD" stage (from its buildspec.yaml) which deploys freshly built to the lambda function.
- Lambda invocation - we don't have to wait for an hour for our first results
## IAM:
- lambda policy
- lambda role
- lambda resource-based policy which allows eventbridge to invoke the function