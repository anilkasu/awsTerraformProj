#Creating the variable to hold the list of files to be copied to S3 bucket
variable "fileList"{
  type = "string"
  default = "/Users/anilkasu/Downloads/StaticWebsite"
}

#This is for copying the entire static website folder to s3 bucket
data "template_file" "filesCopy" {
  template = <<-EOF
  aws s3 cp "${var.fileList}" "s3://${aws_s3_bucket.bucket4web.id}" --recursive
  EOF
}

#Make sure that you have the aws cli installed locally and can execute aws commands with out setting the environment variables
resource "null_resource" "s3filesCopy" {
  provisioner "local-exec" {
    command = "${data.template_file.filesCopy.rendered}"
  }
}


#Bucket creation for storing the S3 logfiles
resource "aws_s3_bucket" "bucket4logs" {
    bucket = "anilkasu-tflog"
    acl = "log-delivery-write"
    tags {
      Name = "TFLogsBucket"
    }
}

#Bucket creation for hosting a static web server
resource "aws_s3_bucket" "bucket4web" {
  bucket = "anikasu-tfstaticweb"

  tags {
    Name = "TFStaticWebsite"
  }

  website {
    index_document = "index.html"
    error_document = "error/index.html"
  }

  logging {
    target_bucket = "${aws_s3_bucket.bucket4logs.id}"
    target_prefix = "TFStaticWeb"
  }
}

/*
#This code snippet can only copy one file. Files are copied recursively using aws cli command
#copy the static website files into the bucket
resource "aws_s3_bucket_object" "s3Objects" {
    #count = "${length(var.fileList)}"
    bucket = "${aws_s3_bucket.bucket4web.id}"
    key = "index.html"
    source = "/Users/anilkasu/Downloads/StaticWebsite/index.html"
}
*/


resource "aws_s3_bucket_policy" "s3Policy" {
    bucket = "${aws_s3_bucket.bucket4web.id}"
    policy =<<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AddPerm",
              "Effect": "Allow",
              "Principal": "*",
              "Action": "s3:GetObject",
              "Resource": "${aws_s3_bucket.bucket4web.arn}/*"
          },
          {
              "Sid": "AddPermtoCF",
              "Effect": "Allow",
              "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.cfAccessID.iam_arn}"
              },
              "Action": "s3:GetObject",
              "Resource": "${aws_s3_bucket.bucket4web.arn}/*"
          }
      ]
    }
    POLICY
}

#"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3B3AYR3IFW0H7"
