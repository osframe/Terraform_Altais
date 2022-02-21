output "vpc_id" {
  value = aws_vpc.terra-vpc.id
  sensitive = false
}

output "subnet_id" {
  value = aws_subnet.public-subnet.id
  sensitive = false
}

output "gateway_id" {
  value = aws_internet_gateway.igw.id
  sensitive = false
}

output "default_route_table_id" {
  value = aws_vpc.terra-vpc.main_route_table_id
  sensitive = false
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.osframe-terra-bucket.id
  sensitive = false
}
