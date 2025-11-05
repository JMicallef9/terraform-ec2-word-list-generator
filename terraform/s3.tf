resource "aws_s3_bucket" "ec2_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "ec2_bucket"
  }
}

resource "terraform_data" "upload_input" {
  provisioner "local-exec" {
    command = "${path.module}/docker/venv/bin/python ${path.module}/script/s3_upload.py"
    environment = {
      BUCKET_NAME = var.bucket_name
      INPUT_KEY = var.input_key
      LOCAL_FILE = var.local_filepath
    }
  }

  depends_on = [aws_s3_bucket.ec2_bucket]
}