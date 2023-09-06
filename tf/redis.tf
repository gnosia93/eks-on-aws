resource "aws_security_group" "eks_redis_sg2" {
    name        = "eks_redis_sg2"
    description = "eks_redis_sg2"
    vpc_id = aws_vpc.eks.id

    ingress = [ 
        {
            cidr_blocks = [ var.vpc_cidr_block ] 
            description = "redis ingress"
            from_port = 6379
            to_port = 6379
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
            description = "redis egress"
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
        Name = "eks_redis_sg2"
    }   
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
resource "aws_elasticache_cluster" "eks_redis" {
  cluster_id           = "eks-redis"
  engine               = "redis"
#  engine_version       = "7.0.7"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  apply_immediately    = "true"
  subnet_group_name    = aws_elasticache_subnet_group.eks_redis_subnet_grp.name
  security_group_ids   = [aws_security_group.eks_redis_sg2.id] 
}

resource "aws_elasticache_subnet_group" "eks_redis_subnet_grp" {
  name       = "eks-redis-subnet-grp"
  subnet_ids = [aws_subnet.eks_priv_subnet1_db.id, aws_subnet.eks_priv_subnet2_db.id]
}
