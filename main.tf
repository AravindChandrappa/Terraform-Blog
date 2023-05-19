provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAXOLJCO4BX6GFYYUE"
  secret_key = "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" 
}
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
 key_name   = "myKey2"       # Create a "myKey" to AWS!!
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
  key_name                     = aws_key_pair.kp.key_name
  vpc_security_group_ids       = [var.security_group_id] # Specify your security group(s) if required
  subnet_id                    = "subnet-004ac59a348d7512b"
  associate_public_ip_address = true
  #user_data                   = "${data.template_file.provision.rendered}"
  #iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"
   connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    host = self.public_ip
    private_key = aws_key_pair.kp.key_name
    # The connection will use the local SSH agent for authentication.
  }

  # install java, create dir
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install openjdk-8-jre-headless",
      "mkdir data",
      "cd data",
      "mkdir inbox",
      "cd ..",
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "EC2-sw-testing"
  } 
  
}
################################
 


