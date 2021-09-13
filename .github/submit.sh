#!/bin/bash

sub_name=$(echo $1 | jq '.name')

echo Processing ${sub_name}...