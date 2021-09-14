#!/bin/bash

sub_name=$(echo "$1" | jq -r '.name')
sub_desc_short=$(echo "$1" | jq -r '.short_description')
sub_desc_long=$(echo "$1" | jq -r '.description')
sub_authors=$(echo "$1" | jq -r '.authors[]')
sub_version=$(echo "$1" | jq -r '.version')
sub_update_notes=$(echo "$1" | jq -r '.update_notes')
sub_zip_url=$(echo "$1" | jq -r '.zip_url')
sub_library=$(echo "$1" | jq -r '.library')
sub_hidden=$(echo "$1" | jq -r '.hidden')

echo Processing "${sub_name}"...

# Get the actual zip url by scraping the bayfiles page
sub_zip_url=$(curl -sS "${sub_zip_url}" | sed -n 's/.*href="\(https\:\/\/cdn[^"]*\)".*/\1/p')
echo $sub_zip_url

# Download zip file
curl "${sub_zip_url}" -o submission.zip

# Extract zip file
unzip submission.zip -d "${subname}.codea"

ls "${subname}.codea"