#!/bin/bash

echo "$1" > meta.json
cat meta.json

sub_name=$(cat meta.json | jq -r '.name')

echo Processing ${sub_name}...