# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name      = "${var.domain_name}-VPC"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name      = "${var.domain_name}-IGW"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name      = "${var.domain_name}-SNT"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "${var.domain_name}-elb"
  description = "Used in the ${var.domain_name} project"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name      = "${var.domain_name}-ELB"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "${var.domain_name}-SG"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name      = "${var.domain_name}-SG"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "${var.domain_name}-ELB"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags {
    Name      = "${var.domain_name}-ELB"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

# KeyPair for EC2 connection
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Userdata stored in a templater file
data "template_file" "web-userdata" {
  template = "${file("user_data.tpl")}"

  vars {
    aws_region = "${var.aws_region}"
  }
}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${var.ami_user}"

    # The connection will use the local SSH agent for authentication.
    key_file = "${var.public_key_path}"
    agent    = true
  }

  instance_type = "${var.instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # Attache Profile for SSMRunCommand (see SSM_Role.tf)
  iam_instance_profile = "${aws_iam_instance_profile.RunCommandRole_profile.id}"

  # Userdata for EC2 based on the template created
  user_data = "${data.template_file.web-userdata.rendered}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install nginx",
      "sudo service nginx start",
    ]
  }

  tags {
    Name      = "${var.domain_name}-EC2"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}
