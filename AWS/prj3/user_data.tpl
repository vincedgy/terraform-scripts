#!/bin/bash
sudo yum -y update
sudo yum -y install nginx
sudo service nginx start

cd /tmp

curl https://amazon-ssm-${aws_region}.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm
sudo start amazon-ssm-agent
sudo status amazon-ssm-agent