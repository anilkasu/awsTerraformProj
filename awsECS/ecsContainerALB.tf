#create a target group for the load balancer
resource "aws_alb_target_group" "ecsALBTargetGroup" {
    name = "ecsALBTargetGroup"
    port = "8090"
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"

    tags {
      Name = "ecsALBGroup"
    }
    health_check {
      port = "8091"
      protocol = "HTTP"
      path = "/health"
    }
}

#Create a application load balancer for the ECS containers
resource "aws_alb" "ecsALB" {
    name = "ecsALB"
    load_balancer_type = "application"
    internal = false
    security_groups = ["${var.albSGID}"]
    subnets = ["${var.subnetPublic1A}", "${var.subnetPublic1B}"]
    enable_cross_zone_load_balancing = true
    tags {
      key = "Name"
      value = "ecsALBName"
    }
}

#Associate the ALB abd albTarget group with each other
resource "aws_alb_listener" "ecsALBListner" {
    load_balancer_arn = "${aws_alb.ecsALB.arn}"
    port = "80"
    protocol = "HTTP"
    default_action {
      target_group_arn = "${aws_alb_target_group.ecsALBTargetGroup.arn}"
      type = "forward"
    }
}
