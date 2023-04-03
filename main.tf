#Create EC2 Instance
resource "aws_instance" "instance1" {
  ami                         = var.variables_ami
  instance_type               = var.variables_instance_type
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  user_data                   = file("jenkins.sh")
  user_data_replace_on_change = true
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.EC2-Jenkins-profile.name
  key_name                    = var.variables_key_name

  tags = {
    Name = var.variables_instance_name
  }
}

#Create security group 
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Open ports 22, 8080, and 443"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Incoming SSH"
    from_port   = 22
    to_port     = 22
    protocol    = var.variables_tcp
    cidr_blocks = [var.variables_cidr]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Incoming 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = var.variables_tcp
    cidr_blocks = [var.variables_cidr]
  }

  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Incoming 443"
    from_port   = 443
    to_port     = 443
    protocol    = var.variables_tcp
    cidr_blocks = [var.variables_cidr]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = var.variables_egress
    cidr_blocks = [var.variables_cidr]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

#Create S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins-artifacts" {
  bucket = "jenkins-artifacts-${random_id.randomness.hex}"

  tags = {
    Name = "jenkins_artifacts"
  }
}

#Create random number for S3 bucket name
resource "random_id" "randomness" {
  byte_length = 16
}

#Make S3 bucket and objects private
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "private-bucket" {
  bucket                  = aws_s3_bucket.jenkins-artifacts.id
  block_public_acls       = var.variables_block_public_acls
  block_public_policy     = var.variables_block_public_policy
  ignore_public_acls      = var.variables_ignore_public_acls
  restrict_public_buckets = var.variables_restrict_public_buckets
}

#Create IAM policy that allows read/write access to Jenkins artifacts S3 bucket
#https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_s3_rw-bucket.html
resource "aws_iam_policy" "S3-read-write-policy" {
  name        = "S3-read-write-policy"
  path        = "/"
  description = "Policy that allows read/write access to Jenkins artifacts S3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : ["arn:aws:s3:::jenkins-artifacts"]
      },
      {
        "Sid" : "GetPutObjectsInBucket"
        "Effect" : "Allow"
        "Action" : ["s3:GetObject", "s3:PutObject"]
        "Resource" : ["arn:aws:s3:::jenkins-artifacts/*"]
      }
    ]
  })
}

#Create IAM role that can be assumed by EC2 instance (Jenkins server)
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "EC2-Jenkins-role" {
  name = "EC2-Jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "EC2-Jenkins-Role"
  }
}

#Attach the role to the IAM policy
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "policy-attachment" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.EC2-Jenkins-role.name]    #Insert role name
  policy_arn = aws_iam_policy.S3-read-write-policy.arn #Insert policy name
}

#Create an instance profile
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "EC2-Jenkins-profile" {
  name = "EC2-Jenkins-profile"
  role = aws_iam_role.EC2-Jenkins-role.name
}

