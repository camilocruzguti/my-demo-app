# Policy: allow Route53 management
# resource "aws_iam_role" "k8s-external-dns" {
#   name = "k8s-external-dns"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com",
#         "AWS": [
#             "arn:aws:iam::679441504692:role/my_web_app_gp1_us1-eks-node-group-20220706150326098600000001"
#         ]
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "k8s-external-dns-attach" {
#   role       = "my_web_app_gp1_us1-eks-node-group-20220706150326098600000001"
#   policy_arn = aws_iam_role_policy.allow-k8s-external-dns.a
# }

resource "aws_iam_role_policy" "allow-k8s-external-dns" {
  role   = "my_web_app_gp1_us1-eks-node-group-20220706150326098600000001"
  policy = data.aws_iam_policy_document.allow-k8s-external-dns.json
}

data "aws_iam_policy_document" "allow-k8s-external-dns" {

  statement {
    sid = "changeResourceRecordSets"

    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid = "readResourceRecords"

    actions = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}
