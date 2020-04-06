#### Data sources

data "aws_vpcs" "list_all" {
  tags = {
    KubernetesCluster = var.cluster_name
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = sort(data.aws_vpcs.list_all.ids)[0]

  tags = {
    SubnetType = "Private"
  }
}

data "aws_security_group" "nodes" {
  name = "nodes.${var.cluster_name}"
}

### Module resources

resource "aws_subnet" "services" {
  vpc_id = sort(data.aws_vpcs.list_all.ids)[0]
  cidr_block = var.services_subnet_cidr_block
  tags = {
    Name = "services-${var.release_name}.${var.cluster_name}"
    SubnetType = "Services"
  }
}

resource "aws_elasticache_subnet_group" "flask" {
  name       = "${var.release_name}-redis-cache-subnet"
  subnet_ids = ["${aws_subnet.services.id}"]
}

resource "aws_security_group" "allow_services" {
  name        = "${var.release_name} Allow Service access"
  description = "Allow all traffic from Nodes to Services subnet"
  vpc_id      = sort(data.aws_vpcs.list_all.ids)[0]

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [data.aws_security_group.nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "services.${var.cluster_name}"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.release_name}-redis"
  subnet_group_name    = aws_elasticache_subnet_group.flask.name
  security_group_ids   = [aws_security_group.allow_services.id]
  engine               = var.redis_engine
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = var.redis_parameter_group_name
  engine_version       = var.redis_engine_version
  port                 = var.redis_port
}
