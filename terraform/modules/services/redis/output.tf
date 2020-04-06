output "vpc_id" {
  value = sort(data.aws_vpcs.list_all.ids)[0]
}

output "node_subnet_ids" {
  value = data.aws_subnet_ids.private.ids
}

output "node_security_group" {
  value = data.aws_security_group.nodes
}

output "elasticcache_subnet_group_id" {
  value = aws_elasticache_subnet_group.flask.id
}

output "redis_host" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "redis_port" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.port
}