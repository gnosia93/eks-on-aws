
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "eks_ec2_sg" {
    name        = "eks_ec2_sg"
    description = "eks_ec2_sg"
    vpc_id = aws_vpc.bigdata.id

    ingress = [ 
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "ec2 ingress"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ "pl-e1a54088" ]
            security_groups = [ ]
            self = false
        },
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "ec2 ingress"
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ "pl-e1a54088" ]
            security_groups = [ ]
            self = false
        }

    ]

    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "ec2 egress"
            from_port = 0
            to_port = 0
            protocol = "-1"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        }
    ]   
    
    tags = {
        Name = "eks_ec2_sg"
    }   
}


resource "aws_iam_role" "eks_ec2_service_role" {
  name = "bigdata_ec2_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "eks_ec2_policy" {
  name = "bigdata_ec2_policy"
  role = aws_iam_role.bigdata_ec2_service_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "eks_ec2_profile" {
  name = "eks_ec2_profile"
  role = aws_iam_role.eks_ec2_service_role.name
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "eks_ec2" {
#    ami = data.aws_ami.amazon-linux-2.id
    associate_public_ip_address = true
    instance_type = "c6i.2xlarge"
    iam_instance_profile = aws_iam_instance_profile.eks_ec2_profile.name
    monitoring = true
    root_block_device {
        volume_size = "50"
    }
    key_name = var.key_pair
    vpc_security_group_ids = [ aws_security_group.eks_ec2_sg.id ]
    subnet_id = aws_subnet.eks_pub_subnet1.id
    user_data = <<_DATA
#! /bin/bash
sudo yum install python
sudo yum install python3-pip
pip install locust
locust -V
_DATA

    tags = {
      "Name" = "eks_locust"
    } 
}

output "locust_public_ip" {
    value = aws_instance.eks_ec2.public_dns
}

