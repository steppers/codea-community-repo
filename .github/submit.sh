#!/bin/bash

echo "$1" > meta.json

sub_name=$(cat meta.json | jq -R '.name')

echo Processing ${sub_name}...