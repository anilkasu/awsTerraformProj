#this is JUMP box so that from this server other servers can be accessed which are in private subnets.
#
resource "aws_instance" "jump_box" {
	ami		= "ami-ab055fc4"
	instance_type	= "t2.micro"
	count		= 1
	#vpc_id		= "${aws_vpc.VPC-Auto.id}"
	subnet_id	= "${aws_subnet.Subnet-Public-1A.id}"
	associate_public_ip_address	= true
	security_groups	= ["${aws_security_group.publiSG.id}"]
	tags {
		Name	= "JUMP_BOX"
	}
	key_name	= "myEC2VMs"
	
}


