import json
import http.client
import os

def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    subject = event['Records'][0]['Sns']['Subject']

    # Prepare the message payload
    postData = {
        "channel": "#datadog",
        "username": "AWS SNS",
        "text": subject,
        "attachments": [
            {
                "text": message
            }
        ]
    }

    # Slack webhook URL path - Make sure this starts with a '/'
    webhook_path = '/services/T068FGGV37W/B06J22JJQMV/pU0qeskZNM4CwROrJIvZrAu9'

    # Create a connection to the Slack API
    connection = http.client.HTTPSConnection('hooks.slack.com')

    # Send the POST request
    connection.request('POST', webhook_path, json.dumps(postData),
                       {'Content-Type': 'application/json'})

    # Get the response
    response = connection.getresponse()
    response_body = response.read().decode()

    # Check for successful post within the 2xx range
    if 200 <= response.status < 300:
        return {
            'statusCode': 200,
            'body': json.dumps('Message sent to Slack successfully')
        }
    else:
        # Log the response body from Slack for debugging
        print("Failed to send message to Slack. Response:", response_body)
        return {
            'statusCode': response.status,
            'body': response_body  # Include the full response body for more context
        }

