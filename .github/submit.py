import os
import json
import plistlib
import urllib.request

# Send a notification
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
    
# Get environment variables
PUSHOVER_APP_TOKEN = os.environ.get('PUSHOVER_APP_TOKEN')
PUSHOVER_GROUP_TOKEN = os.environ.get('PUSHOVER_GROUP_TOKEN')
SUB_METADATA = os.environ.get('SUB_METADATA')
REPO_ROOT = os.environ.get('GITHUB_WORKSPACE')

# Parse metadata input
md = json.loads(SUB_METADATA)

# Validate inputs
if "name" not in md:
    print(f'No project name provided!')
    sys.exit()
    
if "version" not in md:
    print(f'No project version provided! ({md_name})')
    sys.exit()
    
print(f'Processing {md["name"]} - {md["version"]} ...')

# Replace space with underscore
md_repo_name = md["name"].replace(" ", "_")
md_repo_ver  = md["version"].replace(" ", "_")

# Send notification to admin
pushover(f'New {"Review" if md["review"] else "Test"} Submission: {md["name"]}', f'{md["version"]} - {md["update_notes"}')
