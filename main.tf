provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAXOLJCO4B4E4EW4FJ"
  secret_key = "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" 
}
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
 key_name   = "myKey3"       # Create a "myKey" to AWS!!
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
  user_data = <<-EOL
	    #!/bin/bash -xe
	    apt update
	    apt install openjdk-11-jdk --yes
	    apt install openjdk-11-jre --yes
	    apt install maven --yes
	    java --version
	    sudo apt --yes install vim bash-completion wget
	    sudo apt --yes upgrade
	    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
            echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
            sudo apt update
	    sudo apt --yes install postgresql-client-12
	    postgresgl-setup initdb
	    systemctl start postgresql.service
	    systemctl enable postgresql.service
	    sed -i "s/host   all    all 127.0.0.1\/32     ident/host    all   all  0.0.0.0\/0
	    sed -i '$a local   all  postgres    trust'  /var/lib/pgsql/data/postgresql.conf
	    sudo -u postgres psql -c "ALTER USER PASSWORD '$(random_password.db_password.result);"
   	    EOL
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "EC2-sw-testing"
  } 
  
}
################################
 


