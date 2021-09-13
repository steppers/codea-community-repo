#!/bin/bash

sub_name=$(echo $1 | jq -r '.')

echo Processing ${sub_name}...