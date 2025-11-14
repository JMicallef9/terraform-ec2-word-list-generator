# Word List Generator (via Terraform, EC2 and Docker)

This project creates an event-driven AWS workflow using Terraform.

When a text file is uploaded to an S3 bucket, a Lambda function automatically triggers an EC2 instance to run a Dockerised Python application. The application processes the file and uploads a generated wordlist CSV file back into the same S3 bucket.

The Python application is a simplified and adapted version of the [Word List Generator](https://github.com/JMicallef9/word-list-generator).

## Terraform Infrastructure

Terraform deploys and configures the following:

1. An S3 bucket for storing input and output files.
2. An EC2 instance with Docker installed and a pre-built image pulled: `jmicallef9/word-list-generator-ec2:latest`
3. A Lambda function that is triggered by any new file uploads to the S3 bucket with a `/input` prefix.
4. An SSM execution path allowing Lambda to issue remote commands to the EC2 instance.

Note that Terraform does not run the Docker container directly; it simply sets up the automation pipeline.

## The Processing Workflow

The workflow is triggered by the uploading of a file to the S3 bucket. To upload a file, you can either:

- Use the AWS console to add a file with the `/input` prefix
- OR run an AWS CLI command using the local filepath and bucket name:
`aws s3 cp ./data/sample.txt s3://<bucket-name>/input/sample.txt`

This is the first step in the following process:

1. Upload a file to the S3 bucket with the prefix `/input`
2. The Lambda function is now triggered and sends an SSM command to the EC2 instance.
3. EC2 runs the Docker container with the provided S3 path.
4. The container downloads the file from the S3 bucket, processes the text, and uploads the CSV result into the same bucket with the prefix `/output`

## Prerequisites

- Terraform
- AWS account with credentials configured via `aws configure`
- An AWS EC2 key pair
- A text file in one of the following file formats: `.txt`, `.srt`, `.md`, `.docx`, `.pdf`, `.epub`

## Instructions

1. Clone the repository with the following command: `git clone https://github.com/JMicallef9/terraform-ec2` (or download the repository as a ZIP package: [Download ZIP](https://github.com/JMicallef9/terraform-ec2/archive/refs/heads/main.zip))

2. Navigate to the main Terraform folder: `cd terraform-ec2/terraform`

3. Set the required environment variables by creating a copy of the `terraform.tfvars.example` file and renaming it `terraform.tfvars`. There are two required variables:
- `bucket_name`: The name of the S3 bucket that stores the input and output files.
- `key_name`: The name of your EC2 `.pem` access key.

Note: Remember to ensure that your `bucket_name` is globally unique and that it uses only lower case alphanumeric characters and/or hyphens.

5. Apply the configuration using `terraform apply`; confirm with `yes` when prompted.

## Verification

After a few minutes, you should see an output file in your S3 bucket:
`s3://<bucket-name>/output/wordlist_<timestamp>.csv`

You can verify this either by checking manually in the AWS console or via the CLI:
`aws s3 ls s3://<bucket-name>/output/`

To inspect Docker activity directly, you can SSH into the EC2 instance using your access key and public DNS name:
`ssh -i ~/.ssh/access_key.pem ec2-user@<public-dns-name>` 

Once connected, you can use `docker ps -a` to check the running/exited containers, or inspect the Docker run logs using `sudo cat /var/log/docker_run.log`

## Cleanup

To avoid incurring unwanted AWS charges, remember to destroy all resources when finished using `terraform destroy`