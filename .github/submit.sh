#!/bin/bash

git_repo="${GITHUB_WORKSPACE}"

# TODO:
# - Add Error checking
# - Only delete old project if the old project is marked for testing
# - Thorough code injection checks

errcho() {
    >&2 echo $@;
}

pushover() {
    echo "Sending Pushover notification";
    
    local payload='{"token":"'$PUSHOVER_APP_TOKEN'", "user":"'$PUSHOVER_GROUP_TOKEN'", "title":"'$1'", "message":"'$2'"}'
    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.pushover.net/1/messages.json
}

metadata=$(echo "$1" | jq -r 'del(.zip_url)')

sub_name=$(echo "$1" | jq -r '.name')
sub_desc_short=$(echo "$1" | jq -r '.short_description')
sub_desc_long=$(echo "$1" | jq -r '.description')
sub_authors=$(echo "$1" | jq -r '.authors[]')
sub_version=$(echo "$1" | jq -r '.version')
sub_update_notes=$(echo "$1" | jq -r '.update_notes')
sub_zip_url=$(echo "$1" | jq -r '.zip_url')
sub_library=$(echo "$1" | jq -r '.library')
sub_hidden=$(echo "$1" | jq -r '.hidden')
sub_review=$(echo "$1" | jq -r '.review')

# Replace spaces with underscores
project_name=$(echo "${sub_name}" | tr ' ' '_')
project_ver=$(echo "${sub_version}" | tr ' ' '_')

[[ -z "${project_name}" ]] && errcho "No project name!" && exit 1
[[ -z "${project_ver}" ]] && errcho "No project version!" && exit 1
[[ -z "${sub_zip_url}" ]] && errcho "No zip url!" && exit 1

# Directory where we're committing the project
project_dir="${git_repo}/${project_name}/${project_ver}"

# Delete old project version if it already exists
[[ -d "${project_dir}" ]] && git rm -rf "${project_dir}"
mkdir -p "${project_dir}"

echo Processing "${sub_name}"...
echo Using "${sub_zip_url}"

# Download zip file
curl -s "${sub_zip_url}" -o ../submission.zip

# Extract zip file
unzip -q ../submission.zip -d "${project_dir}"

# Rename project bundle if required
bundle_name="${sub_name}.codea"
cd "${project_dir}"
[[ ! -d "${bundle_name}" ]] && mv *.codea "${bundle_name}"

# Generate manifest
find "${bundle_name}" -type f > manifest.txt

# Save metadata
echo "${metadata}" > metadata.json

# Sanitize .codea bundle name to match project name + authors

# Adjust project metadata in Info.plist to match provided metadata

# Add to submission manifest file
cd "${git_repo}"
submissions_manifest=manifest_sub.json
[[ ! -f "${submissions_manifest}" ]] && echo "{}" > "${submissions_manifest}"
jq -r '.["'${project_name}'"]["'${project_ver}'"] = '${sub_review} < "${submissions_manifest}" > _tmp.json
mv _tmp.json "${submissions_manifest}"

# Commit project (We need to be damn sure that we're good to go here)
commit_message="Add $sub_name project for submission"
git config --global user.name "autosub"
git config --global user.email "autosub@webrepo.com"
git add -A
git commit -m "${commit_message}"
git push

# Send pushover notification
review=$([[ $sub_review == "true" ]] && echo "Review" || echo "Test")
pushover "New ${review} Submission: ${sub_name}" "${sub_version} - ${sub_update_notes}"