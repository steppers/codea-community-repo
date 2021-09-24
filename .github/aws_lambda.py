import os
import json
import urllib3

#################################################################
# REPLACE THIS WITH A TOKEN WITH ACCESS TO THE REPOSITORY
GITHUB_TOKEN="ghp_dshjknmcuadsbnSGuASgy8ughsAsg78uhjds"
# (This is not a valid token)

# REPLACE THESE
GITHUB_REPO_OWNER="steppers"
GITHUB_REPO_NAME="codea-community-repo"
GITHUB_WORKFLOW_ID="review.yml"
#################################################################

http = urllib3.PoolManager()

def lambda_handler(event, context):
    
    # Load the metadata accounting for a test trigger
    proj_metadata = event
    if "body" in event:
        proj_metadata = json.loads(event["body"])
        
    if 'type' in proj_metadata:
        if proj_metadata['type'] == 'approve':
            GITHUB_WORKFLOW_ID="approve.yml"
        else if proj_metadata['type'] == 'reject':
            GITHUB_WORKFLOW_ID="reject.yml"
        
    # The github workflow dispatch payload
    payload={
        "ref": "main",
        "inputs": {
            "metadata_json": json.dumps(proj_metadata)
        }
    }
    
    # Trigger the Github Action, sending the metadata payload too    
    r = http.request_encode_body(
        'POST',
        'https://api.github.com/repos/' + GITHUB_REPO_OWNER + '/' + GITHUB_REPO_NAME + '/actions/workflows/' + GITHUB_WORKFLOW_ID +'/dispatches',
        headers={
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': 'token ' + GITHUB_TOKEN
        },
        body=json.dumps(payload).encode('utf-8'))
        
    if (r.status != 204):
        return { 'statusCode': 400 }
    
    # Everything ok
    return {
        'statusCode': 200
    }
	