resource "aws_elasticache_subnet_group" "_" {
  name       = "tendenci-${var.env}"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_cluster" "_" {
  cluster_id           = "tendenci-${var.env}"
  engine               = "memcached"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5"
  port                 = 11211
  subnet_group_name = aws_elasticache_subnet_group._.name
  security_group_ids = [aws_security_group.elasticache.id]
}