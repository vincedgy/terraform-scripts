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
resource "aws_subnet" "first-SNT" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags {
    Name      = "${var.domain_name}-SNT-1"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

resource "aws_subnet" "second-SNT" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags {
    Name      = "${var.domain_name}-SNT-2"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

resource "aws_subnet" "third-SNT" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = true

  tags {
    Name      = "${var.domain_name}-SNT-3"
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

resource "aws_elb" "web-elb" {
  name = "${var.domain_name}-ELB"

  # The same availability zone as our instances
  # availability_zones = ["${split(",", var.availability_zones)}"]

  subnets         = ["${aws_subnet.first-SNT.id}", "${aws_subnet.second-SNT.id}", "${aws_subnet.third-SNT.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  tags {
    Name      = "${var.domain_name}-ELB"
    Env       = "${var.env}"
    Author    = "${var.author}"
    Generator = "${var.generator}"
  }
}

resource "aws_autoscaling_group" "web-asg" {
  availability_zones  = ["${split(",", var.availability_zones)}"]
  name                = "${var.domain_name}-ASG"
  max_size            = "${var.asg_max}"
  min_size            = "${var.asg_min}"
  desired_capacity    = "${var.asg_desired}"
  force_delete        = true
  vpc_zone_identifier = ["${aws_subnet.first-SNT.id}", "${aws_subnet.second-SNT.id}", "${aws_subnet.third-SNT.id}"]

  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  /*
  initial_lifecycle_hook {
    name                 = "${var.domain_name}-${var.env}-Launching"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "Message": "${var.domain_name}-${var.env}-Launching"
}
EOF

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }
  */

  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "${var.domain_name}-web-asg"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Env"
    value               = "${var.env}"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Author"
    value               = "${var.author}"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Generator"
    value               = "${var.generator}"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "web-lc" {
  name          = "${var.domain_name}-LC"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # Connection and Key
  connection {
    # The default username for our AMI
    user = "${var.ami_user}"

    # The connection will use the local SSH agent for authentication.
    key_file = "${var.public_key_path}"
    agent    = true
  }

  key_name = "${var.key_name}"

  # Security group
  security_groups = ["${aws_security_group.default.id}"]

  # Attache Profile for SSMRunCommand (see SSM_Role.tf)
  iam_instance_profile = "${aws_iam_instance_profile.RunCommandRole_profile.id}"

  # Userdata for EC2 based on the template created
  user_data = "${data.template_file.web-userdata.rendered}"
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
