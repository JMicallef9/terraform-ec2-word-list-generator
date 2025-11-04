resource "aws_lambda_function" "output_notifier" {
  function_name = "wordlist-output-notifier"
  role          = aws_iam_role.lambda_role.arn
  handler       = "output_notifier.lambda_handler"
  runtime       = "python3.12"

  filename = "${path.module}/lambda.zip"
}

resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.output_notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ec2_bucket.arn
}

resource "aws_s3_bucket_notification" "output_trigger" {
  bucket = aws_s3_bucket.ec2_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.output_notifier.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "output/"
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]
}