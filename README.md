# Futureproof recruitment task

I've put together a project to deploy a simple application to the AWS cloud. 

The application is based on the serverless model, leveraging cloud-native architecture and keeping the costs minimal. 

Below is a diagram of the infrastructure, a description of the data flow, and the steps you need to take to make it work.

**Feel free to check other README files in [part1](part1) and [part2](part2) folders**
# Infrastructure Diagram

![aws diagram](https://github.com/xMaciekMx/futureproof-interview/blob/master/diagram.png?raw=true)

### How application update works (high level)
1. Freshly pushed commit is being detected by an AWS CodePipeline (via CloudWatch Events).
2. The application build process begins in the AWS CodeBuild.
3. New docker image is being built and then pushed to the AWS Elastic Container Registry
4. After 20 seconds AWS CodeBuilt finishes its job by updating the AWS Lambda application version.
### How the application works (high level)
1. Python is fetching a bitcoin price from coinmarketcap.com.
2. After a bit of data modification, the modified price and current date are inserted into the HTML template.
3. Modified template gets saved and then uploaded to the s3 bucket.

![application demo](https://github.com/xMaciekMx/futureproof-interview/blob/master/bitcoinprice.png?raw=true)
### How the application works (cloud backend)
AWS EventBridge rule is triggering a lambda function every one hour.

# Deployment guide
### Editing variables
1. Head to the `part1/locals.tf` file.
2. Change `ACCOUNT_ID` (**required**) and other values (**optional**)
### Prerequisites
1. AWS account with **administrative access** (iam resources are being created, so power user won't do).
2. Configured aws cli
## Deployment
1. `terraform apply -target module.part1`
2. Configure git
   1. `git remote add cloud (put "codecommit_url" output here)`
   2. `terraform output codecommit_service_user_name`
   3. `terraform output codecommit_service_password `
   4. `git push cloud `
   5. Enter credentials from previous steps 
   6. **Wait for a minute or two** for codepipeline to finish building and pushing a docker image
3. `terraform apply`
4. We can grab `s3website` output from terraform and test whether the app is working.
# What additional steps would prepare this app for production
### AWS 
- Better security
    - more complex IAM policies (conditions, calledvia)
    - resource policies (mainly for the s3 buckets)
- CloudFront implementation
    - Instead of AWS bucket website endpoint
    - Better security (ssl/tls)
    - Fewer GET requests on the s3 bucket
    - Smaller latencies for international users
### Terraform
- Consider implementing terraform pipeline (in AWS)
- Store terraform state in the private s3 bucket
- Uncomment some sections from the .tf files such as:
  - [part1/main.tf](part1/main.tf) s3-versioning
- Consider switching to cloudformation :))
