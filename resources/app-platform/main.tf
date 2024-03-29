variable "certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "domain" {
  type = string
}

resource "aws_iam_instance_profile" "aws-elasticbeanstalk-ec2-profile" {
  name = "aws-elasticbeanstalk-ec2-profile"
  role = aws_iam_role.ec2-role.name

  depends_on = [
    aws_iam_role.ec2-role
  ]
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"
  path = "/"

  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_elastic_beanstalk_application" "edu-eb-application" {
  name        = "edu-eb-application"
  description = "Avalon Staging Reporting Public Beanstalk App"
}

resource "aws_elastic_beanstalk_environment" "edu-eb-environment" {
  name                = "edu-eb-environment"
  application         = aws_elastic_beanstalk_application.edu-eb-application.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.0 running Corretto 11"
  tier                = "WebServer"

  /**
    Networking
    **/
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value = join(
      ",",
      var.PUBLIC_SUBNET_IDS
    )
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value = join(
      ",",
      var.PUBLIC_SUBNET_IDS
    )
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = true
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name       = "Port"
    value      = "8080"
  }

  /**
    Launch configuration
    **/
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-profile"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.ACCESS_KEY_PAIR_NAME
  }

  /**
    EC Instances
    **/
  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t3.micro"
  }

  /**
    Capacity and scaling
    **/
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "Any 1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
  }

  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.certificate_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = "markokrizan64@gmail.com"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "/health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  depends_on = [
    aws_iam_instance_profile.aws-elasticbeanstalk-ec2-profile
  ]
}

data "aws_elastic_beanstalk_hosted_zone" "current" {}

resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = format("api.%s", var.domain)
  type    = "A"

  alias {
    name    = aws_elastic_beanstalk_environment.edu-eb-environment.cname
    zone_id = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

# TODO
# resource "aws_wafv2_web_acl_association" "public_environment_alb_rate_rule_association" {
#   resource_arn = aws_elastic_beanstalk_environment.public_environment.load_balancers[0]
#   web_acl_arn   = data.aws_wafv2_web_acl.main_avalon_waf_acl.arn
# }

# TODO
# resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
#     role = "${aws_iam_role.ec2_iam_role.name}"
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }
