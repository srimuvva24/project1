# -----------------------------
# IAM Role for EC2
# -----------------------------
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "ec2-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------
# IAM Policy for DynamoDB
# -----------------------------
resource "aws_iam_policy" "dynamodb_policy" {
  name        = "ec2-dynamodb-policy"
  description = "Allow EC2 to access DynamoDB Candidates table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBTableAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.candidate_table.arn
      }
    ]
  })
}

# -----------------------------
# Attach Policy to Role
# -----------------------------
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# -----------------------------
# IAM Instance Profile (for EC2 to use the role)
# -----------------------------
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-dynamodb-instance-profile"
  role = aws_iam_role.ec2_dynamodb_role.name
}
