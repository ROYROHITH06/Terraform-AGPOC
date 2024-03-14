data "aws_acm_certificate" "mangoapp_cert" {
  domain   = "vipinktxing.in"
  statuses = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]  #PRIVATE, IMPORTED
}

module "lb" {
  source  = "../../../modules/alb"

  name    = "mangoapps-internal-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  security_groups    = [module.alb_security_group.security_group_id]
  internal = true 
  ip_address_type = "ipv4" 
  load_balancer_type = "application"
  enable_deletion_protection = false

  listeners = {
    redirect-http-https = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https5223 = {
      port            = 5223
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.mangoapp_cert.arn
      forward = {
        target_group_key = "server5223"
      }
    }

    https443 = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.mangoapp_cert.arn
      forward = {
        target_group_key = "server443"
      }

      #listner rules
      rules = {
        #rules for sync
        forward-sync = {
          priority = 1
          actions = [
            {
              type             = "forward"
              target_group_key = "server9001"
            }
          ]
          conditions = [{
            path_pattern = {
              values = ["/mangoappssync*", "/folderSyncList*", "/fpu*", "/fileAccess*"]
            }
          }]
        }

        #rules for api
        forward-solr = {
          priority = 2
          actions = [
            {
              type             = "forward"
              target_group_key = "server8080"
            }
          ]
          conditions = [{
            path_pattern = {
              values = ["/api/solr*"]
            }
          }]
        }
      
        #Rules for media
        forward-media = {
          priority = 3
          actions = [
            {
              type             = "forward"
              target_group_key = "server8080"
            }
          ]
          conditions = [{
            path_pattern = {
              values = ["/mjanus**", "/zip*", "/v2/media*", "/media*", "/dl*"]
            }
          }]
        }

        #Rule for cjs
        forward-api = {
          priority = 4
          actions = [
            {
              type             = "forward"
              target_group_key = "server9000"
            }
          ]
          conditions = [{
            path_pattern = {
              values = ["/cjs*"]
            }
          }]
        }  
      }   
    }
  }

  #### Create Target Groups ####
  target_groups = {
######### Target group for "MaUsTGAppServer443" ###########     
    server443 = {
      name                              = "MaUsTGAppServer443"
      protocol                          = "HTTPS"
      protocol_version = "HTTP1"
      port                              = 443
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_algorithm_type     = "round_robin"
      # load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration" #false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = 443 #"traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200-399"
      }

      # target_id        = aws_instance.this.id
    }

######### Target group for "MaUsTGMsgServer5223" ###########  
    server5223 = {
      name                              = "MaUsTGMsgServer5223"
      protocol                          = "HTTPS"
      protocol_version                  = "HTTP1"
      port                              = 5223
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_algorithm_type     = "round_robin"
      # load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration" #false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = 443 #"traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
      
      # target_id        = "${module.ec2_instance_target.id}"
    }

######### Target group for "MaUsTGBgServer8080" ###########  
    server8080 = {
      name                              = "MaUsTGBgServer8080"
      protocol                          = "HTTP"
      protocol_version                  = "HTTP1"
      port                              = 8080
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_algorithm_type     = "round_robin"
      # load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration" #false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = 443 #"traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
      
      # target_id        = "${module.ec2_instance_target.id}"

    }

    ######### Target group for "MaUsTGBgServer9000" ###########  
    server9000 = {
      name                              = "MaUsTGBgServer9000"
      protocol                          = "HTTP"
      protocol_version                  = "HTTP1"
      port                              = 9000
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_algorithm_type     = "round_robin"
      # load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration" #false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = 443 #"traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
      
      # target_id        = "${module.ec2_instance_target.id}"
    }

    ######### Target group for "MaUsTGBgServer9001" ###########  
    server9001 = {
      name                              = "MaUsTGBgServer9001"
      protocol                          = "HTTP"
      protocol_version                  = "HTTP1"
      port                              = 9001
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_algorithm_type     = "round_robin"
      # load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration" #false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = 443 #"traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
      
      # target_id        = "${module.ec2_instance_target.id}"
    }    

  }

  additional_target_group_attachments = {
    ex-instance-other = {
      target_group_key = "server5223"
      target_type      = "instance"
      target_id        = module.ec2_instance_target.id
      port             = "5223"
    }
 
    ex-instance-other = {
      target_group_key = "server8080"
      target_type      = "instance"
      target_id        = module.ec2_instance_target.id
      port             = "8080"
    }
  }
}


########################
#ec2 module for target

module "ec2_instance_target" {
  source  = "../../../modules/ec2"

  name = "single-instance"

  instance_type          = "t2.micro"
  key_name               = "user1"
  vpc_security_group_ids = [module.bastion_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]
}


##############################################
#ASG###
# ASG with block device mapping
module "asg" {
  source = "../../../modules/asg"

  name = "${var.client_name}-${var.environment}-asg"

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_size
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  # Launch template
  launch_template_name        = "${var.client_name}-${var.environment}-asg-Launch-template"
  launch_template_description = "Launch template for ${var.client_name} ${var.environment} environment"

  key_name        = var.asg_key_name
  security_groups = [module.bastion_security_group.security_group_id]

  image_id          = var.asg_ami_id
  instance_type     = var.asg_instance_type
  ebs_optimized     = var.asg_instance_ebs_optimized
  enable_monitoring = var.enable_asg_monitoring
  target_group_arns         = [module.lb.target_groups.server443.arn]

  # IAM role & instance profile
  create_iam_instance_profile = var.create_asg_iam_instance_profile
  iam_role_name               = "${var.client_name}-${var.environment}-asg-instance-role"
  iam_role_description        = "IAM role for asg instance profile in ${var.client_name} ${var.environment} environment"

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = var.asg_volume_mapping

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Created_by  = "Terraform"
    Client      = var.client_name
    Environment = var.environment
  }
}


variable "enable_redirect" {
  type = bool
  default = false
}
