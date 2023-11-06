terraform {
  backend "s3" {
    bucket = "swamy-mrcloudchallenger1047"
    key = "vpc/terraform.tfstate"
    region = "ap-southeast-1"    
  }
}