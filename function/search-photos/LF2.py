import json
import boto3
import io
from datetime import datetime
import urllib.parse
from requests_aws4auth import AWS4Auth
import requests
import base64


def lambda_handler(event, context):
    # lex bot parsig sentences
    chatbot = boto3.client('lexv2-runtime')
    response = chatbot.recognize_text(
        botId="23UASWBATI",
        botAliasId="TSTALIASID",
        localeId='en_US',
        sessionId="90267227652285",
        text=event['queryStringParameters']['q'])

    labels = response['messages'][0]['content'].split()

    # open search
    region = 'us-east-1'
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    host = 'https://search-photos-wwabll457m6pbqsqqfsgz7qjq4.us-east-1.es.amazonaws.com'
    index = 'photos'
    type = '_doc'
    url = host + '/' + index + '/' + type + '/_search?' + "q=labels:"
    id_list = set()

    for l in labels:
        if l[-1]=="s":
            l=l[:-1]
        r = requests.get(url + l, auth=awsauth)
        response = r.json()
        for photo in response['hits']['hits']:
            id_list.add(photo['_source']['objectKey'])

    # get files from s3
    s3 = boto3.client('s3')
    bucket = "6998as2b2"
    imgs = []

    for i in id_list:
        fileObj = s3.get_object(Bucket=bucket, Key=i)
        file_content = fileObj["Body"].read()
        imgs.append(base64.b64encode(file_content).decode('utf-8'))

    return {
        "statusCode": 200,
        "headers": {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
        'body': json.dumps(imgs),
    }
