data "aws_availability_zones" "azlist" {
    state = "available"
}

resource "aws_vpc" "eks" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags = {
        Name = "eks-workshop"
    } 
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "eks_igw" {
    vpc_id = aws_vpc.eks.id   

    tags = {
        Name = "eks_igw"
    } 
}

resource "aws_eip" "eks_eip_nat" {
    vpc = true
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "eks_natgw" {
    allocation_id = aws_eip.eks_eip_nat.id
    subnet_id     = aws_subnet.eks_pub_subnet1.id

    tags = {
        Name = "eks-nat-gw"
    }
}



# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "eks_pub_subnet1" {
    availability_zone = data.aws_availability_zones.azlist.names[0]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_pub1

    tags = {
        Name = "eks_pub_subnet1"
    } 
}

resource "aws_subnet" "eks_pub_subnet2" {
    availability_zone = data.aws_availability_zones.azlist.names[1]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_pub2

    tags = {
        Name = "eks_pub_subnet2"
    } 
}

/*
resource "aws_subnet" "eks_pub_subnet3" {
    availability_zone = data.aws_availability_zones.azlist.names[2]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_pub3

    tags = {
        Name = "eks_pub_subnet3"
    } 
}
*/

resource "aws_subnet" "eks_priv_subnet1" {
    availability_zone = data.aws_availability_zones.azlist.names[0]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv1

    tags = {
        Name = "eks_priv_subnet1"
    } 
}

resource "aws_subnet" "eks_priv_subnet2" {
    availability_zone = data.aws_availability_zones.azlist.names[1]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv2

    tags = {
        Name = "eks_priv_subnet2"
    } 
}

/*
resource "aws_subnet" "eks_priv_subnet3" {
    availability_zone = data.aws_availability_zones.azlist.names[2]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv3

    tags = {
        Name = "eks_priv_subnet3"
    } 
}
*/


resource "aws_subnet" "eks_priv_subnet1_db" {
    availability_zone = data.aws_availability_zones.azlist.names[0]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv1_db

    tags = {
        Name = "eks_priv_subnet1_db"
    } 
}

resource "aws_subnet" "eks_priv_subnet2_db" {
    availability_zone = data.aws_availability_zones.azlist.names[1]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv2_db

    tags = {
        Name = "eks_priv_subnet2_db"
    } 
}

/*
resource "aws_subnet" "eks_priv_subnet3_db" {
    availability_zone = data.aws_availability_zones.azlist.names[2]
    vpc_id = aws_vpc.eks.id
    cidr_block = var.vpc_subnet_priv3_db

    tags = {
        Name = "eks_priv_subnet3_db"
    } 
}
*/


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "eks_pub_rt" {
    vpc_id = aws_vpc.eks.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id    
    }
    
    tags = {
        Name = "eks_pub_rt"
    }
}


resource "aws_route_table" "eks_priv_rt" {
    vpc_id = aws_vpc.eks.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.eks_natgw.id    
    }
    
    tags = {
        Name = "eks_priv_rt"
    }
}


#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "eks_rt_association1" {
    subnet_id = aws_subnet.eks_pub_subnet1.id
    route_table_id = aws_route_table.eks_pub_rt.id
}

resource "aws_route_table_association" "eks_rt_association2" {
    subnet_id = aws_subnet.eks_pub_subnet2.id
    route_table_id = aws_route_table.eks_pub_rt.id
}

/*
resource "aws_route_table_association" "eks_rt_association3" {
    subnet_id = aws_subnet.eks_pub_subnet3.id
    route_table_id = aws_route_table.eks_pub_rt.id
}
*/

resource "aws_route_table_association" "eks_rt_association-priv1" {
    subnet_id = aws_subnet.eks_priv_subnet1.id
    route_table_id = aws_route_table.eks_priv_rt.id
}

resource "aws_route_table_association" "eks_rt_association-priv2" {
    subnet_id = aws_subnet.eks_priv_subnet2.id
    route_table_id = aws_route_table.eks_priv_rt.id
}

/*
resource "aws_route_table_association" "eks_rt_association-priv3" {
    subnet_id = aws_subnet.eks_priv_subnet3.id
    route_table_id = aws_route_table.eks_priv_rt.id
}
*/


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
