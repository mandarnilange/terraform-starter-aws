#########################################################
# VPC Main to be created 
#########################################################
resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.namespace}-vpc"
  }
}

# Deny all traffic in default in SG
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.namespace}-default-sg"
  }
}

# Default NACL updated for Name - keeping all ingress and egress same as default 
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "Name" = "${var.namespace}-default-NACL"
  }

}

#########################################################
# Security Groups 
#########################################################

#Security group for ALBs 
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  name        = "${var.namespace}-ALB-SG"
  description = "Seurity Group for Load Balancers"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for Http traffic "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for Https traffic "
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Rule for Https traffic "
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Rule for Http traffic "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  tags = {
    "Name" = "${var.namespace}-ALB-SG"
  }

}

#Security group for Bastion host  
resource "aws_security_group" "tunnel_sg" {
  vpc_id = aws_vpc.main.id

  name        = "${var.namespace}-Tunnel-SG"
  description = "Seurity Group for Tunneling SSH"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for ssh traffic "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Rule for SSH traffic to EC2 "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for HTTPs traffic to EC2 "
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  tags = {
    "Name" = "${var.namespace}-Tunnel-SG"
  }

}

#Security group for Web Servers  
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  name        = "${var.namespace}-Web-SG"
  description = "Seurity Group for Web Servers"

  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Rule for Http traffic "
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }

  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Rule for Https traffic "
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  ingress {
    security_groups = [aws_security_group.tunnel_sg.id]
    description     = "Rule for SSH traffic from tunnel "
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }

  egress {
    # cidr_blocks = [aws_vpc.main.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for outbound traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.namespace}-Web-SG"
  }

}

#Security group for DB Servers  
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  name        = "${var.namespace}-DB-SG"
  description = "Seurity Group for Database Servers"

  ingress {
    security_groups = [aws_security_group.web_sg.id]
    description     = "Rule for DB traffic "
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
  }


  egress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Rule for outbound traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
  }

  tags = {
    "Name" = "${var.namespace}-DB-SG"
  }

}

resource "aws_security_group" "endpoint" {
  vpc_id = aws_vpc.main.id

  name        = "${var.namespace}-endpoint-SG"
  description = "Seurity Group for VPC endpoints"

  ingress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Rule for all traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }


  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rule for outbound traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.namespace}-endpoint-SG"
  }

}


#########################################################
# Subnets
#########################################################

# create private subnets 
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id

  # for_each = toset(var.private_subnets)
  count = length(var.private_subnets)

  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.selected.names[count.index]

  tags = {
    Name = "${var.namespace}-private-subnets"
  }

  depends_on = [
    data.aws_availability_zones.selected
  ]

}

# public subnets to be crated 
# TODO current implementation is not full proof - expects 3 subnets
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  count = length(var.public_subnets)

  cidr_block        = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.selected.names[count.index]

  tags = {
    Name = "${var.namespace}-public-subnets"
  }

  depends_on = [
    data.aws_availability_zones.selected
  ]
}

# create DB subnets 
# TODO current implementation is not full proof - expects 3 subnets
resource "aws_subnet" "db_subnets" {
  vpc_id = aws_vpc.main.id

  count = length(var.db_subnets)

  cidr_block        = var.db_subnets[count.index]
  availability_zone = data.aws_availability_zones.selected.names[count.index]

  tags = {
    Name = "${var.namespace}-db-subnets"
  }

  depends_on = [
    data.aws_availability_zones.selected
  ]
}

#########################################################
# Internet Gateway and Routing table   
#########################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.namespace}-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.namespace}-internet-route-tbl"
  }
}

resource "aws_route_table_association" "public" {

  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [
    aws_subnet.public,
  ]
}


#########################################################
# Subnet Group for DB  
#########################################################

# Database subnet group for RDS 
resource "aws_db_subnet_group" "default" {
  name        = lower("${var.namespace}-db-subnet-group")
  description = "DB subnet group - ${var.namespace}"

  subnet_ids = aws_subnet.db_subnets[*].id

  tags = {
    Name = "${var.namespace}-db-subnet-group"
  }

  depends_on = [
    aws_subnet.db_subnets
  ]

}

#########################################################
# VPC endpoints and associate to private subnet 
#########################################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.endpoint.id,
  ]

}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.endpoint.id,
  ]

}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.endpoint.id,
  ]

}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id


  security_group_ids = [
    aws_security_group.endpoint.id,
  ]

}

#########################################################
# Supporting data sources 
#########################################################


# Availability zones 
data "aws_availability_zones" "selected" {
  state = "available"
  filter {
    name   = "region-name"
    values = ["${var.region}"]
  }
}
