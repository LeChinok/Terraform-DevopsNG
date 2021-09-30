terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.60.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  access_key = var.access_key[0]
  secret_key = var.secret_key[0]
}

variable "access_key"{
    description = "AWS Acess key"
    
}
variable "secret_key"{
    description = "AWS Secret key"
    
}
# Create 1 instance
resource "aws_instance" "devopsng1"{
    ami = "ami-0b1deee75235aa4bb"
    instance_type = "t2.micro"
    availability_zone = "eu-central-1a"
    key_name          = "main-key"

}
