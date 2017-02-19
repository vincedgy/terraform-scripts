provider "aws" {
  # If commenter depends on ~/.aws/credentials (as AWS CLI configure)
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}
