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
  key_name                     = aws_key_pair.kp.key_name
  vpc_security_group_ids       = [var.security_group_id] # Specify your security group(s) if required
  subnet_id                    = "subnet-004ac59a348d7512b"
  associate_public_ip_address = true
  #user_data                   = "${data.template_file.provision.rendered}"
  #iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"
  user_data = <<-EOF
	    #!/bin/bash
	    sudo su 
            apt update -y
            yum install postgresgl-server -y 
            
  	    # initialize postgres database and start service 
            
	    postgresgl-setup initdb
            systemctl start postgresql.service
            systemctl enable postgresql.service
            
	    # modify pg_hba.conf to allow access from any ip address and set trust authentication for postgres user 
            sed -i "s/host   all    all 127.0.0.1\/32     ident/host    all   all  0.0.0.0\/0
            sed -i '$a local   all  postgres    trust'  /var/lib/pgsql/data/postgresql.conf

            sudo -u postgres psql -c "ALTER USER PASSWORD '$(random_password.db_password.result);"  
   EOF
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "EC2-sw-testing"
  } 
  provisioner "file" {
    source      = "~/easyELKnginx.sh"
    destination = "/tmp/easyELKnginx.sh"
  }
  provisioner "file" {
    source      = "~/easyELKapache.sh"
    destination = "/tmp/easyELKapache.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/easyELKnginx.sh ",
      "sudo /tmp/easyELKnginx.sh ",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/easyELKapache.sh ",
      "sudo /tmp/easyELKapache.sh ",
    ]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    private_key = file(var.keyPath)
    host        = self.public_ip
  }
}
################################
 


