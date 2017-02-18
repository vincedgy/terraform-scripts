# Create an IAM role for the Web Servers.	

resource "aws_iam_role" "RunCommandRole" {
  name = "RunCommandRole"

  assume_role_policy = <<EOF
{		  
    "Version": "2012-10-17",		  
    "Statement": 
    [		    
        {		      
            "Action": "sts:AssumeRole",		      
            "Principal": {		        
                "Service": "ec2.amazonaws.com"		      
                },		      
            "Effect": "Allow",		      
            "Sid": ""		    
            }		  
        ]		
}
EOF
}

resource "aws_iam_policy_attachment" "RunCommandRole_policy" {
  name       = "RunCommandRole_policy"
  roles      = ["${aws_iam_role.RunCommandRole.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "RunCommandRole_profile" {
  name  = "RunCommandRole_profile"
  roles = ["${aws_iam_role.RunCommandRole.name}"]
}
