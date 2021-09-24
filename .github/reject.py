# Accepts a name + version combo along with 
# 2 URLs we can use to download the project & metadata
# from bayfiles (100MB project max)
#
# If the project is not in the queue for review then nothing
# is done and the project will not be added to the repo.
#
# If the project is queued then we download and add the project
# to the repo, remove the entry from the queue, and then add the
# project version to the repo manifest.

import os
import sys
import json
import copy
import plistlib
import urllib.request

# Get environment variables
PUSHOVER_APP_TOKEN = os.environ.get('PUSHOVER_APP_TOKEN')
PUSHOVER_GROUP_TOKEN = os.environ.get('PUSHOVER_GROUP_TOKEN')
PAYLOAD = os.environ.get('PAYLOAD')
REPO_ROOT = os.environ.get('GITHUB_WORKSPACE')
REVIEW_KEY = os.environ.get('REVIEW_KEY')

def is_admin(payload):
    if not 'key' in payload:
        print(f'No review key provided!')
        return False
    if payload['key'] != REVIEW_KEY:
        print(f'Incorrect review key provided!')
        return False
    return True
    

def project_is_in_review(name, ver):
    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    # Nothing queued
    if not os.path.exists('review_queue.json'):
        return False
        
    in_review = False
        
    # Decode manifest and determine if this version
    # is already queued for review
    file = open('review_queue.json', 'r')
    for entry in json.load(file):
        if entry['name'] == name and entry['version'] == ver:
            in_review = True
            break
    file.close()
    
    # Return to original wd
    os.chdir(wd)
    return in_review
    

def remove_from_queue(name, ver):
    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
        
    # Decode manifest and determine if this version
    # is already queued for review
    file = open('review_queue.json', 'r')
    queue = json.load(file)
    for entry in queue:
        if entry['name'] == name and entry['version'] == ver:
            queue.remove(entry)
            break
    file.close()
    
    # Write new queue file
    file = open('review_queue.json', 'w')
    file.write(json.dumps(queue, indent=4))
    file.close()
    
    # Return to original wd
    os.chdir(wd)
    return


def git_commit():
    print("Committing changes to repository...")

    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    stream = os.popen(
        f'git config --global user.name "autosub"\n'
        f'git config --global user.email "autosub@webrepo.com"\n'
        f'git add -A\n'
        f'git commit -m "Reject {payload["name"]}-{payload["version"]}"\n'
        f'git push'
    )
    print(stream.read())
    stream.close()
    
    # Return to original wd
    os.chdir(wd)
    return


# Sends a notification
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





# Parse payload
payload = json.loads(PAYLOAD)

# Admin check
if not is_admin(payload):
    sys.exit()
    
# Specified project must be in review
if not project_is_in_review(payload['name'], payload['version']):
    print(f'Project is not in review: {payload["name"]} - {payload["version"]} ...')
    sys.exit()
    
print(f'Processing {payload["name"]} - {payload["version"]} ...')

# Finalise the sparse git clone
stream = os.popen(f'git sparse-checkout set ".github" && git checkout')
print(stream.read())
stream.close()

# Remove from review queue
remove_from_queue(payload['name'], payload['version'])

# Commit all of our changes
git_commit()

# Send notification to admin
pushover(
    f'Rejected {payload["name"]}-{payload["version"]}',
    "")
