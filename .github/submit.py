import os
import sys
import json
import copy
import plistlib
import urllib.request

# TODO:
# - Maintain recently updated & newly added project lists

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
        print(f'No zip download link provided!')
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
    
    # Create blank file
    if not os.path.exists('manifest_sub.json'):
        return False
        
    # Decode manifest and determine if this version
    # is already submitted for review
    file = open('manifest_sub.json', 'r')
    in_review = json.load(file).get(name, {}).get(ver, False)
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





def update_manifest(name, version, should_review):
    print("Adding to WebRepo submission manifest...")

    # Change to repo root
    wd = os.getcwd()
    os.chdir(REPO_ROOT)
    
    # Create blank file
    if not os.path.exists('manifest_sub.json'):
        file = open('manifest_sub.json', 'w')
        file.write('{}')
        file.close()

    # Read current manifest
    file = open('manifest_sub.json', 'r')
    manifest = json.load(file)
    file.close()
    
    # Add new entry
    if not name in manifest:
        manifest[name] = {}
    manifest[name][version] = should_review
    
    # Write new manifest file
    file = open('manifest_sub.json', 'w')
    file.write(json.dumps(manifest, indent=4))
    file.close()
    
    # Return to original wd
    os.chdir(wd)
    return





def generate_metadata(project_path, metadata):
    print("Generating project metadata:")
    
    # Take a copy
    md = copy.deepcopy(metadata)
    md.pop('zip_url', None)
    md.pop('review', None)
    md.pop('key', None)

    # Change to project root
    wd = os.getcwd()
    os.chdir(project_path)
    
    # Generate manifest
    file = open('metadata.json', 'w')
    md = json.dumps(md, indent=4, sort_keys=True)
    print(md)
    file.write(md)
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
        f'git commit -m "Add {md["name"]} project for submission"\n'
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

# Replace space with underscore
md_repo_name = md["name"].replace(" ", "_")
md_repo_ver  = md["version"].replace(" ", "_")

# Finalise the sparse git clone
stream = os.popen(f'git sparse-checkout set ".github" "{md_repo_name}" && git checkout')
print(stream.read())
stream.close()

# Ensure we have the right to overwrite a previous version
if project_is_in_review(md_repo_name, md_repo_ver):
    print(f'Project version has already been submitted for review! Please submit with a new version specified.')
    sys.exit()

# Directory where we're committing the project
project_dir=f'{REPO_ROOT}/{md_repo_name}/{md_repo_ver}'

# Delete old project version if it already exists
if os.path.exists(project_dir):
    os.system(f'git rm -rf "{project_dir}"')
os.system(f'mkdir -p "{project_dir}"')

# Download zip
if not download(md["zip_url"], '../submission.zip'):
    print(f'Failed to download submission zip from {md["zip_url"]}')
    sys.exit()
    
# Unzip submission
if (os.popen(f'unzip -q ../submission.zip -d "{project_dir}"').close() != None):
    print(f'Failed to unzip submission zip!')
    sys.exit()

# Generate Manifest
generate_project_manifest(project_dir)

# Add to submission manifest file
update_manifest(md_repo_name, md_repo_ver, md['review'])

# Write metadata file
generate_metadata(project_dir, md)

# Commit all of our changes
git_commit()

# Send notification to admin
pushover(
    f'New {"Review" if md["review"] else "Test"} Submission: {md["name"]}',
    f'{md["version"]}:\n{md["update_notes"]}')
