# Create VPC
resource "aws_vpc" "mod" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mod-vpc"
  }
}
# Create internet gateway and attach to vpc
resource "aws_internet_gateway" "mod" {
  vpc_id = aws_vpc.mod.id
  tags = {
    Name = "mod-igw"
  }
}
# Create public subnets
resource "aws_subnet" "mod" {
  vpc_id = aws_vpc.mod.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ca-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-mod-subnet"
  }
}
# Create route table and associate with subnets
resource "aws_route_table" "mod" {
    vpc_id = aws_vpc.mod.id
    tags = {
      Name = "mod-route-table"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mod.id
    }
    
}
resource "aws_route_table_association" "mod" {
  subnet_id = aws_subnet.mod.id
  route_table_id = aws_route_table.mod.id
}
# Create Security group
resource "aws_security_group" "mod" {
  vpc_id = aws_vpc.mod.id
  name = "allow traffic"
  description = "allow all the traffic with the help of ingress and egress rules"
  tags = {
    Name = "mod-sg"
  }
  ingress  {
    description = "TLS from vpc"
    from_port   = 22
    to_port     = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from vpc"
    from_port   = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress  {
    description = "TLS from vpc"
    from_port   = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create Instance
resource "aws_instance" "mod" {
  ami = "ami-0dcab815e6ee910aa"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mod.id]
  key_name = "jenkins"
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.mod.id
  availability_zone = "ca-central-1a"
  tags = {
    Name = "mod-ec2"
  }
}
