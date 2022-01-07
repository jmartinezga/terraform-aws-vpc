terraform {
  backend "s3" {
    bucket = "terraform-backend-365101756910"
    region = "eu-west-1"
    key    = "eu-west-1/dev/helloworld/vpc"
  }
}
