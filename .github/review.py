# Accepts a name + version combo along with 
# 2 URLs we can use to download the project & metadata
# from file.io (100MB project max)
#
# If the project is already queued for review or already
# exists in the repo, the new submission is rejected
# automatically.
#
# If an entry for the project is not already queued and
# does not already exist then it is added to review_queue.json
# which can be cross-checked with the repo manifest
# to determine review statuses.

import os
import sys
import json
import copy
import plistlib
import urllib.request

# Get environment variables
PUSHOVER_APP_TOKEN = os.environ.get('PUSHOVER_APP_TOKEN')
PUSHOVER_GROUP_TOKEN = os.environ.get('PUSHOVER_GROUP_TOKEN')
SUB_METADATA = os.environ.get('SUB_METADATA')
REPO_ROOT = os.environ.get('GITHUB_WORKSPACE')
RESERVED_KEY = os.environ.get('RESERVED_KEY')

# Names of reserved projects
reserved_names = [
    ".github",
    "screenshots",
    "WebRepo"
]

def validate_metadata(md):
    success = True

    if "name" not in md:
        print(f'No project name provided!')
        success = False
    else:
        if md['name'] in reserved_names:
            if md.get('key', None) != RESERVED_KEY:
                print(f'Provided key is invalid!')
                success = False
        
    if "version" not in md:
        print(f'No project version provided!')
        success = False
        
    # TODO: Check version format
        
    if "zip_url" not in md:
        print(f'No project zip download link provided!')
        success = False
        
    if "metadata_url" not in md:
        print(f'No metadata download link provided!')
        success = False

    if "short_description" not in md:
        print(f'No short description provided!')
        success = False
    elif len(md['short_description']) > 40:
        print(f'Short description is too long! (>40 characters)')
        success = False
        
    if "description" not in md and "short_description" in md:
        print(f'No long description provided. Copying short description.')
        md["description"] = md["short_description"]
    elif "description" not in md:
        print(f'No long description provided!')
        success = False
    elif len(md['description']) > 1024:
        print(f'Long description is too long! (>1024 characters)')
        success = False
        
    if "authors" not in md:
        print(f'No authors provided!')
        success = False
        
    if "review" not in md:
        md['review'] = False
        
    if "icon" not in md:
        print(f'No icon path provided!')
        success = False
        
    if md['review'] == True and "categories" not in md:
        print(f'No categories provided! Please provide at least 1 category for approval.')
        success = False
        
    return success





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





def project_is_live(name, ver):
    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    # No manifest
    if not os.path.exists('manifest.json'):
        return False
        
    is_live = False
        
    # Decode manifest and determine if this version
    # is already live and available
    file = open('manifest.json', 'r')
    manifest = json.load(file)
    if name in manifest:
        for version in manifest[name]:
            if version == ver:
                is_live = True
                break
    file.close()
    
    # Return to original wd
    os.chdir(wd)
    return is_live





def queue_for_review(name, version, zip_url, metadata_url):
    print("Adding to WebRepo review queue...")

    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    # Create blank file
    if not os.path.exists('review_queue.json'):
        file = open('review_queue.json', 'w')
        file.write('{}')
        file.close()

    # Read current queue
    file = open('review_queue.json', 'r')
    queue = json.load(file)
    file.close()
    
    # Add new entry
    queue.append({
        "name": name,
        "version": version,
        "zip_url": zip_url,
        "metadata_url": metadata_url
    })
    
    # Write new queue
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
        f'git commit -m "Queue {md["name"]}-{md["version"} project for review"\n'
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





# Parse metadata input
md = json.loads(SUB_METADATA)

# Validate the provided metadata
if not validate_metadata(md):
    print("Metadata validation failed! Aborting...")
    sys.exit()
    
print(f'Processing {md["name"]} - {md["version"]} ...')

# Finalise the sparse git clone
stream = os.popen(f'git sparse-checkout set ".github" "manifest.json" "review_queue.json" && git checkout')
print(stream.read())
stream.close()

# Ensure we have the right to overwrite a previous version
if project_is_in_review(md_repo_name, md_repo_ver):
    print(f'Project version has already been submitted for review! Please submit with a new version specified.')
    sys.exit()

# Ensure a project of the same name and version isn't already live
if project_is_live(md_repo_name, md_repo_ver):
    print(f'Project version is already live! Please submit with a new version specified.')
    sys.exit()

# Add to review queue file
queue_for_review(md_repo_name, md_repo_ver, md['zip_url'], md['metadata_url'])

# Commit all of our changes
git_commit()

# Send notification to admin
pushover(
    f'New Review Request: {md["name"]}',
    f'{md["version"]}:\n{md["update_notes"]}')
