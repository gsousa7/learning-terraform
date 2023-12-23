resource "aws_vpc" "alpha_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Give the name of the VPC dev
  tags = {
    Name = "dev"
  }
}

# Create a Subnet with the name "dev" to get the name of vpc_id use the command 'terraform state list'
# map_public_ip_on_launch  -> Specify true to indicate that instances launched into the subnet should be assigned a public IP address
resource "aws_subnet" "alpha_subnet" {
  vpc_id                  = aws_vpc.alpha_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

# Create a internet gateway - this will expose resources to the internet
resource "aws_internet_gateway" "alpha_internet_gateway" {
  vpc_id = aws_vpc.alpha_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# Create route table
resource "aws_route_table" "alpha_public_rt" {
  vpc_id = aws_vpc.alpha_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

# Create routes
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.alpha_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.alpha_internet_gateway.id

}

# Associate the route table to the subnet
resource "aws_route_table_association" "alpha_public_association" {
  subnet_id      = aws_subnet.alpha_subnet.id
  route_table_id = aws_route_table.alpha_public_rt.id
}

# Create security group
# security group is a component for controlling inbound and outbound traffic to and from EC2 instances and other AWS resources in a VPC. It acts as a virtual firewall for your instances, allowing to define rules that specify the type of traffic and the sources or destinations that are allowed or denied.
resource "aws_security_group" "alpha_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.alpha_vpc.id

  ingress {                            #incoming traffic
    from_port   = 0                    # represents the starting port for the rule. It's set to 0, meaning the rule applies to traffic starting from port 0.
    to_port     = 0                    # This represents the ending port for the rule. It's set to 0, indicating that the rule applies to traffic up to port 0.
    protocol    = "-1"                 # means all protocols are allowed. -1 is a wildcard that matches all protocols.
    cidr_blocks = ["0.0.0.0/32"]       # for multiple IPs use ["1.1.1.1/32", "2.2.2.0/24"], before 0.0.0.0/0 was the public IP
  }

  egress { # outgoing  traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}