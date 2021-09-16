import os
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

#    r = http.request_encode_body(
#        'POST',
#        'https://api.pushover.net/1/messages.json',
#        headers={
#            'Content-Type': 'application/json'
#        },
#        body=json.dumps(payload).encode('utf-8'))
        
    req = urllib.request.Request(
        'https://api.pushover.net/1/messages.json',
        data=json.dumps(payload).encode('utf-8')),
        headers={
            'Content-Type': 'application/json'
        })
        
    r = urllib.request.urlopen(req)
    return

# print(os.environ.get('GITHUB_WORKSPACE'))

pushover("Title", "Message")
