#!/bin/bash

echo $1
sub_name=$(echo $1 | jq -R '.["name"]')

echo Processing ${sub_name}...