# To get the owner Simulate a creation of a EC2 instance and grab the AMI ID, go to Images -> AMIs and search for the AMI ID and collect the owner
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # AMI NAME
  }
}