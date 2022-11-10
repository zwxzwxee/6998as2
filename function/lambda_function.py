import json
import boto3

# LexV2 client uses 'lexv2-runtime'
client = boto3.client('lexv2-runtime')


def lambda_handler(event, context):
    # TODO implement
    # Submit the text
    response = client.recognize_text(
        botId="RKVNKGE0WD",
        botAliasId="TSTALIASID",
        localeId='en_US',
        sessionId="902672276522487",
        text=event['messages'][0]['unstructured']['text'])
    msgs = [
            {
                "type": "unstructured",
                "unstructured": {
                    "text": i['content'],
                }
            }
            for i in response['messages']
            ]
    
    return {
        'statusCode': 200,
        'messages': msgs
    }
