resource "aws_launch_configuration" "as_conf" {
	name 	= "ASG-LaunchConfig"
	instance_type	= "t2.micro"
	image_id	= "ami-ab055fc4"
	#image_id	= "ami-9f91caf0"
	security_groups	= ["${aws_security_group.privateSG.id}"]
	user_data	= <<-EOF
		#!/bin/bash
		export PATH="/usr/local/maven/bin:$PATH"
		export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.36.amzn1.x86_64"
		cd /home/ec2-user/spring-boot-rest-example
		mvn spring-boot:run -Drun.arguments="spring.profiles.active=test" &
		EOF
	key_name	= "myEC2VMs"
	}

resource "aws_autoscaling_policy" "as_policy" {
	name		= "asPolicy"
	#metric_type	= ""
	policy_type		= "TargetTrackingScaling"
	autoscaling_group_name	= "${aws_autoscaling_group.as_group.id}"
	#adjustment_type		= "PercentChangeInCapacity"
	target_tracking_configuration {
		predefined_metric_specification {
			predefined_metric_type = "ASGAverageCPUUtilization"
		}
		target_value	= 60
	}
}

resource "aws_autoscaling_group" "as_group" {
	name 			= "myASG"
	max_size		= 4
	min_size		= 2
	health_check_type	= "ELB"
	desired_capacity	= 2
	launch_configuration	= "${aws_launch_configuration.as_conf.name}"
	#availability_zones	= ["${aws_subnet.Subnet-Private-1A.id}", "${aws_subnet.Subnet-Private-1B.id}"]
	vpc_zone_identifier	= ["${aws_subnet.Subnet-Private-1A.id}", "${aws_subnet.Subnet-Private-1B.id}"]
	load_balancers		= ["${aws_elb.cl_elb.name}"]
	tag {
		key	= "Name"
		value	= "ASGMember"
		propagate_at_launch = true
	}
	health_check_grace_period	= 600
}
