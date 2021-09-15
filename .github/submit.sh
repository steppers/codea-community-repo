#!/bin/bash

git_repo="${GITHUB_WORKSPACE}"

# TODO:
# - Add Error checking

sub_name=$(echo "$1" | jq -r '.name')
sub_desc_short=$(echo "$1" | jq -r '.short_description')
sub_desc_long=$(echo "$1" | jq -r '.description')
sub_authors=$(echo "$1" | jq -r '.authors[]')
sub_version=$(echo "$1" | jq -r '.version')
sub_update_notes=$(echo "$1" | jq -r '.update_notes')
sub_zip_url=$(echo "$1" | jq -r '.zip_url')
sub_library=$(echo "$1" | jq -r '.library')
sub_hidden=$(echo "$1" | jq -r '.hidden')

# Replace spaces with underscores
project_ver=$(echo ${sub_version} | tr ' ' '_')
project_name=$(echo ${sub_name} | tr ' ' '_')

# Directory where we're committing the project
project_dir="${git_repo}/${project_name}/${project_ver}"

echo Processing "${sub_name}"...
echo Using "${sub_zip_url}"

# Download zip file
curl "${sub_zip_url}" -o ../submission.zip

# Extract zip file
unzip -q ../submission.zip -d "${project_dir}"

echo "${project_dir}"
ls -l "${project_dir}"

# Sanitize .codea bundle name to match project name + authors

# Adjust project metadata in Info.plist to match provided metadata

# Commit project

# Add to submission manifest file