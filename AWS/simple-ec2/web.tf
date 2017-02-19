resource "aws_instance" "web" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = "${var.subnet_id}"
}

output "ip" {
  value = "${aws_instance.web.public_ip}"
}
