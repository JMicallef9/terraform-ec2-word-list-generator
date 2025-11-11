import json
import boto3
import os

ssm_client = boto3.client("ssm")

def lambda_handler(event, context):

    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    ec2_instance_id = os.environ['EC2_INSTANCE_ID']

    command = f"docker run -e BUCKET_NAME={bucket} -e INPUT_KEY={key} jmicallef9/word-list-generator-ec2:latest"

    response = ssm_client.send_command(
        InstanceIds=[ec2_instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={
            "commands": [command]
        }
    )

    print(f"SSM command sent: {response}")
    return {
        "statusCode": 200, 
        "body": json.dumps("Command sent successfully")
    }