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
import time

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
    

# Download a url to a file
def download(url, filepath):
    file = open(filepath, "wb")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as stream:
            if stream.status != 200:
                file.close()
                return False
            while 1:
                chunk = stream.read(1024*256) # 256K
                if not chunk:
                    break
                file.write(chunk)        
            # TODO: Verify file size
    except urllib.error.HTTPError as err:
        print(url, err.reason)
        file.close()
        return False
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
    

def add_timestamp(metadata_path):
    # Read current metadata
    file = open(metadata_path, 'r')
    md = json.load(file)
    file.close()
    
    # Add timestamp of approval
    md["timestamp"] = int(time.time())
    
    # Write new metadata file
    file = open(metadata_path, 'w')
    file.write(json.dumps(md, indent=4))
    file.close()
    
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
        f'git commit -m "Approve & add {payload["name"]}-{payload["version"]}"\n'
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

def fail(msg):
    pushover("[FAIL] Approval", msg)
    sys.exit()



# Parse payload
payload = json.loads(PAYLOAD)

# Admin check
if not is_admin(payload):
    fail(f'Admin key check failed: {payload["name"]} - {payload["version"]}')
    sys.exit()
    
# Specified project must be in review
if not project_is_in_review(payload['name'], payload['version']):
    fail(f'Project is not in review: {payload["name"]} - {payload["version"]} ...')
    
print(f'Processing {payload["name"]} - {payload["version"]} ...')

# Replace space with underscore
repo_name = payload["name"].replace(" ", "_")
repo_ver  = payload["version"].replace(" ", "_")

# Finalise the sparse git clone
stream = os.popen(f'git sparse-checkout set ".github" "{repo_name}" && git checkout')
print(stream.read())
stream.close()

# Directory where we're committing the project
project_dir=f'{REPO_ROOT}/{repo_name}/{repo_ver}'

# Reject project version if it already exists
if os.path.exists(project_dir):
    fail(f'Project already live! abort.')
os.system(f'mkdir -p "{project_dir}"')

# Download zip
attempts = 5
print(f'Attempting to download submission zip from {payload["zip_url"]}')
while not download(payload["zip_url"], '../submission.zip'):
    attempts -= 1
    print("Failed to download submission zip, retrying...")
    time.sleep(5)
    if attempts == 0:
        fail(f'Failed to download submission zip from {payload["zip_url"]}')
    
# Unzip submission
if (os.popen(f'unzip -q ../submission.zip -d "{project_dir}"').close() != None):
    fail(f'Failed to unzip submission zip!')

# Generate Manifest
generate_project_manifest(project_dir)

# Download metadata (after the manifest generation)
attempts = 5
print(f'Attempting to download submission metadata from {payload["metadata_url"]}')
while not download(payload["metadata_url"], f'{project_dir}/metadata.json'):
    attempts -= 1
    print("Failed to download metadata, retrying...")
    time.sleep(5)
    if attempts == 0:
        fail(f'Failed to download metadata from {payload["metadata_url"]}')

# Add unix timestamp to metadata
add_timestamp(f'{project_dir}/metadata.json')

# Add to manifest file
update_manifest(repo_name, repo_ver)

# Remove from review queue
remove_from_queue(payload['name'], payload['version'])

# Commit all of our changes
git_commit()

# Send notification to admin
pushover("[SUCCESS] Approval", f'{payload["name"]}-{payload["version"]}')
