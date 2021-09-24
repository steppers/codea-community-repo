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
ADMIN_KEY = os.environ.get('ADMIN_KEY')

def is_admin(payload):
    if 'key' not payload:
        print(f'No admin key provided!')
        return False
    if payload['key'] != ADMIN_KEY:
        print(f'Incorrect admin key provided!')
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
        
    in_review = False
        
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
    return in_review
    

# Download a url to a file
def download(url, filepath):
    file = open(filepath, "wb")
    with urllib.request.urlopen(url) as stream:
        if stream.status != 200:
            return False
        while 1:
            chunk = stream.read(1024*256) # 256K
            if not chunk:
                break
            file.write(chunk)        
        # TODO: Verify file size
    file.close()
    return True
    

def generate_project_manifest(project_path):
    print("Generating project manifest:")

    # Change to project root
    wd = os.getcwd()
    os.chdir(project_path)
    
    # Generate manifest
    stream = os.popen("find -type f -printf '%P\n'")
    manifest = stream.read()
    stream.close()
    print(manifest)
    file = open('manifest.txt', 'w')
    file.write(manifest)
    file.close()
    
    # Return to original wd
    os.chdir(wd)
    return


def update_manifest(name, version):
    print("Adding to WebRepo manifest...")

    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    # Create blank file
    if not os.path.exists('manifest.json'):
        file = open('manifest.json', 'w')
        file.write('{}')
        file.close()

    # Read current manifest
    file = open('manifest.json', 'r')
    manifest = json.load(file)
    file.close()
    
    # Add new entry
    if not name in manifest:
        manifest[name] = []
    manifest[name].append(version)
    
    # Write new manifest file
    file = open('manifest.json', 'w')
    file.write(json.dumps(manifest, indent=4))
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
#if not is_admin(payload):
#    sys.exit()
    
# Specified project must be in review
if not project_is_in_review(payload['name'], payload['version']):
    print(f'Project is not in review: {payload["name"]} - {payload["version"]} ...')
    sys.exit()
    
print(f'Processing {md["name"]} - {md["version"]} ...')

# Finalise the sparse git clone
stream = os.popen(f'git sparse-checkout set ".github" "{repo_name}" && git checkout')
print(stream.read())
stream.close()

# Add to manifest file
update_manifest(repo_name, repo_ver)

# Commit all of our changes
git_commit()

# Send notification to admin
pushover(
    f'Rejected {md["name"]}-{md["version"]}',
    "")
