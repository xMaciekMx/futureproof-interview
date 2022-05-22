#--
#S3
#--
resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.BUCKET_NAME
#  For Dev env purposes
  force_destroy = true
}
resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

#  We can uncomment this in PROD, but it'll make terraform destroy harder in the dev environments.
#resource "aws_s3_bucket_versioning" "s3_bucket" {
#  bucket = aws_s3_bucket.s3_bucket.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}

resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}/*"
            ]
        }
    ]
})
}
#--------------
#CodePipelineS3
#--------------
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.CODE_PIPELINE_BUCKET_NAME
  #  For Dev env purposes
  force_destroy = true
}
resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}
