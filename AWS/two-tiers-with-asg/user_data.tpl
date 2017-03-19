#!/bin/bash
sudo yum -y update
sudo yum -y install nginx
sudo service nginx start

cd /tmp

curl https://amazon-ssm-${aws_region}.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm
sudo start amazon-ssm-agent

# Retrieve metadatas for the current EC2 into a temp file
# And get web assets from S3 bucket
aws s3api get-object --bucket ${s3_bucket} --key "index.html" /tmp/index.html
cat /tmp/index.html | sed 's/\<\/body\>//' | sed 's/\<\/html\>//' > /tmp/index_t.html
mv /tmp/index_t.html /tmp/index.html
echo "<h2>AMI id is $(curl http://169.254.169.254/latest/meta-data/ami-id)</h2>" >> /tmp/index.html
echo "<h2>HOSTNAME id is $(curl http://169.254.169.254/latest/meta-data/local-hostname)</h2>" >> /tmp/index.html
echo "<h2>IP v4 id is $(curl http://169.254.169.254/latest/meta-data/public-ipv4)</h2>" >> /tmp/index.html
echo "</body></html>" >> /tmp/index.html

cp /tmp/index.html /usr/share/nginx/html/index.html 
