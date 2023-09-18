data "aws_iam_policy" "pvre_policy" {
    arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "pvre_policy_patch" {
    arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

// ec2 SSM Core
resource "aws_iam_role_policy_attachment" "pvre-attach-ec2" {
  role       = aws_iam_role.eks_ec2_service_role.name
  policy_arn = data.aws_iam_policy.pvre_policy.arn
}


// ec2 SSM Patch
resource "aws_iam_role_policy_attachment" "pvre-attach-patch-ec2" {
  role       = aws_iam_role.eks_ec2_service_role.name
  policy_arn = data.aws_iam_policy.pvre_policy_patch.arn
}

