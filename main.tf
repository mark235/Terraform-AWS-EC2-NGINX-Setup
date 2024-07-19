provider "aws" {
  region = "us-east-1"  
}

resource "aws_instance" "terraform" {
  ami           = "ami-01fccab91b456acc2"  # Amazon Linux 2 AMI ID
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "Hello World" | sudo tee /usr/share/nginx/html/index.html
  EOF

  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "HelloWorldWebServer"
  }
}

resource "aws_security_group" "sg" {
  name_prefix = "terraform-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
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

output "instance_ip" {
  value = aws_instance.terraform.public_ip
}
