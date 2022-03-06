resource "aws_iam_user" "honeyuser" {
  name = "DeeSeatful"
  tags = {
    Division = "Obfuscation"
  }
}

resource "aws_iam_user_policy" "honeyuser_policy" {
  name = "explicit_deny"
  user = aws_iam_user.honeyuser.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "*",
            "Effect": "Deny",
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_access_key" "honeyuser_key" {
  user = aws_iam_user.honeyuser.name
}

output "display_secret" {
  value = "terraform output secret"
}

output "secret" {
  value     = aws_iam_access_key.honeyuser_key.secret
  sensitive = true
}

output "key" {
  value = aws_iam_access_key.honeyuser_key.id
}