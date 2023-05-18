provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAXOLJCO4BWCHJ4EO5"
  secret_key = "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" 
}
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
}

#Create a new EC2 launch configuration
resource "aws_instance" "ec2_public" {
  ami                          = var.ami_id
  instance_type                = var.instance_type
  key_name                     = var.key_name
  #security_group_id            = var.security_group_id
  #subnet_id                    = var.subnet_id
  associate_public_ip_address = true
  #user_data                   = "${data.template_file.provision.rendered}"
  #iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "EC2-sw-testing"
  } 
}
################################
 


