/*this terraform file would build the infrastructure for my personal website via ec2 webservers
although this file is not currently used in production
*/

variable "bucket" {
  description = "name of bucket to retrieve html files"
}

terraform {
  required_version = ">= 0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/*s3 bucket for web servers to pull from*/
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket
  acl = "private"
}

/*insert website html files into bucket*/
resource "aws_s3_bucket_object" "html" {
  bucket = var.bucket
  key    = "html"
  source = "./app/PW.html"
}

/*launch config for ec2 webservers*/
resource "aws_launch_configuration" "lc1" {
  image_id        = "ami-40d28157"
  instance_type   = "t2.micro"
  security_groups = ["aws_security_group.security_group_1.id"]

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install httpd -y
            sudo service httpd start
            sudo chkconfig httpd on
            aws s3 cp ${var.bucket} /var/www/html/ --recursive
            hostname -f >> /var/www/html/index.html
            EOF

  lifecycle {
    create_before_destroy = true
  }
}

/*autoscaling policy, commands autoscaling whenever pod reaches over 80% CPU usage*/
resource "aws_autoscaling_policy" "ag1-policy" {
  name = "ag1-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.ag1.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }

/*server demand autoscaling*/
resource "aws_autoscaling_group" "ag1"{
    name = "ag1"
    launch_configuration = "aws_launch_configuration.lc1.id"
    availability_zones = ["us-east-1"]
    min_size = 1
    max_size = 3
    desired_capacity = 2

    tag {
        key = "Name"
        value = "terraform-ec2-instance"
        propagate_at_launch = true
    }
}








