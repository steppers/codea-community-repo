import os
import urllib3

PUSHOVER_APP_TOKEN = os.environ.get('PUSHOVER_APP_TOKEN')
PUSHOVER_GROUP_TOKEN = os.environ.get('PUSHOVER_GROUP_TOKEN')

def pushover(title, message):
    payload = {
        "token": PUSHOVER_APP_TOKEN,
        "user": PUSHOVER_GROUP_TOKEN,
        "title": title,
        "message": message
    }

    r = http.request_encode_body(
        'POST',
        'https://api.pushover.net/1/messages.json',
        haders={
            'Content-Type': 'application/json'
        },
        body=json.dumps(payload).encode('utf-8'))
    return

# print(os.environ.get('GITHUB_WORKSPACE'))

pushover("Title", "Message")
