#Define output 
#https://developer.hashicorp.com/terraform/language/values/outputs
output "Jenkins-instance-id" {
  value       = aws_instance.instance1.id
  description = "Jenkins instance ID number"
}

output "Jenkins-public-ip" {
  value       = aws_instance.instance1.public_ip
  description = "Jenkins public IP of the web server"
}

output "Jenkins-bucket-name" {
  value       = aws_s3_bucket.jenkins-artifacts.id
  description = "Name of the Jenkins S3 bucket"
}
