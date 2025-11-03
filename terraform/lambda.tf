resource "aws_lambda_function" "output_notifier" {
  function_name = "wordlist-output-notifier"
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime       = "python3.12"

  filename = "${path.module}/lambda/output_notifier.zip"
}

resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.output_notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ec2_bucket.arn
}