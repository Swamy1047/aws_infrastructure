resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
      Name = "My-VPC"
      Environment = "Dev"
      Terraform = "true"
    }  
}
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id  

    tags = {
        Name = "Internet Gateway"
        Environment = "Dev"
    } 
}
resource "aws_security_group" "my-sg" {
  name        = "instance security group"
  description = "open 22,443,80,8080,9000,3000"
  vpc_id      = aws_vpc.main.id

  ingress = [
    for port in [22, 443, 80, 8080, 9000, 3000, 5000] : {
    description      = "TLS from VPC"
    from_port        = port
    to_port          = port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []   
    self             = false
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "My-Sg"
  }
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_sub1_cidr
    map_public_ip_on_launch = true
    availability_zone = "ap-southeast-1a"

    tags = {
      Name = "Public Subnet-1"
      Environment = "Dev"
      Terraform = "true"
    }
  
}
resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_sub2_cidr
    map_public_ip_on_launch = true
    availability_zone = "ap-southeast-1b"

    tags = {
      Name = "Public Subnet-2"
      Environment = "Dev"
      Terraform = "true"
    }
  
}
resource "aws_route_table" "public_rt1" {
    vpc_id = aws_vpc.main.id

    route {        
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
    tags = {
      Name = "Public Route table-1"
      Environment = "Dev"
      Terraform = "true"
    }  
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.public_rt1.id  
}
resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public2.id
    route_table_id = aws_route_table.public_rt1.id  
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_sub_cidr
    map_public_ip_on_launch = false
    availability_zone = "ap-southeast-1c"

    tags = {
      Name = "Private Subnet"
      Environment = "Dev"
      Terraform = "true"
    }  
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Private RT"
        Environment = "Dev"
    }  
}
resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id  
}
resource "aws_eip" "elastic_ip" {
    domain = "vpc"  
}
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.elastic_ip.id
    subnet_id = aws_subnet.public1.id

    tags = {
        Name = "Nat Gateway"
        Environment = "Dev"
    }   
}
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
    depends_on = [ aws_route_table.private ]  
}

resource "aws_instance" "server" {
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.public1.id
    vpc_security_group_ids = [ aws_security_group.my-sg.id ]
    user_data = templatefile("./install_jenkins.sh", {})
    key_name = "mns"
    count = 1

    root_block_device {
      volume_size = 30
    }

    tags = {
      Name = "Web-server"
      Environment = "Dev"
      Terraform = "true"
    }
  
}