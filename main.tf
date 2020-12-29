provider "aws" {
  region     = "eu-central-1"
}

resource "aws_security_group" "quicklaunchsg" {

    ingress {
        from_port   = 0
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Purpose = "OneTimeStorage"
    }
} 

resource "aws_instance" "ubuntu-docker" {
    ami             = "ami-066c7f5dd4143b850"
    instance_type   = "t2.micro"

    tags = {
        Purpose = "OneTimeStorage"
    }

      vpc_security_group_ids = [aws_security_group.quicklaunchsg.id]
   
    key_name = "medium_terraform"
}
