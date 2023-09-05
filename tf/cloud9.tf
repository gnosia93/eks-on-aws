# https://spak.no/blog/article/61407c2e77201a55fc6dc87b

resource "aws_cloud9_environment_ec2" "cloud9_instance" {
  name                        = "eks_cloud9"
  instance_type               = "t2.medium"
  automatic_stop_time_minutes = 30
  subnet_id                   = aws_subnet.eks_pub_subnet1.id

  tags = {
    app = "cloud9"
  }
}
