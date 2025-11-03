resource "aws_lambda_function" "output_notifier" {
  function_name = "wordlist-output-notifier"
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime       = "python3.12"

  filename = "${path.module}/lambda/output_notifier.zip"
}