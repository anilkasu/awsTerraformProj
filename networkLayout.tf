provider "aws" {
	region = "ap-south-1"
}

resource "aws_vpc" "VPC-Auto" {
	cidr_block="10.1.0.0/22"
	tags {
		Name = "VPC-With-TF"
	}
}

resource "aws_subnet" "Subnet-Public-1A" {
	#count		= 1
	vpc_id 		= "${aws_vpc.VPC-Auto.id}"
	cidr_block	= "10.1.0.0/24"
	availability_zone	= "ap-south-1a"
	tags {
		Name = "AutoProvision-Public-1A"
	}
}

resource "aws_subnet" "Subnet-Public-1B" {
        #count           = 1
        vpc_id          = "${aws_vpc.VPC-Auto.id}"
        cidr_block      = "10.1.1.0/24"
        availability_zone            = "ap-south-1b"
	tags {
		Name = "AutoProvision-Public-1B"
	}
}

resource "aws_subnet" "Subnet-Private-1A" {
        #count           = 1
        vpc_id          = "${aws_vpc.VPC-Auto.id}"
        cidr_block      = "10.1.2.0/24"
        availability_zone            = "ap-south-1a"
	tags {
		Name = "AutoProvision-Private-1A"
	}
}

resource "aws_subnet" "Subnet-Private-1B" {
        #count           = 1
        vpc_id          = "${aws_vpc.VPC-Auto.id}"
        cidr_block      = "10.1.3.0/24"
        availability_zone            = "ap-south-1b"
	tags {
		Name = "AutoProvision-Private-1B"
	}
}

output "vpc_id" {
	value	= "${aws_vpc.VPC-Auto.id}"
}

resource "aws_route_table" "RT_Public" {
	vpc_id		= "${aws_vpc.VPC-Auto.id}"
	route {
		cidr_block 	= "0.0.0.0/0"
		gateway_id	= "${aws_internet_gateway.IGateWay.id}"
	}
	tags {
		Name = "PublicRT"
	}
}

resource "aws_route_table" "RT_Private" {
	vpc_id	= "${aws_vpc.VPC-Auto.id}"
/*	route {
		nat_gateway_id	= "${aws_nat_gateway.NATGWay.id}"
	}
*/
	tags {
		Name 	= "PrivateRT"
	}
}

resource "aws_route_table_association" "RTAcc-Public-1A" {
	subnet_id	= "${aws_subnet.Subnet-Public-1A.id}"
	route_table_id	= "${aws_route_table.RT_Public.id}"
}

resource "aws_route_table_association" "RTAcc-Private-1B" {
        subnet_id       = "${aws_subnet.Subnet-Private-1B.id}"
        route_table_id  = "${aws_route_table.RT_Private.id}"
}

resource "aws_route_table_association" "RTAcc-Public-1B" {
        subnet_id       = "${aws_subnet.Subnet-Public-1B.id}"
        route_table_id  = "${aws_route_table.RT_Public.id}"
}

resource "aws_route_table_association" "RTAcc-Private-1A" {
        subnet_id       = "${aws_subnet.Subnet-Private-1A.id}"
        route_table_id  = "${aws_route_table.RT_Private.id}"
}

resource "aws_internet_gateway" "IGateWay" {
	vpc_id	= "${aws_vpc.VPC-Auto.id}"
	tags {
		Name	= "InternetGateWay"
	}	
}


/*
resource "aws_eip" "NAT1A" {
	vpc	= true
	
}
resource "aws_nat_gateway" "EIP-1A" {
	subnet_id	= "${aws_subnet.Subnet-Private-1A.id}"
	allocation_id	= "{aws_eip.NAT1A.id}"
}
*/

resource "aws_security_group" "publiSG" {
	name 		= "SG-Public"
	description	= "Allows traffic from internet for webservers"
	vpc_id		= "${aws_vpc.VPC-Auto.id}"
	ingress {
		from_port	= 22
		to_port		= 22
		protocol	= "TCP"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	
	ingress	{
		from_port	= 8090
		to_port		= 8091
		protocol	= "TCP"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	egress	{
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "privateSG" {
	name		= "SG-Private"
	description	= "Allows traffic from the VPC only, not from out side network"
	vpc_id		= "${aws_vpc.VPC-Auto.id}"
	ingress	{
		from_port	= 22
		to_port		= 22
		protocol	= "TCP"
		cidr_blocks	= ["${aws_vpc.VPC-Auto.cidr_block}"]
	}
	ingress {
		from_port	= 8090
		to_port		= 8091
		protocol	= "TCP"
		cidr_blocks	= ["${aws_vpc.VPC-Auto.cidr_block}"]
	}
	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}
