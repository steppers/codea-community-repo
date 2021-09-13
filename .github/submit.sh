#!/bin/bash

sub_name=$(echo "$1" | jq -R '.["name"]')

echo Processing ${sub_name}...