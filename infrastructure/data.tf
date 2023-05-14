data "aws_iam_policy_document" "instance-assume-role-policy-for-spotfleet" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy-for-ecs-node" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}