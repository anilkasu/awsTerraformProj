#Create an ECS instance on the ASG

#Create a launch configuration to initiate the instances for ECS service
resource "aws_launch_configuration" "ecsLaunchConfig" {
    name = "ECSLanuchConfig"
    image_id = "ami-2149114e"
    user_data = <<-EOF
      #!/bin/bash
      echo ECS_CLUSTER="${aws_ecs_cluster.restAPICluster.name}" >> /etc/ecs/ecs.config
    EOF
    key_name = "myDockerKey"
    iam_instance_profile = "ECSRole4EC2"
    #iam_instance_profile = "ecsInstanceRole"
    security_groups = ["${var.privateSGID}"]
    instance_type = "t2.micro"
    #auto_assign_public_ips = true
}

#Create an ASG to deploy the container instances
resource "aws_autoscaling_group" "ecsASG" {
    name = "ecsClusterASG"
    launch_configuration = "${aws_launch_configuration.ecsLaunchConfig.name}"
    max_size = "4"
    min_size = "2"
    desired_capacity = "2"
    vpc_zone_identifier = ["${var.subnetPrivate1A}", "${var.subnetPrivate1B}"]
    health_check_type = "EC2"
    health_check_grace_period = "600"
    tags {
      key = "Name"
      value = "ecsASGMember"
      propagate_at_launch = true
    }
}

#create an autoscaling policy for the created ASG
resource "aws_autoscaling_policy" "ecsAutoScalingPolicy" {
    name = "ecsAutoScalingPolicy"
    autoscaling_group_name = "${aws_autoscaling_group.ecsASG.name}"
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50.0
  }
}
