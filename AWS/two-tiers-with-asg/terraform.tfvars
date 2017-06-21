terragrunt = {
  # Configure Terragrunt to use DynamoDB for locking
  lock {
    backend = "dynamodb"

    config {
      state_file_id = "webinfra"
    }
  }

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"

    config {
      encrypt = "true"
      bucket  = "hsbcinnovation4-webinfra-terraform-state"
      key     = "terraform.tfstate"
      region  = "eu-west-1"
    }
  }
}
