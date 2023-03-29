#Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

#Create EC2 Instance
resource "aws_instance" "instance1" {
  ami                    = "ami-0533def491c57d991"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "jenkins_instance"
  }

  #Bootstrap Jenkins installation and start  
  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo yum upgrade
  sudo amazon-linux-extras install java-openjdk11 -y
  sudo yum install jenkins -y
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  EOF

  user_data_replace_on_change = true
}

#Create security group for ports 22 and 8080
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Open ports 22 and 8080"

  #Allow incoming TCP requests on port 22 from local IP
  ingress {
    description = "SSH from local"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["67.173.234.137/32"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Incoming 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

#Create S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins-artifacts5847" {
  bucket = "jenkins-artifacts-${random_id.randomness.hex}"

  tags = {
    Name = "jenkins_artifacts"
  }
}

#Make S3 bucket private
resource "aws_s3_bucket_acl" "private_bucket" {
  bucket = aws_s3_bucket.jenkins-artifacts5847.id
  acl    = "private"
}

#Create random number for S3 bucket name
resource "random_id" "randomness" {
  byte_length = 16
}