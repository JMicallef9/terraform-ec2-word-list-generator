resource "aws_s3_bucket" "ec2_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "ec2_bucket"
  }
}

resource "terraform_data" "upload_input" {
  provisioner "local-exec" {
    command = "python script/s3_upload.py"
    environment = {
      BUCKET_NAME = var.bucket_name
      INPUT_KEY = var.input_key
      LOCAL_FILE = var.local_filepath
    }
  }

  depends_on = [aws_s3_bucket.ec2_bucket]
}

resource "terraform_data" "verify_output" {
  depends_on = [aws_instance.word_list_bucket]

  provisioner "local-exec" {
    command = <<EOF
      sleep 120
      if aws s3 ls s3://${aws_s3_bucket.ec2_bucket.bucket}/output/; then
        echo "Success! Output file found in S3!"
      else
        echo "Operation failed. No output file found in S3."
      fi
    EOF
  }
}