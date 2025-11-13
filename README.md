# Word List Generator (via Terraform, EC2 and Docker)

This project automates the deployment of an AWS EC2 instance that is ready to run a Dockerised Python application. The application is a simplified and adapted version of the [Word List Generator](https://github.com/JMicallef9/word-list-generator) app. Once the EC2 instance has been deployed, file uploads to an S3 bucket will trigger a Lambda function to send commands to the EC2. The EC2 will run the Dockerised app, processing the text file in the S3 bucket and then generating a word list CSV file that is stored in the same bucket.

When deployed, Terraform:

1. Launches an EC2 instance and S3 bucket.
2. Installs and starts Docker within the EC2 instance.
3. Pulls a pre-built Docker image to the EC2 instance: `jmicallef9/word-list-generator-ec2:latest`

When a text file is uploaded to the S3 bucket's `/input` folder, the infrastructure:

1. Runs the container to process the text file.
2. Saves the generated `.csv` word file in the S3 bucket's `output/` folder.

## Prerequisites

- Terraform
- AWS account and credentials configured via `aws configure`
- An AWS EC2 key pair
- A source input file in one of the following file formats: `.txt`, `.srt`, `.md`, `.docx`, `.pdf`, `.epub`

## Instructions

1. Clone the repository with the following command: `git clone https://github.com/JMicallef9/terraform-ec2` (or download the repository as a ZIP package: [Download ZIP](https://github.com/JMicallef9/terraform-ec2/archive/refs/heads/main.zip))

2. Navigate to the main Terraform folder via the command line: `cd terraform-ec2/terraform`

3. Set the required environment variables by creating a copy of the `terraform.tfvars.example` file and renaming it `terraform.tfvars`. There are two required variables:
- `bucket_name`: The name of the S3 bucket that stores the input and output files.
- `key_name`: The name of your EC2 .pem access key.

Note: Remember to ensure that your `bucket_name` is globally unique and that it uses only lower case alphanumeric characters and/or hyphens.

5. Apply the configuration using `terraform apply`; confirm with `yes` when prompted.

Terraform will create the S3 bucket and launch the EC2 instance.

To trigger the container to process a file, you can either:

- Upload the file to the `/input` folder of your S3 bucket using the AWS console
- OR run an AWS CLI command using the local filepath and bucket name:
`aws s3 cp ./data/sample.txt s3://<bucket-name>/input/sample.txt`

## Verification

After a few minutes, you should see an output file in your S3 bucket:
`s3://<bucket-name>/output/wordlist_<timestamp>.csv`

You can verify this either by checking manually in the AWS console or via the CLI:
`aws s3 ls s3://<bucket-name>/output/`

You can also go to the CloudWatch log groups to view the logs.

To verify Docker activity or view the logs directly, you can SSH into the EC2 instance using your access key and public DNS name:
`ssh -i ~/.ssh/access_key.pem ec2-user@<public-dns-name>` 

Once connected, you can use `docker ps -a` to check the running/exited containers, or inspect the Docker run logs using `sudo cat /var/log/docker_run.log`

If no errors are displayed in the run logs, you can be sure that the operation ran successfully.

To avoid incurring unwanted AWS charges, remember to destroy all resources when finished using `terraform destroy`