resource "aws_lambda_function" "send_ssm" {
  function_name = "send_ssm"
  role          = aws_iam_role.lambda_role.arn
  handler       = "send_ssm.lambda_handler"
  runtime       = "python3.12"

  filename = "${path.module}/lambda.zip"

  depends_on = [aws_iam_role_policy_attachment.lambda_ssm]
}

resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_ssm.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ec2_bucket.arn
}

resource "aws_s3_bucket_notification" "input_trigger" {
  bucket = aws_s3_bucket.ec2_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.send_ssm.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]
}