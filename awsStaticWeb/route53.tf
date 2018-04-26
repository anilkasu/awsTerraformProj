#create a hosted zone for your domain
#Domain/hosted zone is already created manually. Zone Id will be provided to the rest of the resources ina a variable.
/*resource "aws_route53_zone" "r53Zone" {
    name = "anilkasu.co.in"
    tags {
      Name = "Hosting zone for my domain anilkasu.co.in"
    }
}
*/

#Zone id variable
variable "anilkasuZoneID" {
  default = "Z2QCGNQAY1Q3U6"
}
#Variable for DEV subdomain
variable "anilkasuDevZoneID" {
  default = "Z20CMUYEUUZXNH"
}

#CNAME entry for s3.anilkasu.co.in
resource "aws_route53_record" "s3urlrecord1" {
      #zone_id = "${aws_route53_zone.r53Zone.id}"
      zone_id = "${var.anilkasuZoneID}"
      name = "s3"
      type = "CNAME"
      ttl = "30"
      records = ["${aws_s3_bucket.bucket4web.website_endpoint}"]
}

#CNAME entry for www.s3.anilkasu.co.in
resource "aws_route53_record" "s3urlrecord2" {
      #zone_id = "${aws_route53_zone.r53Zone.id}"
      zone_id = "${var.anilkasuZoneID}"
      name = "www.s3"
      type = "CNAME"
      ttl = "30"
      records = ["${aws_s3_bucket.bucket4web.website_endpoint}"]
}

#CNAME entry for www.s3.anilkasu.co.in
resource "aws_route53_record" "cfRecord1" {
      #zone_id = "${aws_route53_zone.r53Zone.id}"
      zone_id = "${var.anilkasuZoneID}"
      name = "cfs3"
      type = "CNAME"
      ttl = "30"
      records = ["${aws_cloudfront_distribution.cfDistribution.domain_name}"]
}

#CNAME entry for www.s3.anilkasu.co.in
resource "aws_route53_record" "cfRecord2" {
      #zone_id = "${aws_route53_zone.r53Zone.id}"
      zone_id = "${var.anilkasuZoneID}"
      name = "www.cfs3"
      type = "CNAME"
      ttl = "30"
      records = ["${aws_cloudfront_distribution.cfDistribution.domain_name}"]
}
