provider "aws" {
  region     = "us-west-2"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

resource "aws_instance" "web" {
  ami                    = "ami-0d97c86470a6f58c6" # instacne image already set all application configuration required for three teir
  instance_type          = var.instance_type
  key_name               = "dockerfile" #replace your key
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./id_rsa") # id_rsa must be present in same dir which have 600 permission
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 755 /root",
      "sudo mv -f /root/apache-tomcat-9.0.89 /home/ubuntu/"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo ./apache-tomcat-9.0.89/bin/catalina.sh start"
    ]
  }
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http_port"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-035db7aafe920b68a" # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # 22 port must for every instance for ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
