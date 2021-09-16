import os
import json
import urllib.request

PUSHOVER_APP_TOKEN = os.environ.get('PUSHOVER_APP_TOKEN')
PUSHOVER_GROUP_TOKEN = os.environ.get('PUSHOVER_GROUP_TOKEN')

def pushover(title, message):
    payload = {
        "token": PUSHOVER_APP_TOKEN,
        "user": PUSHOVER_GROUP_TOKEN,
        "title": title,
        "message": message
    }

    req = urllib.request.Request('https://api.pushover.net/1/messages.json')
    req.add_header('Content-Type', 'application/json')
    response = urllib.request.urlopen(req, json.dumps(payload).encode('utf-8'))
    return

# print(os.environ.get('GITHUB_WORKSPACE'))

pushover("Title", "Message")
