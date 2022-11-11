import json
import boto3
import io
import urllib.parse
from datetime import datetime
from requests_aws4auth import AWS4Auth
import requests


def lambda_handler(event, context):
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    rekog = boto3.client("rekognition")
    s3 = boto3.client('s3')
    bucket = "6998as2b2"

    fileObj = s3.get_object(Bucket=bucket, Key=key)
    file_content = fileObj["Body"].read()
    rekog_response = rekog.detect_labels(Image={"Bytes": file_content}, MaxLabels=3, MinConfidence=70)
    rekog_labels = list(map(lambda label: label['Name'].lower(), rekog_response["Labels"]))

    s3_response = s3.head_object(Bucket=bucket, Key=key)
    if "customlabels" in s3_response["Metadata"]:
        s3_raw_labels = s3_response["Metadata"]["customlabels"].lower().split(", ")
    else:
        s3_raw_labels = []

    labels = list(set(rekog_labels + s3_raw_labels))

    region = 'us-east-1'
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    host = 'https://search-photos-wwabll457m6pbqsqqfsgz7qjq4.us-east-1.es.amazonaws.com'
    index = 'photos'
    type = '_doc'
    url = host + '/' + index + '/' + type
    headers = {"Content-Type": "application/json"}

    document = {
        "objectKey": key,
        "bucket": bucket,
        "createdTimestamp": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "labels": labels
    }
    r = requests.post(url, auth=awsauth, json=document, headers=headers)

    return {
        'headers': {"Content-Type": "image/jpg"},
        'statusCode': 200,
        'body': 1,
        'labels': labels
    }
