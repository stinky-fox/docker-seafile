#################################################
# 	Define variables to pass                	#
#	Set variables in set.tfvars file			#
#################################################

#EC2 specific configuration

variable "baseAMI" {
        
	type		= string
    description	= "AMI ID with preinstalled docker, docker-compose and pre-activated DSA"

}

variable "instanceType" {

	type		= string
	description	= "Set the instance type you would like to run."
	default		= "t2.micro"

}

variable "rootVolumeSize" {

	type		= number
	description	= "How big your root volume should be. From terraform docs: Size of the volume in gibibytes (GiB)."
	default		= 10
	
}

# Provider-specific configuration

variable "awsRegion" {

	type		= string
	description	= "region where to deploy EC2 instance"

}

# Route 53 configurations

variable "zoneID" {
	
	type		= string
	description	= "domains zone ID"

}


variable "nodeBaseName" {

    type		= string
    description = "Name of the node in Route 53 DNS"

}


# Seafile specific configuration

variable "nodeAdmin" {
	
	type		= string
	description	= "Administrators email for Seafile instance"
	default		= "me@example.com"

}

variable "nodePassword" {

	type		= string
	description	= "Seafile admin password"
	default		= "SuperSecure123"

}

variable "databasePassword" {

	type		= string
	description	= "Seafile DB password"
	default		= "YetAnotherSuperSecret123Password"

}

# Other variables

variable "nodeCount" {
	
	type 		= number
	description	= "Number of nodes to deploy"
	default		= 1

}

variable "publicKeyLocation" {

	type		= string
	description	= "Path to public key for Ansible to connect to EC2"
	default		= "~/.ssh/id_rsa.pub"

}

variable "privateKeyLocation" {

	type		= string
	description	= "Path to public key for Ansible to connect to EC2"
	default		= "~/.ssh/id_rsa"

}