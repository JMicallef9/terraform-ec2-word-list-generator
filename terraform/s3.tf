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

# resource "terraform_data" "verify_output" {
#   depends_on = [aws_instance.word_list_ec2]

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Waiting for output file in S3...'",
#       "for i in {1..30}; do",
#       "  if aws s3 ls s3://${aws_s3_bucket.ec2_bucket.bucket}/output/; then",
#       "    echo 'Success! Output file found in S3!'",
#       "    exit 0;",
#       "  fi",
#       "  echo 'Still waiting...'; sleep 10;",
#       "done",
#       "echo 'Operation failed. No output file found in S3.'",
#       "exit 1"
#     ]

#     connection {
#       type = "ssh"
#       user = "ec2-user"
#       private_key =  file(local.local_key_path) 
#       host = aws_instance.word_list_ec2.public_ip
#     }
#   }
# }

# resource "terraform_data" "end_message" {
#   depends_on = [terraform_data.verify_output]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
#       echo "Word list generation completed successfully!"
#       echo "Output available in S3 bucket:"
#       echo "   s3://${aws_s3_bucket.ec2_bucket.bucket}/output/"
#       echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
#     EOT
#   }
# }