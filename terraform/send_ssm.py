import json
import boto3
import os

def lambda_handler(event, context):

    ssm_client = boto3.client("ssm") # inside or outside function?

    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    ec2_instance_id = os.environ['EC2_INSTANCE_ID'] # set env variable?

    command = f"docker run jmicallef9/word-list-generator-ec2:latest process s3://{bucket}{key}" # use process?

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