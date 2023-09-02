# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
resource "aws_elasticache_cluster" "eks_redis" {
  cluster_id           = "eks-redis"
  engine               = "redis"
  engine_version       = "7.0.7"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7.cluster.on"
  port                 = 6379
}
