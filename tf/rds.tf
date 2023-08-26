# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "eks_db_subnet_grp" {
  name       = "eks-db-subnet-grp"
#  subnet_ids = [ aws_subnet.eks_priv_subnet1_db.id, aws_subnet.eks_priv_subnet2_db.id, aws_subnet.eks_priv_subnet3_db.id ]
  subnet_ids = [ aws_subnet.eks_priv_subnet1_db.id, aws_subnet.eks_priv_subnet2_db.id ]

  tags = {
    Name = "eks_db_subnet_grp"
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_security_group

resource "aws_security_group" "eks_rds_sg" {
    name = "eks_rds_sg"
    description = "eks_rds_sg"
    vpc_id = aws_vpc.eks.id

    ingress = [   
        {
            cidr_blocks = [ var.vpc_cidr_block ] 
            description = "rds ingress"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        }
    ]

    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "rds egress"
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
        Name = "eks_rds_sg"
    }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "eks_mysql_stage" {
    identifier            = "eks-mysql-stage" 
    allocated_storage     = 10
    max_allocated_storage = 100
    engine                = "mysql"
    engine_version        = "8.0.33"
    instance_class        = "db.m5.large"
    username              = "root"
    password              = "admin22admin"
    skip_final_snapshot   = true
    db_subnet_group_name  = aws_db_subnet_group.eks_db_subnet_grp.name
    vpc_security_group_ids = [ aws_security_group.eks_rds_sg.id ] 
}

resource "aws_db_instance" "eks_mysql_prod" {
    identifier            = "eks-mysql-prod" 
    allocated_storage     = 10
    max_allocated_storage = 100
    engine                = "mysql"
    engine_version        = "8.0.33"
    instance_class        = "db.m5.large"
    username              = "root"
    password              = "admin22admin"
    skip_final_snapshot   = true
    db_subnet_group_name  = aws_db_subnet_group.eks_db_subnet_grp.name
    vpc_security_group_ids = [ aws_security_group.eks_rds_sg.id ] 
}

output "eks_mysql_stage" {
    value = aws_db_instance.eks_mysql_stage.endpoint
}

output "eks_mysql_prod" {
    value = aws_db_instance.eks_mysql_prod.endpoint
}

