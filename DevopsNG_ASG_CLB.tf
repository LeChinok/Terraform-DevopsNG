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
variable "server_port"{
    description = "AWS Server_port"

}


#Create launch configuration

resource "aws_launch_configuration" "DevopsNG_Config" {
  image_id        = "ami-0b1deee75235aa4bb"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.elb_sec_grp.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

#data source for Ava zones

data "aws_availability_zones" "all"{

}

# Create auto scaling group
resource "aws_autoscaling_group" "DevopsNG_ASG" {
  launch_configuration = aws_launch_configuration.DevopsNG_Config.id
  availability_zones = data.aws_availability_zones.all.names



  min_size = 2
  max_size = 6
  tag {
    key                 = "DevopsNG"
    value               = "terraform-asg-DevopsNG"
    propagate_at_launch = true
  }
}


# Create Elastic Load Balancer (Classic)

resource "aws_elb" "Devops_lb" {
name           = "terraform-asg-DevopsNG"
availability_zones = data.aws_availability_zones.all.names
security_groups    = [aws_security_group.elb_sec_grp.id]
listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "elb_sec_grp" {
  name = "terraform-elb-DevopsNG"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "clb_dns_name" {
  value       = aws_elb.Devops_lb.dns_name
  description = "The domain name of the load balancer"
}

