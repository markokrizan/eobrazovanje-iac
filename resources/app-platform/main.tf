resource "aws_elastic_beanstalk_application" "edu_eb_application" {
    name = "edu_eb_application"
    description = "Avalon Staging Reporting Public Beanstalk App"
}

resource "aws_elastic_beanstalk_environment" "edu_eb_environment" {
    name = "edu_eb_environment"
    application = aws_elastic_beanstalk_application.edu_eb_application.name
    solution_stack_name = "Correto 17 running on 64bit Amazon Linux 2"
    tier = "WebServer"

    /**
    Networking
    **/
    setting { 
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = var.PUBLIC_SUBNET_ID
    }

    setting { 
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = var.PRIVATE_SUBNET_ID
    }

    /**
    Launch configuration
    **/
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = "aws-elasticbeanstalk-ec2-role"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "EC2KeyName"
        value = var.ACCESS_KEY_PAIR_NAME
    }

    /**
    EC Instances
    **/
    setting { 
        namespace = "aws:ec2:instances"
        name = "InstanceTypes"
        value = "t3.micro"
    }

    /**
    Capacity and scaling
    **/
    setting { 
        namespace = "aws:autoscaling:asg"
        name = "MaxSize"
        value = "1" 
    }

    setting { 
        namespace = "aws:autoscaling:asg"
        name = "MinSize"
        value = "1" 
    }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "Availability Zones"
        value = "Any 1" 
    }

    setting { 
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerType"
        value = "application"
    }

    setting {
        namespace = "aws:elbv2:listener:80"
        name      = "Protocol"
        value     = "HTTP"
    }

    // TODO
    # setting {
    #     namespace = "aws:elbv2:listener:443"
    #     name      = "Protocol"
    #     value     = "HTTPS"
    # }

    # setting {
    #     namespace = "aws:elbv2:listener:443"
    #     name      = "SSLCertificateArns"
    #     value     = var.SSL_CERTIFICATE_ARN
    # }

    setting {
        namespace = "aws:elasticbeanstalk:sns:topics"
        name = "Notification Endpoint"
        value = "markokrizan64@gmail.com"
    }

    setting {
        namespace = "aws:elasticbeanstalk:application"
        name = "Application Healthcheck URL"
        value = "/health"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckPath"
        value = "/health"
    }
}

# TODO
# resource "aws_wafv2_web_acl_association" "public_environment_alb_rate_rule_association" {
#   resource_arn = aws_elastic_beanstalk_environment.public_environment.load_balancers[0]
#   web_acl_arn   = data.aws_wafv2_web_acl.main_avalon_waf_acl.arn
# }