resource "aws_elb" "cl_elb" {
	name		= "CL-lb"
	#subnets	= ["${aws_subnet.Subnet-Public-1B.id}", "${aws_subnet.Subnet-Public-1A.id}"]
	subnets	= ["${var.subnetPublic1B}", "${var.subnetPublic1A}"]
	#availability_zones	= ["${aws_subnet.Subnet-Public-1B.availability_zone}", "${aws_subnet.Subnet-Public-1A.availability_zone}"]
	listener	{
		instance_port	= "8090"
		lb_port		= "80"
		instance_protocol	= "HTTP"
		lb_protocol		= "HTTP"
	}
	cross_zone_load_balancing	= true
	#vpc_id				= "${aws_vpc.VPC-Auto.id}"
	security_groups			= ["${aws_security_group.elbSG.id}"]
	health_check {
		healthy_threshold	= 10
		unhealthy_threshold	= 2
		interval		= 30
		target			= "HTTP:8091/health"
		timeout			= 5
	}
}

resource "aws_security_group" "elbSG" {
	vpc_id		= "${var.vpc_id}"
	name		= "elb_secGroup"
	description	= "Allows traffic from internet to the load balancer"
	ingress {
		from_port	= 80
		to_port		= 80
		protocol	= "TCP"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		#cidr_blocks	= "10.1.0.0/22"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

output	"elb_dns_name" {
	value	= "${aws_elb.cl_elb.dns_name}"
}
