###########################################
# 	main.tf to build the environment      #
# 	Author: Stinky Fox		              #
###########################################

provider "aws" {
  region	= var.awsRegion
}

###########################################
### 	Upload the public key for EC2   ###
###########################################

resource "aws_key_pair" "quicklaunch-key" {

    key_name    = "${var.nodeBaseName}-deploy"
    public_key  = file(var.publicKeyLocation)

    tags = {

        Purpose 	= "OneTimeStorage"
        Name        = "${var.nodeBaseName}-key"

    }
}

###########################################
### 	Configure the security group 	###
###########################################

resource "aws_security_group" "quicklaunchsg" {

	count	= var.nodeCount

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

   ingress {
        from_port   = 443
        to_port     = 443
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

        Purpose 	= "OneTimeStorage"
        Name        = "${var.nodeBaseName}-${count.index}"

    }
}


###########################################
### 	Deploy an EC2 instance      	###
###########################################

resource "aws_instance" "dockerAMI" {
	
	count	                = var.nodeCount
	ami            	        = var.baseAMI
	instance_type  	        = var.instanceType
	key_name                = aws_key_pair.quicklaunch-key.key_name
   	vpc_security_group_ids  = [aws_security_group.quicklaunchsg[count.index].id]

    root_block_device {

        volume_size         = var.rootVolumeSize

    }

	tags = {

        	Purpose 	= "OneTimeStorage"
		    Name        = "${var.nodeBaseName}-${count.index}"

}

    depends_on = [
    aws_key_pair.quicklaunch-key,
    ]
}

###########################################
### 	Configure Route 53 names     	###
###########################################

resource "aws_route53_record" "node53" {

    count	= var.nodeCount
    zone_id = var.zoneID
    name    = "${var.nodeBaseName}-${count.index}"
    type    = "A"
    ttl     = "300"
    records = [aws_instance.dockerAMI[count.index].public_ip]

    depends_on = [
    aws_instance.dockerAMI,
    ]

}

###########################################
###     Dummy resource to run Ansible   ###
###########################################

resource "null_resource" "run-ansible" { 

    count	= var.nodeCount
	provisioner "local-exec" {

		command = "ansible-playbook ansible/configure.yaml -i $FQDN, --extra-vars '{\"my_db_password\":\"'$DBPWD'\",\"my_admin_password\":\"'$PSWD'\",\"my_admin_email\":\"'$ADMIN'\",\"my_dns_hostname\":\"'$FQDN'\"}' --key-file $KEY_LOCATION"
		
		environment = {
		
		FQDN 	                    = aws_route53_record.node53[count.index].fqdn
		ADMIN	                    = var.nodeAdmin
		PSWD	                    = var.nodePassword
		DBPWD	                    = var.databasePassword
        ANSIBLE_HOST_KEY_CHECKING   = "False"
        KEY_LOCATION                = var.privateKeyLocation
	
		}
	}

    depends_on = [
    aws_instance.dockerAMI,
    aws_route53_record.node53,
    ]
    
}