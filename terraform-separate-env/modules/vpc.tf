resource "aws_vpc" "test_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "${var.env}-test_vpc"
  }
}
